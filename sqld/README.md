# SQLD 개념 관계망 (`/sqld/`)

SQLD 1·2과목의 개념과 문제를 **다섯 관계**(Type of · Instance of · Part of · Cause of · Data → Claim)로만 연결한
정적 웹사이트. 공통 메뉴로 전환하는 세 지도를 하나의 GitHub Pages 사이트에서 제공한다.

| 경로 | 내용 |
|---|---|
| `/sqld/` | 홈 — 세 지도 링크, 다섯 관계·문제해결도식·검증 상태 설명 |
| `/sqld/subject-1/` | 1과목 전용 지도 (데이터 모델링의 이해) |
| `/sqld/bridge/` | 1·2과목 대응 지도 (설계 원리 ↔ SQL 구현·처리, 대응표 포함) |
| `/sqld/subject-2/` | 2과목 전용 지도 (SQL 기본·활용·관리) |

GitHub Pages 주소(프로젝트 사이트): `https://leewonseol.github.io/SQLD/sqld/` 와 그 하위 경로.
모든 내부 링크·데이터 경로는 상대경로라서 `/SQLD/` 같은 프로젝트 하위 경로에서도, 다른 저장소 이름에서도 그대로 동작한다.

## 파일 구조

```
sqld/
  index.html                 홈
  subject-1/index.html       1과목 전용 지도 (페이지 골격만, 내용은 JSON)
  bridge/index.html          1·2과목 대응 지도
  subject-2/index.html       2과목 전용 지도
  assets/sqld-map.css        세 지도·홈 공통 스타일(라이트/다크)
  assets/sqld-map.js         세 지도 공통 뷰어(그래프·문제해결 경로·관계 목록·대응표)
  data/subject-1.json        구조화 데이터 — 이 JSON이 원본(canonical)이다
  data/bridge.json
  data/subject-2.json
  tools/validate.mjs         데이터 검증기(의존성 없음, Node 18+)
  legacy/*.html              리팩터링 전 원본 지도 3개(보관·누락 검사용, 메뉴에는 노출하지 않음)
```

빌드 단계가 없다. 세 지도 페이지는 같은 `sqld-map.js`를 불러와 `<body data-data="../data/NAME.json">`의 데이터를 그린다.
로컬 확인: 저장소 루트에서 `python3 -m http.server 8000` 실행 후 `http://localhost:8000/sqld/` (파일을 직접 열면 브라우저가 JSON 읽기를 막는다).

## 화면 기능

- **개념 관계망**: 영역별 클러스터 그래프. 확대·축소(휠·핀치·버튼), 이동(드래그), 노드 위치 조정(노드 드래그).
  - 초기 화면은 `핵심 노드`만 표시하고, `범위`에서 개념 전체 → 문제 경로 전체로 확장한다.
  - 노드 선택 → 정의·설명·관계(상위/하위 개념, 사례, 전체/구성 요소, 원인/결과, 근거/주장)·대응·관련 문제 경로·참조 문서.
  - `집중 보기`(노드 두 번 누르기): 연결된 노드만 1단계/2단계로 남겨 다시 배치한다.
  - 다섯 관계마다 색과 선 모양이 다르다: Type of(보라 실선·빈 삼각형), Instance of(파랑 점선·열린 화살표),
    Part of(초록 실선·마름모), Cause of(주황 굵은 선·채운 삼각형), Data → Claim(회색 점선).
  - 관계별 표시·숨기기, 영역(문제 영역) 필터, 개념명·문제명 검색(자동완성).
- **문제해결 경로**: 같은 열에 맞춰 ① `원인 → Cause of → 문제` ② `개입 → Cause of → 원인 변화 → Cause of → 기대효과`
  ③ `관찰 자료 → Data → Claim → 주장`을 나란히 보여 주고, 인과 성격(결정적·충분·필요·확률적)과 주의사항을 함께 표시한다.
- **관계 목록**: 모든 간선을 표로(관계·영역·검색·검증 상태 필터).
- **설계 ↔ 구현 대응표**(대응 지도만): 1과목 원리와 2과목 기능의 대응. 다섯 관계가 아니므로 간선으로 그리지 않는다.
- 상태는 URL 해시에 남는다(예: `subject-1/#v=paths&s=A17`, `bridge/#v=graph&n=q_fk_c&f=1`). 새로고침·공유 시 유지된다.

## 데이터 형식

