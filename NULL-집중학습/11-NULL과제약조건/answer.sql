-- 11. NULL과 제약조건 — 정답 및 해설

-- Q1 정답: ②
-- 해설: CHECK 제약조건은 조건식이 FALSE로 평가되는 행만 위반으로 거부한다.
-- score가 NULL이면 "NULL >= 0"은 UNKNOWN이고, UNKNOWN은 FALSE가 아니므로
-- CHECK는 이 행을 통과시킨다. WHERE가 UNKNOWN인 행을 버리는 것과 정반대
-- 방향이라는 것이 핵심이다.

-- Q2 정답: ③
-- 해설: 표준 SQL/Oracle은 UNIQUE 컬럼에서 NULL을 서로 "같다"고 비교하지
-- 않으므로 NULL을 여러 번 허용한다. 반면 SQL Server의 일반 UNIQUE
-- 제약조건/인덱스는 NULL도 유일성 검사 대상에 포함시켜 딱 한 번만
-- 허용한다 — 이는 Microsoft 공식 문서에 명시된 SQL Server 고유의 동작으로,
-- 표준/Oracle과 다르다.

-- Q3 정답: ③
-- 해설: PRIMARY KEY는 내부적으로 NOT NULL + UNIQUE가 합쳐진 제약이다.
-- UNIQUE의 NULL 허용 개수가 DBMS마다 다른 것과 무관하게, PK는 두 DBMS
-- 모두 NULL을 0개까지만(즉 전혀) 허용하지 않는다 — 이 폴더에서 유일하게
-- 예외 없는 공통 규칙이다.

-- Q4 정답
INSERT INTO null_lab_fk_demo VALUES (99, NULL);

-- 성공/실패 및 이유(주석):
-- 성공한다. FOREIGN KEY 제약조건은 그 컬럼이 부모 테이블의 특정 행과
-- "반드시 연결되어 있어야 한다"를 강제하는 것이지, "값이 있어야 한다"를
-- 강제하는 게 아니다. dept_code가 NULL이면 애초에 어떤 부모 행과도 매칭할
-- 필요가 없는 상태로 취급되므로 FK 검사 대상에서 제외된다. 반대로
-- dept_code='D99'처럼 실제 값이지만 부모 테이블(null_lab_dept)에 없는
-- 값을 넣으면 FK 위반으로 실패한다.

-- Q5 정답(서술)
-- CHECK (score >= 0)는 score가 NULL일 때 "NULL >= 0"이 UNKNOWN으로
-- 평가되고, CHECK는 FALSE인 행만 거부하므로 UNKNOWN인 행(NULL)은 그대로
-- 통과시켜 버린다. 즉 이 CHECK 제약조건 하나만으로는 "score가 NULL이면
-- 안 된다"는 규칙을 전혀 강제하지 못한다. NULL을 확실히 막으려면
-- CHECK와는 별개로 컬럼 정의에 NOT NULL 제약조건을 추가로 걸어야 한다
-- (예: score NUMBER NOT NULL CHECK (score >= 0) — 두 제약을 함께 걸어야
-- "NULL도 아니고 음수도 아닌 값"이라는 의도가 정확히 강제된다).
