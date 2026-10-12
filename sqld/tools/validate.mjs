#!/usr/bin/env node
// SQLD 관계망 데이터 검증기 (의존성 없음)
//   node sqld/tools/validate.mjs            → 세 데이터셋 검증, 오류가 있으면 exit 1
//   node sqld/tools/validate.mjs --verbose  → 경고(원본 용어 커버리지 등) 상세 출력
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const VERBOSE = process.argv.includes("--verbose");
const MAPS = [
  { id: "subject-1", legacy: "SQLD_1과목_다섯관계_전용지도.html" },
  { id: "bridge", legacy: "SQLD_1_2과목_다섯관계_대응지도.html" },
  { id: "subject-2", legacy: "SQLD_2과목_다섯관계_전용지도.html" },
];
const RELATIONS = ["type_of", "instance_of", "part_of", "cause_of", "data_to_claim"];
const STATUSES = ["confirmed", "derived", "supplement", "authored", "inferred", "pending", "example"];
const CAUSALITY = ["deterministic", "sufficient", "necessary", "probabilistic"];

let errors = 0;
let warnings = 0;
const err = (map, msg) => { errors++; console.log(`  ✗ [${map}] ${msg}`); };
const warn = (map, msg, show = true) => { warnings++; if (show) console.log(`  ! [${map}] ${msg}`); };

function hasCycle(nodes, edges, type) {
  const adj = new Map();
  for (const e of edges) if (e.type === type) (adj.get(e.source) ?? adj.set(e.source, []).get(e.source)).push(e.target);
  const state = new Map();
  const visit = (n, path) => {
    if (state.get(n) === 1) return [...path, n];
    if (state.get(n) === 2) return null;
    state.set(n, 1);
    for (const m of adj.get(n) ?? []) { const c = visit(m, [...path, n]); if (c) return c; }
    state.set(n, 2);
    return null;
  };
  for (const n of nodes) { const c = visit(n.id, []); if (c) return c; }
  return null;
}

function legacyData(file) {
  const html = readFileSync(join(ROOT, "legacy", file), "utf8");
  const m = html.match(/<script id="dataJson" type="application\/json">([\s\S]*?)<\/script>/);
  return JSON.parse(m[1]);
}