```jsonc
{
  "meta": { "id": "subject-1", "title": "...", "legacySources": ["H1"] },
  "documents": { "L1": { "title": "...", "file": "...", "provided": true, "note": "..." }, ... },
  "relations": { "type_of": { "label": "Type of", "direction": "하위 개념 → 상위 개념", "meaning": "..." }, ... },
  "statuses":  { "confirmed": "...", ... },  "causality": { ... },  "kinds": { ... },
  "areas": [ { "id": "m-key", "label": "식별자·키·무결성", "desc": "..." } ],
  "nodes": [ { "id": "candidate", "label": "후보키", "kind": "concept", "area": "m-key", "subject": "1과목",
               "def": "정의", "note": "간선으로 표현하지 않은 보충 설명", "refs": [{ "doc": "L1", "sec": "10" }],
               "basis": "source", "core": true } ],
  "edges": [ { "id": "S1-E087", "source": "candidate", "target": "superkey", "type": "type_of",
               "direction": "하위 개념 → 상위 개념", "why": "근거·설명", "refs": [{ "doc": "L1", "sec": "10" }],
               "status": "derived", "causality": "probabilistic(Cause of만)", "scenarios": ["A15"] } ],
  "scenarios": [ { "id": "A17", "area": "m-norm", "title": "...", "legacy": ["A17"],
                   "nodes": { "category", "problem", "case", "cause", "intervention", "mediator", "effect", "evidence", "claim", "side?" },
                   "concepts": ["관련 개념(간선 아님)"], "causal": { "problem": {...}, "solution": {...} },
                   "claimStatus": "pending", "caveat": "...", "bridge": "(대응 지도) 설계↔구현 연결 설명" } ],
  "mappings": [ { "id": "M04", "design": "ref_int", "impl": ["q_fk_c"], "function": "집행", "desc": "...", "limits": "...", "refs": [...], "status": "confirmed" } ]
}
```

모든 간선은 출발·도착 노드, 관계 유형, 방향, 근거(`why`), 출처 문서·절(`refs`), 검증 상태(`status`)를 갖는다.

### 검증 상태(`status`)

| 값 | 표시 | 뜻 |
|---|---|---|
| `confirmed` | 출처 확인 | 제공된 강의내용 교정편집본의 해당 절에서 관계가 직접 서술됨 |
| `derived` | 정의상 도출 | 해당 절의 정의로부터 논리적으로 따라 나옴(예: 후보키 ⊂ 슈퍼키) |
| `supplement` | 보충(출처 외) | 표준 이론이지만 제공 문서에서 직접 확인되지 않음(문서 `STD`) |
| `authored` | 학습용 구성 | 작성자가 구성한 분류·사례 연결(문제 → 문제 유형, 사례 → 문제) |
| `inferred` | 학습용 추론 | 작성자가 추론한 인과 경로. 실증 아님 |
| `pending` | 검증 예정 | Data → Claim: 실제 실행·관찰 결과가 아직 없음 |
| `example` | 예시 | Data → Claim: 강의의 설명용 예시 값(실행 결과 아님) |

노드의 `basis`는 `source`(출처 기반) / `supplement`(보충) / `authored`(학습용 작성)로 출처 기반 내용과 구분한다.

### 연결 규칙

- 여러 구체 문장·선언을 포괄하는 종류(문장 유형, 제약 유형, 조인 유형, 함수 범주)는 **Type of**,
  개별 이름을 가진 함수·연산자·의사열·사례는 **Instance of**, 절·키워드·옵션·구성 요소는 **Part of**.
- 문제와 해결책을 잇는 여섯 번째 간선은 없다. 해결은 `개입 → Cause of → 원인 변화 → Cause of → 기대효과`로만 표현한다.
- 다섯 관계로 정확히 표현할 수 없는 것(순서, 대응, 분해, '관점에서 활용하는 도구', 논리↔물리 대응 등)은 간선을 만들지 않고
  노드 `note`, 시나리오 `concepts`, 대응표(`mappings`)에 기록한다.
- 문제 경로의 원인은 개념 노드를 재사용할 수 있다(예: `redundancy` 불필요한 중복 저장 → `an_upd` 갱신 이상).

### 검증기

```bash
node sqld/tools/validate.mjs
```

검사 항목: 필수 필드·중복 ID·끊긴 참조·자기 간선·중복 간선, 다섯 관계 외 유형 금지, Type of·Part of 순환 금지,
Cause of의 인과 성격, Data → Claim의 양 끝 종류와 상태(`pending`/`example`만 허용), 문제 경로의 필수 간선 구조,
그리고 다음 **정확성 규칙**:

1. WHERE절은 SELECT문의 Type of가 아니며 `WHERE절 Part of SELECT문`이 있어야 한다.
2. `후보키 Type of 슈퍼키`가 있어야 한다.
3. 함수적 종속(결정자·종속자·완전/부분/이행·예시 포함) 노드에는 Cause of 간선이 없다.
4. 정규화는 어떤 이상 현상의 Type of도 아니다.
5. DISTINCT에서 출발하는 Cause of가 없고, DISTINCT 적용 개입은 '저장·정규화·원본' 개선에 인과로 닿지 않는다.
6. JOIN 개념에서 출발하는 Cause of가 없고, JOIN만 적용한 개입은 '무결성' 개선에 인과로 닿지 않는다.
7. 기대효과 라벨에 관측 표현이 없고, 모든 Data → Claim은 `pending`/`example`.
8. Instance of의 출발은 개별 사례, Type of 양 끝은 같은 종류(개념끼리 또는 문제 → 문제 유형).

