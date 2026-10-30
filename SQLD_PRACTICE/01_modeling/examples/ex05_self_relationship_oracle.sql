-- ex05 자기 자신과의 관계(순환 관계) (PDF E-02 "하나의 엔터티 내에서 인스턴스끼리 계층 구조", E-03 "FK는 자기 자신이 속한 릴레이션을 참조할 수 있다. ex) 멘토")  | Oracle
EXEC lab_drop('M01_MEM')
CREATE TABLE m01_mem (
  member_id NUMBER CONSTRAINT pk_m01_mem PRIMARY KEY,
  name      VARCHAR2(10) NOT NULL,
  recommender_id NUMBER CONSTRAINT fk_m01_mem_rec REFERENCES m01_mem(member_id),
  CONSTRAINT ck_m01_mem_not_self CHECK (recommender_id <> member_id)
);
PROMPT == [Q1] 자기참조 FK: 추천인은 존재하는 회원이어야 한다 (NULL = 추천인 없음, 선택 관계)
INSERT INTO m01_mem VALUES (1, 'A', NULL);
INSERT INTO m01_mem VALUES (2, 'B', 1);
INSERT INTO m01_mem VALUES (3, 'C', 2);
-- @expect-error: ORA-02291
INSERT INTO m01_mem VALUES (4, 'D', 99);

PROMPT == [Q2] '자기 자신을 추천할 수 없다'는 한 행 안의 조건 -> CHECK 로 구현 가능
-- @expect-error: ORA-02290
INSERT INTO m01_mem VALUES (5, 'E', 5);

PROMPT == [Q3] 'A 가 C 를 추천 -> 순환(A->C->B->A)' 같은 여러 행에 걸친 순환 금지는 CHECK·FK 로 막지 못한다
UPDATE m01_mem SET recommender_id = 3 WHERE member_id = 1;
SELECT member_id, recommender_id FROM m01_mem ORDER BY member_id;

PROMPT == [Q4] 순환 여부는 조회로 '탐지'만 할 수 있다 (12단원 NOCYCLE)
SELECT member_id, LEVEL lvl, CONNECT_BY_ISCYCLE is_cycle FROM m01_mem START WITH member_id = 1 CONNECT BY NOCYCLE PRIOR recommender_id = member_id;
ROLLBACK;
EXEC lab_drop('M01_MEM')