const summary = [];
for (const { id: mapId, legacy } of MAPS) {
  console.log(`\n▶ ${mapId}`);
  const data = JSON.parse(readFileSync(join(ROOT, "data", `${mapId}.json`), "utf8"));
  const { nodes, edges, scenarios, documents, areas } = data;
  const byId = new Map();
  const areaIds = new Set(areas.map((a) => a.id));

  // 1) 노드 스키마
  for (const n of nodes) {
    if (byId.has(n.id)) err(mapId, `중복 노드 id ${n.id}`);
    byId.set(n.id, n);
    for (const k of ["id", "label", "kind", "area", "subject", "def", "refs", "basis"])
      if (n[k] === undefined || n[k] === "") err(mapId, `노드 ${n.id}: '${k}' 누락`);
    if (!data.kinds[n.kind]) err(mapId, `노드 ${n.id}: 알 수 없는 kind ${n.kind}`);
    if (!areaIds.has(n.area)) err(mapId, `노드 ${n.id}: 알 수 없는 area ${n.area}`);
    for (const r of n.refs ?? []) if (!documents[r.doc]) err(mapId, `노드 ${n.id}: 문서 ${r.doc} 미정의`);
  }

  // 2) 간선 스키마
  const edgeIds = new Set();
  const keys = new Set();
  for (const e of edges) {
    for (const k of ["id", "source", "target", "type", "direction", "why", "refs", "status"])
      if (e[k] === undefined || e[k] === "") err(mapId, `간선 ${e.id ?? "?"}: '${k}' 누락`);
    if (!e.refs?.length) err(mapId, `간선 ${e.id}: 출처(refs)가 비어 있음`);
    if (edgeIds.has(e.id)) err(mapId, `중복 간선 id ${e.id}`);
    edgeIds.add(e.id);
    if (!RELATIONS.includes(e.type)) err(mapId, `간선 ${e.id}: 다섯 관계 외 유형 ${e.type}`);
    if (!STATUSES.includes(e.status)) err(mapId, `간선 ${e.id}: 알 수 없는 검증 상태 ${e.status}`);
    if (!byId.has(e.source)) err(mapId, `간선 ${e.id}: 출발 노드 ${e.source} 없음`);
    if (!byId.has(e.target)) err(mapId, `간선 ${e.id}: 도착 노드 ${e.target} 없음`);
    if (e.source === e.target) err(mapId, `간선 ${e.id}: 자기 자신으로의 간선`);
    const key = `${e.source}|${e.type}|${e.target}`;
    if (keys.has(key)) err(mapId, `간선 중복 ${key}`);
    keys.add(key);
    if (e.type === "cause_of" && !CAUSALITY.includes(e.causality)) err(mapId, `간선 ${e.id}: Cause of 인과 유형 누락`);
    if (e.type !== "cause_of" && e.causality) err(mapId, `간선 ${e.id}: Cause of가 아닌데 인과 유형이 있음`);
    if (e.direction !== data.relations[e.type]?.direction) err(mapId, `간선 ${e.id}: 방향 표기 불일치`);
    for (const r of e.refs ?? []) if (!documents[r.doc]) err(mapId, `간선 ${e.id}: 문서 ${r.doc} 미정의`);
    if (e.type === "data_to_claim") {
      const s = byId.get(e.source), t = byId.get(e.target);
      if (s && s.kind !== "evidence") err(mapId, `간선 ${e.id}: Data → Claim 출발이 관찰 자료가 아님 (${s.kind})`);
      if (t && t.kind !== "claim") err(mapId, `간선 ${e.id}: Data → Claim 도착이 주장이 아님 (${t.kind})`);
      if (!["pending", "example"].includes(e.status)) err(mapId, `간선 ${e.id}: 실행 결과 없는 Data → Claim은 '검증 예정' 또는 '예시'여야 함`);
    }
    if (e.type === "cause_of") {
      const t = byId.get(e.target);
      if (t && ["concept", "example"].includes(t.kind) && !/이상|Read/.test(t.label))
        warn(mapId, `간선 ${e.id}: Cause of 도착이 일반 개념 노드 '${t.label}'`);
    }
  }

  // 3) 계층 순환 금지
  for (const type of ["type_of", "part_of"]) {
    const c = hasCycle(nodes, edges, type);
    if (c) err(mapId, `${type} 순환: ${c.join(" → ")}`);
  }

  // 4) 문제해결 경로 구조
  const has = (s, type, t) => edges.some((e) => e.source === s && e.type === type && e.target === t);
  for (const sc of scenarios) {
    const n = sc.nodes;
    for (const role of ["problem", "cause", "intervention", "mediator", "effect", "evidence", "claim"])
      if (!byId.has(n[role])) err(mapId, `경로 ${sc.id}: ${role} 노드 없음`);
    if (!has(n.cause, "cause_of", n.problem)) err(mapId, `경로 ${sc.id}: 원인 → Cause of → 문제 없음`);
    if (!has(n.intervention, "cause_of", n.mediator)) err(mapId, `경로 ${sc.id}: 개입 → Cause of → 원인 변화 없음`);
    if (!has(n.mediator, "cause_of", n.effect)) err(mapId, `경로 ${sc.id}: 원인 변화 → Cause of → 기대효과 없음`);
    if (!has(n.evidence, "data_to_claim", n.claim)) err(mapId, `경로 ${sc.id}: 관찰 자료 → Data → Claim → 주장 없음`);
    if (n.case && !has(n.case, "instance_of", n.problem)) err(mapId, `경로 ${sc.id}: 사례 → Instance of → 문제 없음`);
    if (n.category && !has(n.problem, "type_of", n.category)) err(mapId, `경로 ${sc.id}: 문제 → Type of → 문제 유형 없음`);
    for (const c of sc.concepts) if (!byId.has(c)) err(mapId, `경로 ${sc.id}: 관련 개념 ${c} 없음`);
    if (!areaIds.has(sc.area)) err(mapId, `경로 ${sc.id}: 알 수 없는 area`);
  }
  for (const m of data.mappings ?? [])
    for (const x of [m.design, ...m.impl]) if (!byId.has(x)) err(mapId, `대응 ${m.id}: 노드 ${x} 없음`);

  // 5) 관계 정확성 규칙 (작업 요청서 3절)
  const label = (id) => byId.get(id)?.label ?? id;
  const out = (id, type) => edges.filter((e) => e.source === id && (!type || e.type === type));
  const touching = (id, type) => edges.filter((e) => (e.source === id || e.target === id) && e.type === type);
  const rule = (ok, msg) => { if (!ok) err(mapId, `규칙 위반: ${msg}`); };
  // R1 WHERE는 SELECT문의 종류가 아니라 질의를 구성하는 절
  for (const n of nodes.filter((x) => /^WHERE ?절/.test(x.label) && x.kind === "concept")) {
    rule(!out(n.id, "type_of").some((e) => /SELECT/.test(label(e.target))), "WHERE가 SELECT의 Type of로 연결됨");
    if (byId.has("q_select")) rule(has(n.id, "part_of", "q_select"), "WHERE → Part of → SELECT문 간선 필요");
  }
  // R2 후보키는 슈퍼키의 일종
  if (byId.has("candidate")) rule(has("candidate", "type_of", "superkey"), "후보키 → Type of → 슈퍼키 간선 필요");
  // R3 함수적 종속은 인과관계가 아님
  const fdFamily = nodes.filter((x) => /^(fd|determinant|dependent|ex_fd_)/.test(x.id) || /함수적 종속/.test(x.label) && x.kind === "concept");
  for (const n of fdFamily) rule(touching(n.id, "cause_of").length === 0, `함수적 종속 관련 노드 '${n.label}'에 Cause of 간선이 있음`);
  // R4 정규화는 갱신 이상(이상 현상)의 종류가 아님
  const anomalyIds = new Set(nodes.filter((x) => /이상/.test(x.label) && x.kind === "concept").map((x) => x.id));
  for (const n of nodes.filter((x) => /정규화/.test(x.label) && x.kind === "concept"))
    rule(!out(n.id, "type_of").some((e) => anomalyIds.has(e.target)), `'${n.label}'가 이상 현상의 Type of로 연결됨`);
  // R5 DISTINCT는 원본 테이블의 저장 중복을 제거하지 않음
  const instOf = (target) => edges.filter((e) => e.type === "instance_of" && e.target === target).map((e) => e.source);
  if (byId.has("q_distinct")) {
    rule(out("q_distinct", "cause_of").length === 0, "DISTINCT에서 출발하는 Cause of 간선이 있음");
    for (const iv of instOf("q_distinct"))
      for (const e of out(iv, "cause_of")) {
        rule(!/저장|정규화|원본/.test(label(e.target)), `DISTINCT 적용 개입이 '${label(e.target)}'의 원인으로 연결됨`);
        for (const e2 of out(e.target, "cause_of")) rule(!/저장|정규화|원본/.test(label(e2.target)), `DISTINCT 경로가 '${label(e2.target)}'에 도달`);
      }
  }
  // R6 JOIN은 참조 무결성 위반을 자동으로 해결하지 않음
  const joinFamily = new Set(nodes.filter((x) => /JOIN|조인/.test(x.label) && x.kind === "concept").map((x) => x.id));
  for (const j of joinFamily) rule(out(j, "cause_of").length === 0, `JOIN 개념 '${label(j)}'에서 출발하는 Cause of 간선이 있음`);
  for (const iv of nodes.filter((x) => x.kind === "intervention")) {
    const cls = out(iv.id, "instance_of").map((e) => e.target);
    if (!cls.length || !cls.every((c) => joinFamily.has(c))) continue;
    for (const e of out(iv.id, "cause_of")) {
      rule(!/무결성/.test(label(e.target)), `JOIN만 적용한 개입이 '${label(e.target)}'의 원인으로 연결됨`);
      for (const e2 of out(e.target, "cause_of")) rule(!/무결성/.test(label(e2.target)), `JOIN만 적용한 경로가 '${label(e2.target)}'에 도달`);
    }
  }
  // R7 검증하지 않은 기대효과를 관측 결과처럼 표시하지 않음
  for (const n of nodes.filter((x) => x.kind === "outcome"))
    rule(!/(확인됨|관측됨|입증|측정 결과)/.test(n.label), `기대효과 '${n.label}'가 관측 결과처럼 표현됨`);
  for (const e of edges.filter((x) => x.type === "data_to_claim"))
    rule(["pending", "example"].includes(e.status), `Data → Claim ${e.id}가 실제 결과처럼 표시됨`);
  // R8 Instance of의 출발은 개별 사례여야 함(개념 범주 → 개념 범주 금지)
  for (const e of edges.filter((x) => x.type === "instance_of")) {
    const s = byId.get(e.source);
    if (s && ["category", "problem", "outcome", "mediator", "claim", "evidence"].includes(s.kind))
      err(mapId, `간선 ${e.id}: '${s.label}'(${s.kind})는 Instance of의 출발이 될 수 없음`);
  }
  // R9 Type of 양 끝의 종류 일치(개념끼리, 문제→문제 유형)
  for (const e of edges.filter((x) => x.type === "type_of")) {
    const s = byId.get(e.source), t = byId.get(e.target);
    const ok = (s.kind === "concept" && t.kind === "concept") || (s.kind === "problem" && ["category", "concept"].includes(t.kind)) ||
      (s.kind === "concept" && t.kind === "category");
    if (!ok) err(mapId, `간선 ${e.id}: Type of 양 끝 종류 불일치 (${s.kind} → ${t.kind})`);
  }

  // 6) 원본 대비 누락 검사
  const old = legacyData(legacy);
  const covered = new Set(scenarios.flatMap((s) => s.legacy));
  const missing = old.scenarios.filter((s) => !covered.has(s.id)).map((s) => s.id);
  if (missing.length) err(mapId, `원본 문제 경로 누락: ${missing.join(", ")}`);
  const corpus = [
    ...nodes.flatMap((n) => [n.label, n.def, n.note ?? "", ...(n.aliases ?? [])]),
    ...scenarios.flatMap((s) => [s.title, s.caveat ?? "", s.bridge ?? ""]),
    ...(data.mappings ?? []).flatMap((m) => [m.desc, m.limits]),
  ].join("\n").replace(/\s+/g, "");
  const terms = new Set();
  for (const s of old.scenarios)
    for (const f of ["p1", "p2"])
      for (const raw of String(s[f]).split(/[·/,，()]|\s+\/\s+|↔|→|\s및\s|\s+/))
        { const t = raw.trim().replace(/[\s'"*]/g, "").replace(/(으로|에서|과|와|의|로|을|를|은|는|이|가)$/, "");
          if (t.length >= 2 && !/^(등|구분|정의|관점|규칙|재검토|장단점|수단|적합성|차원|정책|원리|동일성)$/.test(t)) terms.add(t); }
  const missTerms = [...terms].filter((t) => !corpus.includes(t));
  if (missTerms.length) warn(mapId, `원본 개념 용어 중 새 데이터에서 찾지 못한 것 ${missTerms.length}/${terms.size}: ${missTerms.join(", ")}`, true);

  const counts = Object.fromEntries(RELATIONS.map((r) => [r, edges.filter((e) => e.type === r).length]));
  summary.push({ map: mapId, nodes: nodes.length, edges: edges.length, scenarios: scenarios.length,
    mappings: (data.mappings ?? []).length, legacyScenarios: old.scenarios.length, legacyCovered: old.scenarios.length - missing.length,
    termCoverage: `${terms.size - missTerms.length}/${terms.size}`, ...counts });
  console.log(`  ✓ 노드 ${nodes.length} · 간선 ${edges.length} · 문제 경로 ${scenarios.length} · 원본 경로 ${old.scenarios.length - missing.length}/${old.scenarios.length} 반영`);
}

console.log("\n요약");
console.table(summary);
console.log(`오류 ${errors}건 · 경고 ${warnings}건`);
if (VERBOSE) console.log("(--verbose)");
process.exit(errors ? 1 : 0);