원본 대비 누락 검사: `legacy/*.html`에 내장된 원본 데이터를 읽어 원본 문제 경로 ID가 모두 새 경로의 `legacy`에 들어 있는지,
원본 개념 용어(p1·p2)가 새 데이터 어딘가에 남아 있는지 확인한다.

`.github/workflows/sqld-validate.yml`이 `sqld/**`가 바뀌는 푸시·PR마다 검증기를 실행한다(배포는 하지 않음).

## 기존 HTML 대비 바뀐 점(검토 기록)

| 원본 | 문제 | 조치 |
|---|---|---|
| 모든 경로 | 원리·SQL 개념이 `Part of → 개입`으로 연결됨(개념은 개입의 구성 요소가 아님) | 간선 삭제, 시나리오 `concepts`(비간선 참조)로 이동. 정확한 경우에만 `개입 Instance of 개념`(예: FOREIGN KEY 선언 → FOREIGN KEY) |
| 모든 경로 | 해결 경로가 원인과 이어지지 않음(개입 → 기대효과) | `개입 → 원인 변화 → 기대효과`로 원인 제거·변경을 명시하고, 인과 성격을 표시 |
| 모든 경로 | 개념 노드가 경로마다 복제되고 개념 사이 상하·구성 관계가 없음 | 지도별 공유 개념 그래프(Type of·Part of·Instance of) 구축. 예: 후보키 Type of 슈퍼키, 2NF Type of 1NF |
| A17 / S12·S13 | 삽입·삭제·갱신 이상을 한 경로로 묶음 | 갱신(A17·S12)·삭제(A25·S13)·삽입(A27) 경로로 분리, 원인을 공유 개념 노드로 연결 |
| A22 | 원자성(부분 처리)과 격리성(동시성)을 한 경로로 묶음 | A22(원자성)·A26(격리성)으로 분리 |
| B28 / S33 | PIVOT과 정규표현식을 한 경로로 묶음(원본도 별개 기능이라 주석) | B28(PIVOT)·B38(정규표현식) 분리, 대응 지도는 S22에서 정규표현식 처리 |
| S06 | '관계 차수·선택 사양' 문제를 미존재 부모 참조 사례로 서술(참조 무결성과 혼동) | 자식 쪽 필수 참여 = FK 열 NOT NULL + FOREIGN KEY로 재정의, 부모 쪽 필수는 단순 제약으로 집행 불가함을 명시 |
| S10 | SELF JOIN과 계층형 질의를 한 개입으로 묶음 | S10(SELF JOIN)·S41(계층형 질의) 분리 |
| 모든 Data 노드 | 검증 자료 후보라는 사실이 노드에만 서술됨 | 간선 상태를 `pending`(검증 예정)·`example`(강의 예시)로 명시 |
| — | 요청서의 정확성 함정 | 신규 경로: B34(DISTINCT ≠ 저장 중복 제거), S40(DISTINCT vs 정규화), S39(INNER JOIN이 참조 무결성 위반을 가림), B35(OUTER JOIN 후 COUNT(*)), B36(OVER 안 ORDER BY ≠ 출력 순서), B37(UNION 순서 미보장) |

보충(출처 외)으로 표시한 내용: 1:1 관계 차수, '도메인 무결성' 명칭, BCNF·4NF·5NF 정의와 정규형 포함 관계, SELECT의 DML 분류,
기본·설계·파생 속성의 정의 문장, Oracle `''` = NULL, UNIQUE·CHECK의 NULL 처리, NULL 정렬 위치, DDL 자동 커밋 차이,
WITH GRANT/ADMIN OPTION 회수 연쇄, 의사열(ROWNUM·LEVEL) 범주명.

## 기준 문서

- 대조함: `SQLD_1과목_강의내용_교정편집본(1).docx`(17절), `SQLD_2과목_강의내용_교정편집본(1).docx`(27절)
- **대조하지 못함**: `SQLD_1과목_개념해설_교정통합본(1).docx`, `SQLD_2과목_개념해설_교정통합본(1).docx` — 작업 시 제공되지 않았다.
  이 문서에서만 확인되는 내용은 현재 `supplement`로 남아 있으므로, 문서를 대조한 뒤 상태를 `confirmed`로 올리거나 수정해야 한다.

## GitHub Pages 배포

이 디렉터리는 빌드가 필요 없는 정적 파일이다. Jekyll로 저장소 전체를 빌드해도(`Deploy from a branch`) `sqld/`는 그대로 복사된다
(파일명이 `_`로 시작하지 않고 HTML에 front matter가 없음 — 로컬 Jekyll 4.4 빌드로 확인).

설정: 저장소 **Settings → Pages → Build and deployment → Source: Deploy from a branch → Branch: `main` / `/ (root)`** → Save.
이 변경이 `main`에 병합된 뒤 몇 분 안에 `https://leewonseol.github.io/SQLD/sqld/`가 열린다.
이미 다른 방식으로 Pages를 쓰고 있다면 그 설정을 유지하면 된다 — 저장소 루트의 기존 파일은 바꾸지 않았다.
