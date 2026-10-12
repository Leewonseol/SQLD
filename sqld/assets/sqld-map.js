/* SQLD 관계망 공통 뷰어 — 세 지도(1과목·대응·2과목)와 홈이 함께 쓴다.
 * 데이터: <body data-data="../data/NAME.json"> 를 fetch해서 그린다(상대경로 → 프로젝트 하위 경로에서도 동작).
 */
(() => {
  "use strict";

  const REL = ["type_of", "instance_of", "part_of", "cause_of", "data_to_claim"];
  const REL_LABEL = { type_of: "Type of", instance_of: "Instance of", part_of: "Part of", cause_of: "Cause of", data_to_claim: "Data → Claim" };
  const REL_GROUPS = [
    ["type_of", "out", "상위 개념 (Type of →)"], ["type_of", "in", "하위 개념 (← Type of)"],
    ["instance_of", "out", "속한 개념·유형 (Instance of →)"], ["instance_of", "in", "사례 (← Instance of)"],
    ["part_of", "out", "전체 (Part of →)"], ["part_of", "in", "구성 요소 (← Part of)"],
    ["cause_of", "in", "원인 (← Cause of)"], ["cause_of", "out", "결과·영향 (Cause of →)"],
    ["data_to_claim", "in", "근거 자료 (← Data → Claim)"], ["data_to_claim", "out", "뒷받침하는 주장 (Data → Claim →)"],
  ];
  const STATUS_LABEL = { confirmed: "출처 확인", derived: "정의상 도출", supplement: "보충(출처 외)", authored: "학습용 구성", inferred: "학습용 추론", pending: "검증 예정", example: "예시" };
  const BASIS_LABEL = { source: "출처 기반", supplement: "보충(출처 외)", authored: "학습용 작성" };
  const CAUSALITY_LABEL = { deterministic: "결정적", sufficient: "충분조건", necessary: "필요조건", probabilistic: "확률적·기여" };
  const SCOPES = [["core", "핵심 노드"], ["concepts", "개념 전체"], ["all", "개념 + 문제 경로 전체"]];
  const AREA_COLORS = ["#3b82c4", "#2f9e6e", "#c2782f", "#8a5cc7", "#c24f6b", "#1f9aa8", "#7f8f25", "#b0558f", "#4f6bd6", "#9a6b3f"];
  const SVGNS = "http://www.w3.org/2000/svg";
  const FONT = getComputedStyle(document.documentElement).getPropertyValue("--font") || "sans-serif";

  // ---------- 작은 DOM 도우미 ----------
  function h(tag, attrs, ...kids) {
    const el = document.createElement(tag);
    for (const [k, v] of Object.entries(attrs || {})) {
      if (v == null || v === false) continue;
      if (k === "class") el.className = v;
      else if (k === "text") el.textContent = v;
      else if (k.startsWith("on")) el.addEventListener(k.slice(2), v);
      else el.setAttribute(k, v === true ? "" : v);
    }
    for (const c of kids.flat(Infinity)) if (c != null && c !== false) el.append(c.nodeType ? c : document.createTextNode(String(c)));
    return el;
  }
  function s(tag, attrs, ...kids) {
    const el = document.createElementNS(SVGNS, tag);
    for (const [k, v] of Object.entries(attrs || {})) if (v != null) el.setAttribute(k, v);
    for (const c of kids.flat(Infinity)) if (c != null) el.append(c.nodeType ? c : document.createTextNode(String(c)));
    return el;
  }
  const flat = (kids) => kids.flat(Infinity).filter((c) => c != null && c !== false).map((c) => (c.nodeType ? c : document.createTextNode(String(c))));
  const setKids = (el, ...kids) => el.replaceChildren(...flat(kids));
  const addKids = (el, ...kids) => el.append(...flat(kids));
  const hash = (str) => { let x = 2166136261; for (let i = 0; i < str.length; i++) { x ^= str.charCodeAt(i); x = Math.imul(x, 16777619); } return x >>> 0; };
  const store = {
    get(k) { try { return localStorage.getItem(k); } catch { return null; } },
    set(k, v) { try { localStorage.setItem(k, v); } catch { /* 저장소를 쓸 수 없는 환경 */ } },
  };

  function relSwatch(type, w = 26) {
    const y = 7;
    const line = s("line", { x1: 1, y1: y, x2: w - 7, y2: y, class: "line" });
    const g = s("g", { class: `edge r-${type}` }, line);
    const svg = s("svg", { width: w, height: 14, viewBox: `0 0 ${w} 14`, "aria-hidden": "true" }, g);
    const tip = w - 7;
    if (type === "type_of") svg.append(s("path", { d: `M${tip} ${y - 4} L${w - 1} ${y} L${tip} ${y + 4} Z`, class: "mk-type_of" }));
    if (type === "instance_of") svg.append(s("path", { d: `M${tip - 1} ${y - 4} L${w - 1} ${y} L${tip - 1} ${y + 4}`, class: "mk-instance_of" }));
    if (type === "part_of") svg.append(s("path", { d: `M${tip - 3} ${y} L${tip + 1.5} ${y - 3.5} L${w} ${y} L${tip + 1.5} ${y + 3.5} Z`, class: "mk-part_of" }));
    if (type === "cause_of") svg.append(s("path", { d: `M${tip - 1} ${y - 4.5} L${w} ${y} L${tip - 1} ${y + 4.5} Z`, class: "mk-cause_of" }));
    if (type === "data_to_claim") svg.append(s("path", { d: `M${tip} ${y - 3.5} L${w - 1} ${y} L${tip} ${y + 3.5} Z`, class: "mk-data_to_claim" }));
    return svg;
  }

  // ---------- 테마 ----------
  function initTheme() {
    const saved = store.get("sqld-theme");
    if (saved === "light" || saved === "dark") document.documentElement.dataset.theme = saved;
    const btn = document.querySelector(".theme-btn");
    if (!btn) return;
    const label = () => { const t = document.documentElement.dataset.theme; btn.textContent = t === "dark" ? "다크" : t === "light" ? "라이트" : "자동"; btn.title = "화면 테마 전환(자동 → 라이트 → 다크)"; };
    label();
    btn.addEventListener("click", () => {
      const t = document.documentElement.dataset.theme;
      const next = !t ? "light" : t === "light" ? "dark" : "";
      if (next) document.documentElement.dataset.theme = next; else delete document.documentElement.dataset.theme;
      store.set("sqld-theme", next);
      label();
    });
  }

  // ---------- 텍스트 측정·줄바꿈 ----------
  const measureCtx = document.createElement("canvas").getContext("2d");
  function textWidth(t, weight = 600) { measureCtx.font = `${weight} 12px ${FONT}`; return measureCtx.measureText(t).width; }
  function wrapLabel(label, maxW = 168, maxLines = 2) {
    const words = label.split(/(?<=[\s·,/])/);
    const lines = [];
    let cur = "";
    for (const w of words) {
      if (textWidth(cur + w) <= maxW || !cur) { cur += w; continue; }
      lines.push(cur.trim()); cur = w;
    }
    if (cur) lines.push(cur.trim());
    // 아주 긴 단어는 글자 단위로 자른다
    const out = [];
    for (const ln of lines) {
      if (textWidth(ln) <= maxW) { out.push(ln); continue; }
      let c = "";
      for (const ch of ln) { if (textWidth(c + ch) > maxW && c) { out.push(c); c = ""; } c += ch; }
      if (c) out.push(c);
    }
    if (out.length > maxLines) { out.length = maxLines; let last = out[maxLines - 1]; while (textWidth(last + "…") > maxW && last.length > 1) last = last.slice(0, -1); out[maxLines - 1] = last + "…"; }
    return out;
  }

  // ---------- 배치(클러스터별 힘 기반 + 방향 편향) ----------
  function forceLayout(nodes, edges, center) {
    const n = nodes.length;
    if (!n) return;
    const idx = new Map(nodes.map((d, i) => [d.id, i]));
    const k = 74;
    const R = Math.sqrt(n) * 48;
    nodes.forEach((d) => {
      const a = ((hash(d.id) % 3600) / 3600) * Math.PI * 2;
      const r = R * (0.25 + 0.75 * ((hash(d.id + "#") % 1000) / 1000));
      d.x = Math.cos(a) * r; d.y = Math.sin(a) * r;
    });
    const E = edges.map((e) => [idx.get(e.source), idx.get(e.target), e.type]).filter(([a, b]) => a != null && b != null);
    if (center && idx.has(center)) {
      const ci = idx.get(center);
      nodes[ci].x = 0; nodes[ci].y = 0;
      const slots = { up: [], down: [], left: [], right: [] };
      for (const [a, b, t] of E) {
        const hier = t !== "cause_of" && t !== "data_to_claim";
        if (a === ci) slots[hier ? "up" : "right"].push(b);
        else if (b === ci) slots[hier ? "down" : "left"].push(a);
      }
      const place = (arr, fx, fy) => arr.forEach((j, i) => { const off = (i - (arr.length - 1) / 2); const p = fx(off); nodes[j].x = p[0]; nodes[j].y = p[1]; });
      place(slots.up, (o) => [o * 190, -170 - Math.abs(o) * 8]);
      place(slots.down, (o) => [o * 190, 170 + Math.abs(o) * 8]);
      place(slots.left, (o) => [-300, o * 70]);
      place(slots.right, (o) => [300, o * 70]);
    }
    const pinned = center && idx.has(center) ? idx.get(center) : -1;
    const rad = nodes.map((d) => Math.max(d.w * 0.8, d.h * 1.6) * 0.45);
    const iters = n > 120 ? 220 : 300;
    let temp = k * 2.2;
    const fx = new Float64Array(n), fy = new Float64Array(n);
    for (let it = 0; it < iters; it++) {
      fx.fill(0); fy.fill(0);
      for (let i = 0; i < n; i++) {
        const a = nodes[i];
        for (let j = i + 1; j < n; j++) {
          const b = nodes[j];
          let dx = a.x - b.x, dy = a.y - b.y;
          let d = Math.hypot(dx, dy);
          if (d < 0.01) { dx = (hash(a.id + b.id) % 7) - 3 || 1; dy = 1; d = Math.hypot(dx, dy); }
          const eff = Math.max(6, d - (rad[i] + rad[j]) * 0.7);
          const f = (k * k) / eff;
          const ux = dx / d, uy = dy / d;
          fx[i] += ux * f; fy[i] += uy * f; fx[j] -= ux * f; fy[j] -= uy * f;
        }
        fx[i] -= a.x * 3.2; fy[i] -= a.y * 4.2; // 중심 인력(세로를 더 강하게 → 가로로 넓은 클러스터)
      }
      for (const [si, ti, t] of E) {
        const a = nodes[si], b = nodes[ti];
        const dx = a.x - b.x, dy = a.y - b.y;
        const d = Math.max(0.01, Math.hypot(dx, dy));
        const L = k * 0.7 + (rad[si] + rad[ti]) * 0.5;
        const f = ((d - L) * Math.abs(d - L)) / k * 0.9;
        const ux = dx / d, uy = dy / d;
        fx[si] -= ux * f; fy[si] -= uy * f; fx[ti] += ux * f; fy[ti] += uy * f;
        if (t === "cause_of" || t === "data_to_claim") {
          const want = (a.w + b.w) / 2 + 40; const gap = b.x - a.x;
          if (gap < want) { const p = (want - gap) * 1.8; fx[ti] += p; fx[si] -= p; }
        } else {
          const want = 70; const gap = a.y - b.y; // 상위(도착)가 위쪽
          if (gap < want) { const p = (want - gap) * 1.8; fy[ti] -= p; fy[si] += p; }
        }
      }
      for (let i = 0; i < n; i++) {
        if (i === pinned) continue;
        const m = Math.hypot(fx[i], fy[i]);
        if (m > 0) { const st = Math.min(m, temp); nodes[i].x += (fx[i] / m) * st; nodes[i].y += (fy[i] / m) * st; }
      }
      temp = Math.max(1.5, temp * 0.982);
    }
    // 겹침 제거
    for (let pass = 0; pass < 60; pass++) {
      let moved = false;
      for (let i = 0; i < n; i++) for (let j = i + 1; j < n; j++) {
        const a = nodes[i], b = nodes[j];
        const dx = b.x - a.x, dy = b.y - a.y;
        const ox = (a.w + b.w) / 2 + 14 - Math.abs(dx);
        const oy = (a.h + b.h) / 2 + 12 - Math.abs(dy);
        if (ox > 0 && oy > 0) {
          moved = true;
          const wa = i === pinned ? 0 : j === pinned ? 1 : 0.5, wb = 1 - wa;
          if (ox < oy) { const sx = dx >= 0 ? 1 : -1; a.x -= sx * ox * wa; b.x += sx * ox * wb; }
          else { const sy = dy >= 0 ? 1 : -1; a.y -= sy * oy * wa; b.y += sy * oy * wb; }
        }
      }
      if (!moved) break;
    }
  }

  function packClusters(clusters) {
    const gap = 46, pad = 22, title = 30;
    for (const c of clusters) {
      let x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
      for (const d of c.nodes) { x0 = Math.min(x0, d.x - d.w / 2); y0 = Math.min(y0, d.y - d.h / 2); x1 = Math.max(x1, d.x + d.w / 2); y1 = Math.max(y1, d.y + d.h / 2); }
      c.w = Math.max(x1 - x0 + pad * 2, textWidth(c.label, 750) + pad * 2 + 10); c.h = y1 - y0 + pad * 2 + title;
      for (const d of c.nodes) { d.x += -x0 + pad; d.y += -y0 + pad + title; }
    }
    const total = clusters.reduce((a, c) => a + c.w * c.h, 0);
    const rowW = Math.max(1300, Math.sqrt(total) * 1.6);
    let x = 0, y = 0, rowH = 0;
    for (const c of clusters) {
      if (x > 0 && x + c.w > rowW) { x = 0; y += rowH + gap; rowH = 0; }
      c.x = x; c.y = y; x += c.w + gap; rowH = Math.max(rowH, c.h);
      for (const d of c.nodes) { d.x += c.x; d.y += c.y; }
    }
  }

  // ---------- 앱 ----------
  class MapApp {
    constructor(root, data) {
      this.root = root;
      this.d = data;
      this.nodes = new Map(data.nodes.map((n) => [n.id, n]));
      this.out = new Map(); this.inn = new Map();
      for (const e of data.edges) {
        (this.out.get(e.source) ?? this.out.set(e.source, []).get(e.source)).push(e);
        (this.inn.get(e.target) ?? this.inn.set(e.target, []).get(e.target)).push(e);
      }
      this.scenById = new Map(data.scenarios.map((sc) => [sc.id, sc]));
      this.scenByNode = new Map();
      for (const sc of data.scenarios) {
        for (const id of [...Object.values(sc.nodes), ...sc.concepts]) if (id) (this.scenByNode.get(id) ?? this.scenByNode.set(id, new Set()).get(id)).add(sc.id);
      }
      this.mapsByNode = new Map();
      for (const m of data.mappings ?? []) for (const id of [m.design, ...m.impl]) (this.mapsByNode.get(id) ?? this.mapsByNode.set(id, []).get(id)).push(m);
      this.areaColor = new Map(data.areas.map((a, i) => [a.id, AREA_COLORS[i % AREA_COLORS.length]]));
      this.areaLabel = new Map(data.areas.map((a) => [a.id, a.label]));
      const featured = data.scenarios.find((x) => x.featured) ?? data.scenarios[0];
      this.st = { view: "graph", rel: new Set(REL), area: "", scope: "core", sel: null, selEdge: null, focus: null, depth: 1, focusScen: null, q: "", scen: featured?.id, status: "" };
      this.readHash();
      this.build();
      window.addEventListener("hashchange", () => { if (this._writing) return; this.readHash(); this.syncControls(); this.renderView(); });
    }

    // ----- URL 상태 -----
    readHash() {
      const p = new URLSearchParams(location.hash.slice(1));
      const v = p.get("v");
      if (["graph", "paths", "table", "map"].includes(v) && (v !== "map" || this.d.mappings)) this.st.view = v;
      if (p.get("a") && this.areaLabel.has(p.get("a"))) this.st.area = p.get("a"); else if (p.has("v")) this.st.area = "";
      if (SCOPES.some(([k]) => k === p.get("sc"))) this.st.scope = p.get("sc");
      const n = p.get("n");
      this.st.sel = n && this.nodes.has(n) ? n : null;
      this.st.focus = p.get("f") === "1" && this.st.sel ? this.st.sel : null;
      this.st.depth = p.get("d") === "2" ? 2 : 1;
      const sc = p.get("s");
      if (sc && this.scenById.has(sc)) this.st.scen = sc;
      this.st.focusScen = p.get("fs") && this.scenById.has(p.get("fs")) ? p.get("fs") : null;
      const r = p.get("r");
      if (r) this.st.rel = new Set(r.split(",").filter((x) => REL.includes(x)));
    }
    writeHash() {
      const p = new URLSearchParams();
      p.set("v", this.st.view);
      if (this.st.area) p.set("a", this.st.area);
      if (this.st.view === "graph") {
        if (this.st.scope !== "core") p.set("sc", this.st.scope);
        if (this.st.sel) p.set("n", this.st.sel);
        if (this.st.focus) { p.set("f", "1"); if (this.st.depth === 2) p.set("d", "2"); }
        if (this.st.focusScen) p.set("fs", this.st.focusScen);
      }
      if (this.st.view === "paths" && this.st.scen) p.set("s", this.st.scen);
      if (this.st.rel.size !== REL.length) p.set("r", [...this.st.rel].join(","));
      const next = "#" + p.toString();
      if (next !== location.hash) { this._writing = true; history.replaceState(null, "", next); setTimeout(() => { this._writing = false; }, 0); }
    }

    // ----- 골격 -----
    build() {
      const d = this.d;
      const counts = REL.map((r) => d.edges.filter((e) => e.type === r).length);
      document.title = `${d.meta.title.split(" — ")[0]} · SQLD 관계망`;
      this.root.replaceChildren();
      this.root.append(
        h("div", { class: "page-head" },
          h("div", {}, h("h1", { text: d.meta.title }), h("p", { text: d.meta.subtitle })),
          h("div", { class: "stats" },
            h("span", { class: "chip" }, "노드 ", h("b", { text: d.nodes.length })),
            h("span", { class: "chip" }, "간선 ", h("b", { text: d.edges.length })),
            h("span", { class: "chip" }, "문제 경로 ", h("b", { text: d.scenarios.length })),
            d.mappings ? h("span", { class: "chip" }, "대응 ", h("b", { text: d.mappings.length })) : null,
            h("span", { class: "chip", title: REL.map((r, i) => `${REL_LABEL[r]} ${counts[i]}`).join(" · ") }, "관계별 ", h("b", { text: counts.join("·") })))),
      );
      const tabs = [["graph", "개념 관계망"], ["paths", "문제해결 경로"], ["table", "관계 목록"]];
      if (d.mappings) tabs.splice(2, 0, ["map", "설계 ↔ 구현 대응표"]);
      this.tabEls = {};
      const tabBar = h("div", { class: "tabs", role: "tablist", "aria-label": "보기 전환" },
        tabs.map(([k, label]) => (this.tabEls[k] = h("button", { role: "tab", id: `tab-${k}`, "aria-controls": "view", onclick: () => this.setView(k) }, label))));
      this.root.append(tabBar, this.buildToolbar(), (this.viewEl = h("section", { id: "view", role: "tabpanel" })));
      this.syncControls();
      this.renderView();
    }

    buildToolbar() {
      const icon = s("svg", { width: 15, height: 15, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": 2.2, "aria-hidden": "true" }, s("circle", { cx: 11, cy: 11, r: 7 }), s("path", { d: "M20 20l-3.5-3.5" }));
      this.qEl = h("input", { type: "search", placeholder: "개념·문제 검색 (예: 후보키, 갱신 이상, NULL)", "aria-label": "개념명·문제명 검색", autocomplete: "off", role: "combobox", "aria-expanded": "false", "aria-controls": "search-results" });
      this.resEl = h("div", { class: "search-results", id: "search-results", role: "listbox", hidden: true });
      this.qEl.addEventListener("input", () => { this.st.q = this.qEl.value.trim(); this.showResults(); this.onQuery(); });
      this.qEl.addEventListener("focus", () => { if (this.st.q) this.showResults(); });
      this.qEl.addEventListener("keydown", (ev) => {
        const items = [...this.resEl.querySelectorAll("button")];
        const cur = items.findIndex((b) => b.getAttribute("aria-selected") === "true");
        if (ev.key === "ArrowDown" || ev.key === "ArrowUp") {
          ev.preventDefault();
          const nx = ev.key === "ArrowDown" ? Math.min(items.length - 1, cur + 1) : Math.max(0, cur - 1);
          items.forEach((b, i) => b.setAttribute("aria-selected", i === nx ? "true" : "false"));
          items[nx]?.scrollIntoView({ block: "nearest" });
        } else if (ev.key === "Enter") { ev.preventDefault(); (items[cur] ?? items[0])?.click(); }
        else if (ev.key === "Escape") { this.resEl.hidden = true; this.qEl.setAttribute("aria-expanded", "false"); }
      });
      document.addEventListener("click", (ev) => { if (!ev.target.closest(".search")) { this.resEl.hidden = true; this.qEl.setAttribute("aria-expanded", "false"); } });

      this.areaEl = h("select", { "aria-label": "문제 영역 필터", onchange: () => { this.st.area = this.areaEl.value; this.st.focus = null; this.st.focusScen = null; this.renderView(); } },
        h("option", { value: "" }, "전체 영역"), this.d.areas.map((a) => h("option", { value: a.id }, a.label)));
      this.scopeEl = h("select", { "aria-label": "표시 범위", onchange: () => { this.st.scope = this.scopeEl.value; this.st.focus = null; this.st.focusScen = null; this.renderView(); } },
        SCOPES.map(([k, l]) => h("option", { value: k }, l)));
      this.statusEl = h("select", { "aria-label": "검증 상태 필터", onchange: () => { this.st.status = this.statusEl.value; this.renderView(); } },
        h("option", { value: "" }, "모든 검증 상태"), Object.entries(STATUS_LABEL).map(([k, l]) => h("option", { value: k }, l)));
      this.relEls = {};
      const rels = h("div", { class: "rel-toggles", role: "group", "aria-label": "관계 유형 표시·숨기기" },
        REL.map((r) => (this.relEls[r] = h("button", { class: "rel-toggle", type: "button", "aria-pressed": "true", title: `${REL_LABEL[r]} 간선 표시·숨기기 — ${this.d.relations[r].meaning}`,
          onclick: () => { if (this.st.rel.has(r)) this.st.rel.delete(r); else this.st.rel.add(r); this.syncControls(); this.onRelChange(); } }, relSwatch(r), REL_LABEL[r]))));
      this.ctlScope = h("label", { class: "ctl" }, "범위", this.scopeEl);
      this.ctlStatus = h("label", { class: "ctl" }, "상태", this.statusEl);
      this.ctlRels = rels;
      return h("div", { class: "toolbar" }, h("div", { class: "search" }, icon, this.qEl, this.resEl), h("label", { class: "ctl" }, "영역", this.areaEl), this.ctlScope, this.ctlStatus, rels);
    }

    syncControls() {
      for (const [k, el] of Object.entries(this.tabEls)) el.setAttribute("aria-selected", k === this.st.view ? "true" : "false");
      this.areaEl.value = this.st.area;
      this.scopeEl.value = this.st.scope;
      this.statusEl.value = this.st.status;
      for (const r of REL) this.relEls[r].setAttribute("aria-pressed", this.st.rel.has(r) ? "true" : "false");
      this.ctlScope.hidden = this.st.view !== "graph";
      this.ctlStatus.hidden = this.st.view !== "table";
      this.ctlRels.hidden = !["graph", "table"].includes(this.st.view);
    }

    setView(v) { this.st.view = v; this.syncControls(); this.renderView(); }

    renderView() {
      this.syncControls();
      this.writeHash();
      this.viewEl.replaceChildren();
      this.viewEl.setAttribute("aria-labelledby", `tab-${this.st.view}`);
      this.graph = null;
      if (this.st.view === "graph") this.renderGraphView();
      else if (this.st.view === "paths") this.renderPaths();
      else if (this.st.view === "table") this.renderTable();
      else if (this.st.view === "map") this.renderMappings();
    }

    // ----- 검색 -----
    matches(q) {
      const ql = q.toLocaleLowerCase();
      const res = [];
      for (const n of this.d.nodes) {
        const l = n.label.toLocaleLowerCase();
        let score = l === ql ? 0 : l.startsWith(ql) ? 1 : l.includes(ql) ? 2 : (n.aliases ?? []).some((a) => a.toLocaleLowerCase().includes(ql)) ? 2.5 : n.def.toLocaleLowerCase().includes(ql) ? 4 : -1;
        if (score < 0) continue;
        if (["concept", "example"].includes(n.kind)) score -= 0.5;
        res.push({ type: "node", id: n.id, label: n.label, kind: this.d.kinds[n.kind], score });
      }
      for (const sc of this.d.scenarios) {
        const t = `${sc.id} ${sc.title}`.toLocaleLowerCase();
        if (t.includes(ql)) res.push({ type: "scen", id: sc.id, label: `${sc.id} ${sc.title}`, kind: "문제 경로", score: 1.5 });
      }
      return res.sort((a, b) => a.score - b.score || a.label.length - b.label.length);
    }
    showResults() {
      const q = this.st.q;
      this.resEl.replaceChildren();
      if (!q) { this.resEl.hidden = true; this.qEl.setAttribute("aria-expanded", "false"); return; }
      const res = this.matches(q).slice(0, 14);
      if (!res.length) this.resEl.append(h("div", { class: "empty" }, "일치하는 개념·문제가 없습니다."));
      res.forEach((r, i) => this.resEl.append(h("button", { type: "button", role: "option", "aria-selected": i === 0 ? "true" : "false",
        onclick: () => { this.resEl.hidden = true; this.qEl.setAttribute("aria-expanded", "false"); if (r.type === "node") this.goNode(r.id, true); else this.goScenario(r.id); } },
        h("span", { class: "k", text: r.kind }), h("span", { text: r.label }))));
      this.resEl.hidden = false;
      this.qEl.setAttribute("aria-expanded", "true");
    }
    onQuery() {
      if (this.st.view === "graph" && this.graph) this.graph.highlightMatches(this.st.q ? new Set(this.matches(this.st.q).filter((r) => r.type === "node").map((r) => r.id)) : null);
      else if (this.st.view === "paths") this.renderScenList();
      else if (this.st.view === "table") this.renderTableRows();
      else if (this.st.view === "map") this.renderMappings();
    }

    // ----- 이동 -----
    goNode(id, focus = false) {
      this.st.view = "graph";
      this.st.sel = id; this.st.selEdge = null; this.st.focusScen = null;
      const visible = this.visibleNodeIds(true);
      if (focus || !visible.has(id)) this.st.focus = id;
      this.renderView();
    }
    goScenario(id) { this.st.view = "paths"; this.st.scen = id; this.renderView(); }

    // ----- 그래프 보기 -----
    visibleNodeIds(ignoreFocus = false) {
      const st = this.st;
      if (!ignoreFocus && st.focusScen) {
        const sc = this.scenById.get(st.focusScen);
        const ids = new Set(Object.values(sc.nodes).filter(Boolean));
        for (const e of this.d.edges) if (e.scenarios?.includes(sc.id)) { ids.add(e.source); ids.add(e.target); }
        return ids;
      }
      if (!ignoreFocus && st.focus) {
        const ids = new Set([st.focus]);
        let frontier = [st.focus];
        for (let dpt = 0; dpt < st.depth; dpt++) {
          const next = [];
          for (const id of frontier) for (const e of [...(this.out.get(id) ?? []), ...(this.inn.get(id) ?? [])]) {
            if (!st.rel.has(e.type)) continue;
            const o = e.source === id ? e.target : e.source;
            if (!ids.has(o)) { ids.add(o); next.push(o); }
          }
          frontier = next;
        }
        return ids;
      }
      const ids = new Set();
      for (const n of this.d.nodes) {
        if (st.area && n.area !== st.area) continue;
        if (st.scope === "core" && !n.core) continue;
        if (st.scope === "concepts" && !["concept", "example"].includes(n.kind)) continue;
        ids.add(n.id);
      }
      return ids;
    }

    renderGraphView() {
      const wrap = h("div", { class: "graph-wrap" });
      this.detailEl = h("aside", { class: "panel-card detail", "aria-live": "polite", "aria-label": "선택한 노드 정보" });
      this.viewEl.append(h("div", { class: "workspace" }, wrap, this.detailEl));
      const ids = this.visibleNodeIds();
      const nodes = [...ids].map((id) => this.nodes.get(id));
      const edges = this.d.edges.filter((e) => ids.has(e.source) && ids.has(e.target));
      this.graph = new GraphView(this, wrap, nodes, edges);
      if (this.st.q) this.graph.highlightMatches(new Set(this.matches(this.st.q).filter((r) => r.type === "node").map((r) => r.id)));
      this.renderBanner();
      if (this.st.sel && ids.has(this.st.sel)) { this.graph.select(this.st.sel, false); this.renderDetail(this.st.sel); }
      else { this.st.sel = null; this.renderPlaceholder(); }
    }

    renderBanner() {
      const b = this.graph.banner;
      b.replaceChildren();
      const st = this.st;
      if (st.focusScen) {
        const sc = this.scenById.get(st.focusScen);
        b.append(h("div", { class: "banner" }, h("span", {}, "문제 경로 ", h("b", { text: `${sc.id} ${sc.title}` }), "의 노드만 표시"),
          h("button", { type: "button", onclick: () => { st.focusScen = null; this.renderView(); } }, "전체 보기")));
      } else if (st.focus) {
        const n = this.nodes.get(st.focus);
        b.append(h("div", { class: "banner" }, h("span", {}, "집중 보기: ", h("b", { text: n.label }), ` 주변 ${st.depth}단계`),
          h("button", { type: "button", onclick: () => { st.depth = st.depth === 1 ? 2 : 1; this.renderView(); } }, st.depth === 1 ? "2단계로 확장" : "1단계로 축소"),
          h("button", { type: "button", onclick: () => { st.focus = null; this.renderView(); } }, "집중 해제")));
      } else {
        const cnt = this.graph.nodes.length;
        const scopeLabel = SCOPES.find(([k]) => k === st.scope)[1];
        b.append(h("div", { class: "banner" }, h("span", {}, `${scopeLabel} · ${st.area ? this.areaLabel.get(st.area) : "전체 영역"} · 노드 ${cnt}개`),
          st.scope !== "all" ? h("button", { type: "button", onclick: () => { st.scope = st.scope === "core" ? "concepts" : "all"; this.renderView(); } }, st.scope === "core" ? "개념 전체로 확장" : "문제 경로까지 확장") : null));
      }
    }

    onRelChange() {
      this.writeHash();
      if (this.st.view === "graph") {
        if (this.st.focus || this.st.focusScen) this.renderView();
        else { this.graph.applyRelVisibility(); if (this.st.sel) this.graph.select(this.st.sel, false); }
      } else if (this.st.view === "table") this.renderTableRows();
    }

    select(id) {
      this.st.sel = id; this.st.selEdge = null;
      this.writeHash();
      if (this.graph) this.graph.select(id, false);
      if (id) this.renderDetail(id); else this.renderPlaceholder();
    }

    renderPlaceholder() {
      const el = this.detailEl;
      if (!el) return;
      setKids(el,
        h("p", { class: "placeholder" }, "노드를 누르면 정의·원인·관련 개념·참조 문서를 확인할 수 있습니다. 노드를 두 번 누르거나 ‘집중 보기’를 누르면 연결된 노드만 남깁니다."),
        h("h3", {}, "선 모양 = 관계 유형"),
        h("ul", { class: "rel-list" }, REL.map((r) => h("li", {}, h("span", { class: "relcell" }, relSwatch(r, 34), REL_LABEL[r]), " ", h("span", { class: "why", style: "padding:0" }, `${this.d.relations[r].direction}: ${this.d.relations[r].meaning}`)))),
        h("h3", {}, "노드 종류"),
        h("div", { class: "badges" }, Object.entries(this.d.kinds).filter(([k]) => this.d.nodes.some((n) => n.kind === k)).map(([k, l]) => h("span", { class: `badge` }, kindDot(k), l))),
        h("h3", {}, "영역 색"),
        h("div", { class: "badges" }, this.d.areas.map((a) => h("span", { class: "badge" }, h("span", { style: `display:inline-block;width:8px;height:8px;border-radius:2px;background:${this.areaColor.get(a.id)}` }), a.label))),
        h("div", { class: "note info" }, "문제와 해결책은 여섯 번째 간선으로 잇지 않습니다. ‘원인 → Cause of → 문제’와 ‘개입 → Cause of → 원인 변화 → Cause of → 기대효과’를 나란히 보려면 ‘문제해결 경로’ 탭을 여세요."),
        h("div", { class: "note" }, "Data → Claim의 관찰 자료는 모두 ‘검증 예정’ 또는 ‘예시’입니다. 실제 실행 결과가 아닙니다."),
      );
    }

    nodeLink(id, extra) {
      const n = this.nodes.get(id);
      return h("button", { type: "button", class: "nodelink", onclick: () => this.goNode(id), title: n.def }, n.label, extra ?? null);
    }
    statusBadge(st) { return h("span", { class: `badge st-${st}`, title: this.d.statuses[st] }, STATUS_LABEL[st]); }
    refList(refs) {
      return h("ul", { class: "refs" }, refs.map((r) => {
        const doc = this.d.documents[r.doc];
        const prov = doc.provided === false ? " · 이번 작업에 미제공(대조 안 됨)" : "";
        return h("li", { title: doc.note ?? "" }, `${doc.title}${r.sec ? ` ${r.sec}절` : ""}${prov}`);
      }));
    }

    renderDetail(id) {
      const n = this.nodes.get(id);
      const el = this.detailEl;
      const scen = [...(this.scenByNode.get(id) ?? [])].map((x) => this.scenById.get(x));
      setKids(el,
        h("div", { class: "badges" },
          h("span", { class: "badge" }, kindDot(n.kind), this.d.kinds[n.kind]),
          h("span", { class: "badge" }, n.subject),
          h("span", { class: "badge" }, h("span", { style: `display:inline-block;width:8px;height:8px;border-radius:2px;background:${this.areaColor.get(n.area)}` }), this.areaLabel.get(n.area)),
          h("span", { class: `badge st-${n.basis === "source" ? "confirmed" : n.basis === "supplement" ? "supplement" : "authored"}` }, BASIS_LABEL[n.basis])),
        h("h2", { text: n.label }),
        h("p", { text: n.def }),
        n.note ? h("div", { class: "note" }, n.note) : null,
        h("div", { class: "btnrow" },
          h("button", { type: "button", class: "btn primary", onclick: () => { this.st.focus = id; this.st.focusScen = null; this.renderView(); } }, this.st.focus === id ? "집중 보기 중" : "집중 보기"),
          this.graph ? h("button", { type: "button", class: "btn", onclick: () => this.graph.centerOn(id) }, "그래프에서 위치") : null,
          h("button", { type: "button", class: "btn", onclick: () => this.select(null) }, "선택 해제")),
      );
      const groups = [];
      for (const [type, dir, title] of REL_GROUPS) {
        const list = (dir === "out" ? this.out.get(id) : this.inn.get(id))?.filter((e) => e.type === type) ?? [];
        if (!list.length) continue;
        groups.push(h("div", { class: "rel-group" },
          h("div", { class: "rg-title" }, relSwatch(type), title, h("span", { class: "chip" }, list.length)),
          h("ul", { class: "rel-list" }, list.map((e) => {
            const other = dir === "out" ? e.target : e.source;
            return h("li", {}, h("details", {},
              h("summary", {}, this.nodeLink(other), this.statusBadge(e.status), e.causality ? h("span", { class: "badge", title: this.d.causality[e.causality] }, CAUSALITY_LABEL[e.causality]) : null),
              h("div", { class: "why" }, e.why, h("br"), h("span", { text: `근거: ${e.refs.map((r) => `${this.d.documents[r.doc].title}${r.sec ? " " + r.sec + "절" : ""}`).join(" · ")}` }), ` · ${e.id}`)));
          }))));
      }
      addKids(el, h("h3", {}, "관계 탐색"), groups.length ? groups : h("p", { class: "placeholder" }, "다섯 관계로 연결된 노드가 없습니다. 연결 정보는 설명에 기록했습니다."));
      const maps = this.mapsByNode.get(id);
      if (maps?.length) {
        addKids(el, h("h3", {}, "설계 ↔ 구현 대응 (간선 아님)"), h("ul", { class: "rel-list" }, maps.map((m) => h("li", {}, h("details", {},
          h("summary", {}, h("b", { text: `${m.id} · ${m.function}` }), " ", this.nodeLink(m.design), " ↔ ", m.impl.map((x, i) => [i ? ", " : "", this.nodeLink(x)])),
          h("div", { class: "why" }, m.desc, h("br"), `한계: ${m.limits}`))))));
      }
      if (scen.length) {
        addKids(el, h("h3", {}, `관련 문제 경로 (${scen.length})`), h("div", { class: "scen-links" }, scen.map((sc) => {
          const role = Object.entries(sc.nodes).find(([, v]) => v === id)?.[0];
          return h("div", {}, h("button", { type: "button", class: "nodelink", onclick: () => this.goScenario(sc.id) }, `${sc.id} ${sc.title}`), " ", h("span", { class: "badge" }, role ? roleLabel(role) : "관련 개념"));
        })));
      }
      addKids(el, h("h3", {}, "참조 문서"), this.refList(n.refs));
      el.scrollTop = 0;
    }

    renderEdgeDetail(e) {
      const el = this.detailEl;
      setKids(el,
        h("div", { class: "badges" }, h("span", { class: "badge" }, relSwatch(e.type), REL_LABEL[e.type]), this.statusBadge(e.status),
          e.causality ? h("span", { class: "badge", title: this.d.causality[e.causality] }, CAUSALITY_LABEL[e.causality]) : null),
        h("h2", {}, this.nodeLink(e.source), " → ", this.nodeLink(e.target)),
        h("dl", { class: "kv" }, h("dt", {}, "방향"), h("dd", {}, e.direction), h("dt", {}, "의미"), h("dd", {}, this.d.relations[e.type].meaning),
          h("dt", {}, "근거"), h("dd", {}, e.why), h("dt", {}, "검증 상태"), h("dd", {}, this.d.statuses[e.status]),
          e.causality ? [h("dt", {}, "인과 유형"), h("dd", {}, this.d.causality[e.causality])] : null,
          e.scenarios ? [h("dt", {}, "문제 경로"), h("dd", {}, e.scenarios.map((x, i) => [i ? ", " : "", h("button", { type: "button", class: "nodelink", onclick: () => this.goScenario(x) }, x)]))] : null,
          h("dt", {}, "간선 ID"), h("dd", {}, e.id)),
        h("h3", {}, "출처"), this.refList(e.refs));
    }

    // ----- 문제해결 경로 -----
    filteredScenarios() {
      const q = this.st.q.toLocaleLowerCase();
      return this.d.scenarios.filter((sc) => {
        if (this.st.area && sc.area !== this.st.area) return false;
        if (!q) return true;
        const text = [sc.id, sc.title, ...Object.values(sc.nodes).filter(Boolean).map((id) => this.nodes.get(id).label), ...sc.concepts.map((id) => this.nodes.get(id).label)].join(" ").toLocaleLowerCase();
        return text.includes(q);
      });
    }
    renderPaths() {
      this.scenListEl = h("nav", { class: "panel-card scen-list", "aria-label": "문제 경로 목록" });
      this.scenDetailEl = h("article", { class: "panel-card scen-detail" });
      this.viewEl.append(h("div", { class: "paths" }, this.scenListEl, this.scenDetailEl));
      this.renderScenList();
    }
    renderScenList() {
      const list = this.filteredScenarios();
      const el = this.scenListEl;
      setKids(el);
      if (!list.length) addKids(el, h("p", { class: "placeholder", style: "padding:8px" }, "조건에 맞는 문제 경로가 없습니다."));
      let last = null;
      for (const sc of list) {
        if (sc.area !== last) { addKids(el, h("div", { class: "grp", text: this.areaLabel.get(sc.area) })); last = sc.area; }
        addKids(el, h("button", { type: "button", "aria-current": sc.id === this.st.scen ? "true" : "false", onclick: () => { this.st.scen = sc.id; this.renderScenList(); this.writeHash(); } },
          h("span", { class: "sid", text: sc.id }), h("span", { text: sc.title }), sc.featured ? h("span", { class: "badge", title: "초기 화면 핵심 경로" }, "핵심") : null));
      }
      if (list.length && !list.some((sc) => sc.id === this.st.scen)) this.st.scen = list[0].id;
      el.querySelector('[aria-current="true"]')?.scrollIntoView({ block: "nearest" });
      this.renderScenario(this.st.scen);
    }
    pcard(id, role, extraClass = "") {
      if (!id) return h("div", { class: "gap" });
      const n = this.nodes.get(id);
      return h("button", { type: "button", class: `pcard k-${n.kind} ${extraClass}`, title: `${n.def}\n(그래프에서 보기)`, onclick: () => this.goNode(id, true) },
        h("span", { class: "role", text: role }), n.label);
    }
    arrow(type, sid, src, tgt) {
      const e = (this.out.get(src) ?? []).find((x) => x.target === tgt && x.type === type);
      const box = h("div", { class: `arrow r-${type}`, title: e ? `${e.why} [${STATUS_LABEL[e.status]}${e.causality ? " · " + CAUSALITY_LABEL[e.causality] : ""}]` : "" },
        h("span", { text: REL_LABEL[type] }), relSwatch(type, 60));
      if (e) box.append(h("span", { class: `badge st-${e.status}`, style: "font-size:10px;padding:0 4px" }, STATUS_LABEL[e.status]));
      return box;
    }
    renderScenario(id) {
      const el = this.scenDetailEl;
      setKids(el);
      const sc = this.scenById.get(id);
      if (!sc) return;
      const N = sc.nodes;
      const sideNode = N.side ? this.nodes.get(N.side) : null;
      const causalNote = (part, title) => {
        const c = sc.causal[part];
        return h("div", { class: "note info" }, h("b", { text: `${title} · ${CAUSALITY_LABEL[c.causality]}` }), h("br"), c.note ?? this.d.causality[c.causality]);
      };
      addKids(el, 
        h("div", { class: "badges" }, h("span", { class: "badge" }, sc.id), h("span", { class: "badge" }, h("span", { style: `display:inline-block;width:8px;height:8px;border-radius:2px;background:${this.areaColor.get(sc.area)}` }), this.areaLabel.get(sc.area)),
          sc.legacy.length ? h("span", { class: "badge", title: "리팩터링 전 원본 경로 ID" }, `원본 ${sc.legacy.join("·")}`) : h("span", { class: "badge" }, "신규 경로")),
        h("h2", { text: sc.title }),
        sc.bridge ? h("div", { class: "note info" }, h("b", {}, "설계 ↔ 구현 연결: "), sc.bridge) : null,
        h("div", { class: "colhead", "aria-hidden": "true" }, h("span", {}, "개입"), h("span"), h("span", {}, "원인 ↕ 원인 변화"), h("span"), h("span", {}, "문제 ↕ 기대효과")),
        h("div", { class: "lanes" },
          h("section", { class: "lane problem", "aria-label": "문제 발생 경로" },
            h("div", { class: "lane-title" }, "① 문제 발생 경로", h("span", { class: "badge" }, "원인 → Cause of → 문제")),
            h("div", { class: "lane-grid" }, h("div", { class: "gap" }), h("div", { class: "gap" }), this.pcard(N.cause, "원인"), this.arrow("cause_of", sc.id, N.cause, N.problem), this.pcard(N.problem, "문제", "as-problem")),
            h("div", { class: "lane-sub" },
              N.case ? [h("span", {}, "사례: "), this.nodeLink(N.case), h("span", { class: "relcell" }, relSwatch("instance_of"), "Instance of → 문제")] : null,
              N.category ? [h("span", {}, " · 문제 유형: "), h("span", { class: "relcell" }, "문제 ", relSwatch("type_of"), "Type of →"), this.nodeLink(N.category)] : null)),
          h("section", { class: "lane solution", "aria-label": "문제 해결 경로" },
            h("div", { class: "lane-title" }, "② 문제 해결 경로", h("span", { class: "badge" }, "개입 → Cause of → 원인 변화 → Cause of → 기대효과")),
            h("div", { class: "lane-grid" }, this.pcard(N.intervention, "개입"), this.arrow("cause_of", sc.id, N.intervention, N.mediator), this.pcard(N.mediator, "원인 변화"), this.arrow("cause_of", sc.id, N.mediator, N.effect), this.pcard(N.effect, "기대효과(관측 아님)")),
            h("div", { class: "lane-sub" },
              (this.out.get(N.intervention) ?? []).filter((e) => e.type === "instance_of").map((e) => [h("span", { class: "relcell" }, "개입 ", relSwatch("instance_of"), "Instance of →"), this.nodeLink(e.target), " "]),
              sideNode ? [h("span", { class: "relcell" }, "부수효과 ", relSwatch("cause_of"), "Cause of →"), this.nodeLink(N.side)] : null)),
          h("section", { class: "lane data", "aria-label": "검증 자료와 주장" },
            h("div", { class: "lane-title" }, "③ 검증", h("span", { class: `badge st-${sc.claimStatus}` }, STATUS_LABEL[sc.claimStatus]), h("span", { class: "badge" }, "관찰 자료 → Data → Claim → 주장")),
            h("div", { class: "lane-grid" }, this.pcard(N.evidence, sc.claimStatus === "pending" ? "관찰 자료(검증 예정)" : "강의 예시 값"), this.arrow("data_to_claim", sc.id, N.evidence, N.claim), this.pcard(N.claim, "주장"), h("div", { class: "gap" }), h("div", { class: "gap" })))),
        h("div", { class: "causal" }, causalNote("problem", "문제 발생 인과"), causalNote("solution", "개입 효과 인과")),
        sc.caveat ? h("div", { class: "note warn" }, h("b", {}, "주의: "), sc.caveat) : null,
        h("div", { class: "note" }, "원인을 제거·변경해도 문제가 완전히 사라진다고 단정하지 않습니다. 기대효과는 관측 결과가 아니며, 위의 ‘검증’ 단계에서 자료를 확보해야 주장이 뒷받침됩니다."),
        h("h3", {}, "관련 개념 (간선이 아닌 참조)"),
        h("div", { class: "concept-chips" }, sc.concepts.map((cid) => h("button", { type: "button", title: this.nodes.get(cid).def, onclick: () => this.goNode(cid) }, this.nodes.get(cid).label))),
        h("div", { class: "btnrow" }, h("button", { type: "button", class: "btn primary", onclick: () => { this.st.view = "graph"; this.st.focusScen = sc.id; this.st.focus = null; this.st.sel = N.problem; this.renderView(); } }, "이 경로를 그래프로 보기")),
        h("h3", {}, "참조 문서"), this.refList(sc.refs),
      );
    }

    // ----- 관계 목록 -----
    filteredEdges() {
      const q = this.st.q.toLocaleLowerCase();
      return this.d.edges.filter((e) => {
        if (!this.st.rel.has(e.type)) return false;
        if (this.st.status && e.status !== this.st.status) return false;
        const a = this.nodes.get(e.source), b = this.nodes.get(e.target);
        if (this.st.area && a.area !== this.st.area && b.area !== this.st.area) return false;
        if (q && !`${a.label} ${b.label} ${e.why} ${e.id}`.toLocaleLowerCase().includes(q)) return false;
        return true;
      });
    }
    renderTable() {
      this.tbody = h("tbody");
      this.tableFoot = h("div", { class: "table-foot" });
      this.viewEl.append(h("div", { class: "panel-card" },
        h("div", { class: "table-wrap" }, h("table", { class: "data" },
          h("caption", { class: "sr-only" }, "다섯 관계 간선 목록"),
          h("thead", {}, h("tr", {}, ["ID", "출발 노드", "관계", "도착 노드", "근거·설명", "인과 유형", "출처", "검증 상태"].map((t) => h("th", { scope: "col" }, t)))),
          this.tbody)), this.tableFoot));
      this.tableLimit = 200;
      this.renderTableRows();
    }
    renderTableRows() {
      const rows = this.filteredEdges();
      this.tbody.replaceChildren(...rows.slice(0, this.tableLimit).map((e) => h("tr", {},
        h("td", { class: "id", text: e.id }), h("td", {}, this.nodeLink(e.source)),
        h("td", {}, h("span", { class: "relcell", title: e.direction }, relSwatch(e.type), REL_LABEL[e.type])),
        h("td", {}, this.nodeLink(e.target)), h("td", { class: "why", text: e.why }),
        h("td", { text: e.causality ? CAUSALITY_LABEL[e.causality] : "—" }),
        h("td", { text: e.refs.map((r) => `${r.doc}${r.sec ? " " + r.sec : ""}`).join(", "), title: e.refs.map((r) => this.d.documents[r.doc].title).join(" / ") }),
        h("td", {}, this.statusBadge(e.status)))));
      setKids(this.tableFoot, h("span", {}, `${rows.length}개 간선 중 ${Math.min(rows.length, this.tableLimit)}개 표시`),
        rows.length > this.tableLimit ? h("button", { type: "button", class: "btn", onclick: () => { this.tableLimit += 300; this.renderTableRows(); } }, "더 보기") : null,
        h("span", {}, "출처 약어: ", Object.entries(this.d.documents).map(([k, v]) => `${k}=${v.title}`).join(" · ")));
    }

    // ----- 대응표 -----
    renderMappings() {
      const q = this.st.q.toLocaleLowerCase();
      const list = this.d.mappings.filter((m) => (!this.st.area || m.area === this.st.area) &&
        (!q || [m.id, m.function, m.desc, m.limits, ...[m.design, ...m.impl].map((x) => this.nodes.get(x).label)].join(" ").toLocaleLowerCase().includes(q)));
      setKids(this.viewEl,
        h("div", { class: "note info", style: "margin-top:0" }, "대응은 다섯 관계가 아니므로 그래프 간선으로 그리지 않고 여기와 노드 설명에만 기록합니다. ‘기능’은 2과목 기능이 1과목 원리에 대해 하는 일(구현·집행·조회 등)을 뜻합니다."),
        list.length ? h("div", { class: "map-cards" }, list.map((m) => h("article", { class: "panel-card map-card" },
          h("div", { class: "badges" }, h("span", { class: "badge" }, m.id), h("span", { class: "badge" }, this.areaLabel.get(m.area)), this.statusBadge(m.status)),
          h("div", { class: "flow" },
            h("div", { class: "side" }, h("small", {}, "1과목 설계 원리"), this.nodeLink(m.design)),
            h("div", { class: "fn", text: `— ${m.function} →` }),
            h("div", { class: "side" }, h("small", {}, "2과목 구현·처리"), m.impl.map((x, i) => [i ? ", " : "", this.nodeLink(x)]))),
          h("p", { text: m.desc }), h("p", { class: "lim" }, h("b", {}, "한계: "), m.limits),
          h("p", { class: "lim" }, "출처: ", m.refs.map((r) => `${this.d.documents[r.doc].title}${r.sec ? " " + r.sec + "절" : ""}`).join(" · "))))) :
          h("p", { class: "placeholder" }, "조건에 맞는 대응이 없습니다."));
    }
  }

  function kindDot(kind) {
    const colors = { concept: "var(--line-strong)", example: "var(--line-strong)", category: "var(--k-problem-line)", problem: "var(--k-problem-line)", instance: "var(--k-problem-line)",
      cause: "var(--k-cause-line)", intervention: "var(--k-solution-line)", mediator: "var(--k-outcome-line)", outcome: "var(--k-outcome-line)", side: "var(--s-supplement)", evidence: "var(--k-data-line)", claim: "var(--k-data-line)" };
    return h("span", { style: `display:inline-block;width:9px;height:9px;border-radius:3px;border:2px solid ${colors[kind]}` });
  }
  function roleLabel(role) { return { category: "문제 유형", problem: "문제", case: "사례", cause: "원인", intervention: "개입", mediator: "원인 변화", effect: "기대효과", evidence: "관찰 자료", claim: "주장", side: "부수효과" }[role] ?? role; }

  // ---------- 그래프 뷰 ----------
  class GraphView {
    constructor(app, wrap, nodes, edges) {
      this.app = app; this.wrap = wrap;
      this.nodes = nodes.map((n) => {
        const lines = wrapLabel(n.label);
        const w = Math.max(...lines.map((l) => textWidth(l, n.core ? 700 : 600))) + 26;
        return { id: n.id, n, lines, w: Math.max(54, w), h: lines.length === 1 ? 28 : 44 };
      });
      this.byId = new Map(this.nodes.map((d) => [d.id, d]));
      this.edges = edges;
      this.layout();
      this.render();
      this.fit();
    }

    layout() {
      const st = this.app.st;
      const key = `${this.app.d.meta.id}|${st.focusScen || ""}|${st.focus || ""}|${st.depth}|${st.area}|${st.scope}|${st.focus || st.focusScen ? [...st.rel].join(",") : ""}`;
      const cache = (GraphView.cache ??= new Map());
      if (cache.has(key)) {
        const pos = cache.get(key);
        this.clusters = pos.clusters;
        for (const d of this.nodes) Object.assign(d, pos.nodes.get(d.id));
        return;
      }
      if (st.focus || st.focusScen) {
        const center = st.focus ?? this.app.scenById.get(st.focusScen).nodes.problem;
        forceLayout(this.nodes, this.edges, center);
        const c = { label: "", nodes: this.nodes };
        packClusters([c]);
        this.clusters = [];
      } else {
        const by = new Map(this.app.d.areas.map((a) => [a.id, []]));
        for (const d of this.nodes) by.get(d.n.area).push(d);
        const clusters = [];
        for (const a of this.app.d.areas) {
          const ns = by.get(a.id);
          if (!ns.length) continue;
          const ids = new Set(ns.map((d) => d.id));
          forceLayout(ns, this.edges.filter((e) => ids.has(e.source) && ids.has(e.target)));
          clusters.push({ id: a.id, label: a.label, nodes: ns });
        }
        packClusters(clusters);
        this.clusters = clusters.map(({ id, label, x, y, w, h: ch }) => ({ id, label, x, y, w, h: ch }));
      }
      cache.set(key, { clusters: this.clusters, nodes: new Map(this.nodes.map((d) => [d.id, { x: d.x, y: d.y }])) });
    }

    render() {
      const app = this.app;
      this.svg = s("svg", { class: "graph", role: "img", "aria-label": `${app.d.meta.title} 관계 그래프. 노드 ${this.nodes.length}개, 간선 ${this.edges.length}개. 같은 내용은 상세 패널과 관계 목록 탭에서 텍스트로 확인할 수 있습니다.` });
      const defs = s("defs");
      const mk = (id, w, hgt, refX, path, cls) => defs.append(s("marker", { id: `mk-${id}`, viewBox: `0 0 ${w} ${hgt}`, refX, refY: hgt / 2, markerWidth: w, markerHeight: hgt, markerUnits: "userSpaceOnUse", orient: "auto" }, s("path", { d: path, class: cls })));
      mk("type_of", 14, 12, 13, "M1 1 L13 6 L1 11 Z", "mk-type_of");
      mk("instance_of", 12, 12, 11, "M1 1 L11 6 L1 11", "mk-instance_of");
      mk("part_of", 18, 10, 17, "M1 5 L9 1 L17 5 L9 9 Z", "mk-part_of");
      mk("cause_of", 13, 12, 12, "M0 0 L13 6 L0 12 Z", "mk-cause_of");
      mk("data_to_claim", 11, 10, 10, "M0 0 L11 5 L0 10 Z", "mk-data_to_claim");
      this.svg.append(defs);
      this.vp = s("g", { class: "viewport" });
      const gClusters = s("g"), gEdges = s("g"), gNodes = s("g");
      this.gLabels = s("g");
      this.vp.append(gClusters, gEdges, this.gLabels, gNodes);
      this.svg.append(this.vp);

      for (const c of this.clusters) {
        gClusters.append(s("rect", { x: c.x, y: c.y, width: c.w, height: c.h, rx: 14, class: "cluster-bg" }),
          s("rect", { x: c.x + 14, y: c.y + 13, width: 10, height: 10, rx: 2, fill: app.areaColor.get(c.id) }),
          s("text", { x: c.x + 30, y: c.y + 22, class: "cluster-title" }, c.label));
      }
      // 같은 두 노드 사이의 여러 간선은 곡률을 나눈다
      const pairCount = new Map();
      this.edgeEls = [];
      for (const e of this.edges) {
        const key = [e.source, e.target].sort().join("|");
        const i = pairCount.get(key) ?? 0; pairCount.set(key, i + 1);
        e._bend = i === 0 ? 0 : (i % 2 ? 1 : -1) * Math.ceil(i / 2) * 26;
      }
      for (const e of this.edges) {
        const line = s("path", { class: "line", "marker-end": `url(#mk-${e.type})` });
        const hit = s("path", { class: "hit" });
        const a = this.byId.get(e.source).n, b = this.byId.get(e.target).n;
        const xc = this.clusters.length && a.area !== b.area ? " xc" : "";
        const g = s("g", { class: `edge r-${e.type}${xc}` }, s("title", {}, `${a.label} —${REL_LABEL[e.type]}→ ${b.label}\n${e.why}\n[${STATUS_LABEL[e.status]}]`), hit, line);
        g.dataset.idx = String(this.edgeEls.length);
        this.edgeEls.push({ e, g, line, hit });
        gEdges.append(g);
      }
      this.nodeEls = new Map();
      for (const d of this.nodes) {
        const col = app.areaColor.get(d.n.area);
        const g = s("g", { class: `node k-${d.n.kind}${d.n.core ? " core" : ""}`, "data-id": d.id, tabindex: "-1" },
          s("title", {}, `${d.n.label}\n${d.n.def}`),
          s("rect", { class: "box", x: -d.w / 2, y: -d.h / 2, width: d.w, height: d.h, rx: d.n.kind === "concept" || d.n.kind === "example" ? 7 : 12 }),
          s("rect", { class: "stripe", x: -d.w / 2 + 4, y: -d.h / 2 + 5, width: 3.5, height: d.h - 10, rx: 1.5, fill: col }));
        d.lines.forEach((ln, i) => g.append(s("text", { x: -d.w / 2 + 14, y: (i - (d.lines.length - 1) / 2) * 15 + 4.2 }, ln)));
        this.nodeEls.set(d.id, g);
        gNodes.append(g);
      }
      this.positionAll();
      this.applyRelVisibility();
      this.wrap.replaceChildren(this.svg);
      this.banner = h("div", { class: "graph-banner" });
      const tool = (label, icon, fn) => h("button", { type: "button", title: label, "aria-label": label, onclick: fn }, icon);
      const ic = (d) => s("svg", { width: 16, height: 16, viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", "stroke-width": 2.2, "stroke-linecap": "round", "aria-hidden": "true" }, s("path", { d }));
      this.wrap.append(this.banner,
        h("div", { class: "graph-tools" },
          tool("확대", ic("M12 5v14M5 12h14"), () => this.zoomBy(1.3)),
          tool("축소", ic("M5 12h14"), () => this.zoomBy(1 / 1.3)),
          tool("전체 맞춤", ic("M4 9V4h5M20 9V4h-5M4 15v5h5M20 15v5h-5"), () => this.fit())),
        h("div", { class: "graph-hint" }, "드래그: 이동 · 휠/핀치: 확대·축소 · 노드 드래그: 위치 조정 · 두 번 누르기: 집중 보기"));
      this.bindPointer();
    }

    endpoint(d, tx, ty) {
      const dx = tx - d.x, dy = ty - d.y;
      if (!dx && !dy) return [d.x, d.y];
      const hw = d.w / 2 + 2, hh = d.h / 2 + 2;
      const t = Math.min(dx ? hw / Math.abs(dx) : Infinity, dy ? hh / Math.abs(dy) : Infinity);
      return [d.x + dx * t, d.y + dy * t];
    }
    edgePath(e) {
      const a = this.byId.get(e.source), b = this.byId.get(e.target);
      if (!e._bend) {
        const [sx, sy] = this.endpoint(a, b.x, b.y), [tx, ty] = this.endpoint(b, a.x, a.y);
        return [`M${sx.toFixed(1)} ${sy.toFixed(1)} L${tx.toFixed(1)} ${ty.toFixed(1)}`, (sx + tx) / 2, (sy + ty) / 2];
      }
      const mx = (a.x + b.x) / 2, my = (a.y + b.y) / 2;
      const len = Math.hypot(b.x - a.x, b.y - a.y) || 1;
      const cx = mx - ((b.y - a.y) / len) * e._bend, cy = my + ((b.x - a.x) / len) * e._bend;
      const [sx, sy] = this.endpoint(a, cx, cy), [tx, ty] = this.endpoint(b, cx, cy);
      return [`M${sx.toFixed(1)} ${sy.toFixed(1)} Q${cx.toFixed(1)} ${cy.toFixed(1)} ${tx.toFixed(1)} ${ty.toFixed(1)}`, (sx + 2 * cx + tx) / 4, (sy + 2 * cy + ty) / 4];
    }
    positionAll() {
      for (const d of this.nodes) this.nodeEls.get(d.id).setAttribute("transform", `translate(${d.x.toFixed(1)} ${d.y.toFixed(1)})`);
      for (const o of this.edgeEls) { const [p, mx, my] = this.edgePath(o.e); o.line.setAttribute("d", p); o.hit.setAttribute("d", p); o.mid = [mx, my]; }
      if (this.selected) this.drawEdgeLabels();
    }
    applyRelVisibility() {
      for (const o of this.edgeEls) o.g.classList.toggle("hidden-rel", !this.app.st.rel.has(o.e.type));
    }

    // ----- 선택·강조 -----
    select(id, center) {
      this.selected = id;
      this.svg.classList.toggle("has-sel", !!id);
      for (const g of this.nodeEls.values()) g.classList.remove("selected", "near");
      for (const o of this.edgeEls) o.g.classList.remove("near");
      if (id && this.nodeEls.has(id)) {
        this.nodeEls.get(id).classList.add("selected");
        for (const o of this.edgeEls) {
          if (!this.app.st.rel.has(o.e.type)) continue;
          if (o.e.source === id || o.e.target === id) {
            o.g.classList.add("near");
            this.nodeEls.get(o.e.source === id ? o.e.target : o.e.source).classList.add("near");
          }
        }
        if (center) this.centerOn(id);
      }
      this.drawEdgeLabels();
    }
    selectEdge(e) {
      this.app.st.selEdge = e.id;
      this.select(null, false);
      this.highlightEdge(e);
      this.app.renderEdgeDetail(e);
    }
    highlightEdge(e) {
      this.svg.classList.add("has-sel");
      for (const o of this.edgeEls) o.g.classList.toggle("near", o.e === e);
      for (const [id, g] of this.nodeEls) g.classList.toggle("near", id === e.source || id === e.target);
      this.drawEdgeLabels([e]);
    }
    drawEdgeLabels(only) {
      this.gLabels.replaceChildren();
      const list = only ?? (this.selected ? this.edgeEls.filter((o) => (o.e.source === this.selected || o.e.target === this.selected) && this.app.st.rel.has(o.e.type)).map((o) => o.e) : []);
      for (const e of list) {
        const o = this.edgeEls.find((x) => x.e === e);
        if (!o?.mid) continue;
        const t = REL_LABEL[e.type];
        const w = textWidth(t, 700) * 0.9 + 12;
        this.gLabels.append(s("g", { class: `elabel`, transform: `translate(${o.mid[0].toFixed(1)} ${o.mid[1].toFixed(1)})` },
          s("rect", { x: -w / 2, y: -9, width: w, height: 17, rx: 8 }),
          s("text", { x: 0, y: 3.6, "text-anchor": "middle", style: `fill:var(--r-${{ type_of: "type", instance_of: "instance", part_of: "part", cause_of: "cause", data_to_claim: "data" }[e.type]})` }, t)));
      }
    }
    highlightMatches(set) {
      this.svg.classList.toggle("has-match", !!set && set.size > 0);
      for (const [id, g] of this.nodeEls) g.classList.toggle("match", !!set && set.has(id));
    }

    // ----- 확대·이동 -----
    apply() { this.vp.setAttribute("transform", `translate(${this.tx.toFixed(1)} ${this.ty.toFixed(1)}) scale(${this.k.toFixed(4)})`); }
    bbox() {
      let x0 = Infinity, y0 = Infinity, x1 = -Infinity, y1 = -Infinity;
      for (const c of this.clusters) { x0 = Math.min(x0, c.x); y0 = Math.min(y0, c.y); x1 = Math.max(x1, c.x + c.w); y1 = Math.max(y1, c.y + c.h); }
      for (const d of this.nodes) { x0 = Math.min(x0, d.x - d.w / 2); y0 = Math.min(y0, d.y - d.h / 2); x1 = Math.max(x1, d.x + d.w / 2); y1 = Math.max(y1, d.y + d.h / 2); }
      return isFinite(x0) ? [x0, y0, x1, y1] : [0, 0, 100, 100];
    }
    fit() {
      const r = this.wrap.getBoundingClientRect();
      const W = r.width || 800, H = r.height || 600;
      const [x0, y0, x1, y1] = this.bbox();
      const topPad = 52;
      this.k = Math.min((W - 40) / (x1 - x0 || 1), (H - topPad - 30) / (y1 - y0 || 1), 1.4);
      this.k = Math.max(this.k, 0.08);
      this.tx = (W - (x1 - x0) * this.k) / 2 - x0 * this.k;
      this.ty = topPad + (H - topPad - (y1 - y0) * this.k) / 2 - y0 * this.k;
      // 좁은 화면에서는 전체를 억지로 맞추지 않고 읽을 수 있는 배율로 왼쪽 위부터 보여 준다
      const minK = W < 700 ? 0.5 : 0.3;
      if (this.k < minK) {
        this.k = minK;
        this.tx = 12 - x0 * this.k;
        this.ty = topPad + 8 - y0 * this.k;
      }
      this.apply();
    }
    zoomBy(f, cx, cy) {
      const r = this.wrap.getBoundingClientRect();
      cx ??= r.width / 2; cy ??= r.height / 2;
      const k = Math.min(4, Math.max(0.05, this.k * f));
      this.tx = cx - ((cx - this.tx) * k) / this.k;
      this.ty = cy - ((cy - this.ty) * k) / this.k;
      this.k = k;
      this.apply();
    }
    centerOn(id) {
      const d = this.byId.get(id);
      if (!d) return;
      const r = this.wrap.getBoundingClientRect();
      if (this.k < 0.75) this.k = 0.95;
      this.tx = r.width / 2 - d.x * this.k;
      this.ty = r.height / 2 - d.y * this.k;
      this.apply();
    }
    bindPointer() {
      const svg = this.svg;
      const pts = new Map();
      let drag = null, pinch = null;
      const local = (ev) => { const r = svg.getBoundingClientRect(); return [ev.clientX - r.left, ev.clientY - r.top]; };
      svg.addEventListener("pointerdown", (ev) => {
        if (ev.button !== 0 && ev.pointerType === "mouse") return;
        svg.setPointerCapture(ev.pointerId);
        pts.set(ev.pointerId, local(ev));
        if (pts.size === 2) {
          const [a, b] = [...pts.values()];
          pinch = { dist: Math.hypot(a[0] - b[0], a[1] - b[1]), k: this.k, tx: this.tx, ty: this.ty, cx: (a[0] + b[0]) / 2, cy: (a[1] + b[1]) / 2 };
          drag = null; return;
        }
        const nodeEl = ev.target.closest(".node");
        const [x, y] = local(ev);
        const edgeEl = nodeEl ? null : ev.target.closest(".edge");
        drag = { x, y, tx: this.tx, ty: this.ty, node: nodeEl ? this.byId.get(nodeEl.dataset.id) : null, moved: false, edge: edgeEl ? this.edgeEls[+edgeEl.dataset.idx]?.e : null };
        if (drag.node) { drag.nx = drag.node.x; drag.ny = drag.node.y; }
      });
      svg.addEventListener("pointermove", (ev) => {
        if (!pts.has(ev.pointerId)) return;
        pts.set(ev.pointerId, local(ev));
        if (pinch && pts.size === 2) {
          const [a, b] = [...pts.values()];
          const dist = Math.hypot(a[0] - b[0], a[1] - b[1]);
          const k = Math.min(4, Math.max(0.05, pinch.k * (dist / pinch.dist)));
          this.tx = pinch.cx - ((pinch.cx - pinch.tx) * k) / pinch.k;
          this.ty = pinch.cy - ((pinch.cy - pinch.ty) * k) / pinch.k;
          this.k = k; this.apply(); return;
        }
        if (!drag) return;
        const [x, y] = local(ev);
        if (!drag.moved && Math.hypot(x - drag.x, y - drag.y) < 5) return;
        drag.moved = true;
        if (drag.node) {
          drag.node.x = drag.nx + (x - drag.x) / this.k;
          drag.node.y = drag.ny + (y - drag.y) / this.k;
          this.positionAll();
        } else {
          svg.classList.add("panning");
          this.tx = drag.tx + (x - drag.x); this.ty = drag.ty + (y - drag.y); this.apply();
        }
      });
      const end = (ev) => {
        pts.delete(ev.pointerId);
        svg.classList.remove("panning");
        if (pinch) { if (pts.size < 2) pinch = null; drag = null; return; }
        if (!drag) return;
        const dr = drag; drag = null;
        if (dr.moved || ev.type === "pointercancel") return;
        if (dr.node) {
          const now = Date.now();
          if (this._last?.id === dr.node.id && now - this._last.t < 380) { this.app.st.focus = dr.node.id; this.app.st.focusScen = null; this.app.st.sel = dr.node.id; this.app.renderView(); return; }
          this._last = { id: dr.node.id, t: now };
          this.app.select(dr.node.id);
        } else if (dr.edge) this.selectEdge(dr.edge);
        else this.app.select(null);
      };
      svg.addEventListener("pointerup", end);
      svg.addEventListener("pointercancel", end);
      svg.addEventListener("wheel", (ev) => {
        ev.preventDefault();
        const [x, y] = local(ev);
        this.zoomBy(Math.exp(-ev.deltaY * (ev.ctrlKey ? 0.01 : 0.0018)), x, y);
      }, { passive: false });
      window.addEventListener("keydown", this._key = (ev) => {
        if (!this.svg.isConnected) { window.removeEventListener("keydown", this._key); return; }
        if (ev.key === "Escape" && !ev.target.closest("input, select")) this.app.select(null);
      });
      let rt;
      new ResizeObserver(() => { clearTimeout(rt); rt = setTimeout(() => { if (this.svg.isConnected && !this._fitOnce) { this._fitOnce = true; this.fit(); } }, 60); }).observe(this.wrap);
    }
  }

  // ---------- 홈 ----------
  function initHome() {
    for (const el of document.querySelectorAll("[data-stats]")) {
      fetch(el.dataset.stats).then((r) => (r.ok ? r.json() : Promise.reject(new Error(r.status)))).then((d) => {
        const c = (t) => d.edges.filter((e) => e.type === t).length;
        setKids(el,
          h("span", { class: "chip" }, "노드 ", h("b", { text: d.nodes.length })),
          h("span", { class: "chip" }, "간선 ", h("b", { text: d.edges.length })),
          h("span", { class: "chip" }, "문제 경로 ", h("b", { text: d.scenarios.length })),
          d.mappings ? h("span", { class: "chip" }, "대응 ", h("b", { text: d.mappings.length })) : null,
          h("span", { class: "chip", title: "Type of · Instance of · Part of · Cause of · Data → Claim" }, "관계별 ", h("b", { text: REL.map(c).join("·") })));
      }).catch(() => { el.textContent = ""; });
    }
    for (const el of document.querySelectorAll("[data-swatch]")) el.prepend(relSwatch(el.dataset.swatch, 34));
  }

  function boot() {
    initTheme();
    if (document.body.dataset.page === "home") { initHome(); return; }
    const root = document.getElementById("app");
    if (!root) return;
    if (location.protocol === "file:") {
      root.replaceChildren(h("p", { class: "fatal" }, "파일을 직접 열면 브라우저 보안 정책 때문에 데이터를 읽을 수 없습니다. 저장소 루트에서 ‘python3 -m http.server’를 실행한 뒤 http://localhost:8000/sqld/ 로 여세요."));
      return;
    }
    fetch(document.body.dataset.data)
      .then((r) => (r.ok ? r.json() : Promise.reject(new Error(`데이터 응답 ${r.status}`))))
      .then((data) => { window.sqldMap = new MapApp(root, data); })
      .catch((e) => { root.replaceChildren(h("p", { class: "fatal" }, `데이터를 불러오지 못했습니다: ${e.message}`)); console.error(e); });
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", boot); else boot();
})();
