# ex03 ~ ex06 정답 (H)
## ex03
* G1 처방약품 PK = (처방전번호, 약품코드). 두 컬럼 모두 FK다. 처방전번호가 PK의 일부이므로 처방전에 대해 식별 관계다(약품에 대해서도 식별 관계).
* G2 처방전 PK = 예약번호(FK)이면 예약 하나에 처방전 행이 둘일 수 없다(PK 유일). 처방전은 예약 없이 존재할 수 없다(PK NOT NULL). 그래서 '1:0..1 + 처방전 쪽 필수'가 PK 하나로 보장된다. 별도 UNIQUE가 필요 없다.

## ex04
* G1 슈퍼키: {환자번호}, {주민번호}, {환자번호, 이름} … / 후보키: {환자번호}, {주민번호} / 기본키: 환자번호 / 대체키: 주민번호(UNIQUE).
  주민번호를 PK로 쓰지 않는 이유: ① 개인정보라 FK로 여러 테이블에 퍼지면 노출 범위가 커진다. ② 외국인처럼 값이 없거나 바뀔 수 있는 경우가 있다(PK는 NOT NULL·불변이 바람직).
* G2 `SELECT dept, birth, COUNT(*) FROM m01_student GROUP BY dept, birth HAVING COUNT(*) > 1;` → (DB, 2004-03-01) 2행이 나와 유일하지 않음이 반증된다(ex04 데이터 기준).

## ex05
* G1 `CREATE TABLE dept (dept_cd VARCHAR2(5) PRIMARY KEY, parent_cd VARCHAR2(5) REFERENCES dept(dept_cd), CHECK (parent_cd <> dept_cd));`
* G2 Oracle: `SELECT SYS_CONNECT_BY_PATH(dept_cd, '/') FROM dept START WITH parent_cd IS NULL CONNECT BY PRIOR dept_cd = parent_cd;`
  SQL Server: 12단원 ex01 SQL Server Q1의 재귀 CTE와 같은 형태다.
  (실행 검증: 같은 구조의 h_emp 예제가 12단원에서 두 DBMS 모두 실행되었다. 이 답안 자체는 **미실행·문법 검토**.)

## ex06
| 규칙 | 선언적 제약 | 대안 |
|---|---|---|
| 처방전에 약품 최소 1개 | 불가(부모 쪽 필수) | 트리거, 등록 프로시저 |
| 완료된 예약에만 처방전 | 불가(다른 테이블 상태) | 트리거 |
| 취소된 예약에는 처방전 불가 | 불가(같은 이유) | 트리거 |
| 의사 1명당 하루 최대 20건 | 불가(여러 행 집계) | 트리거 + 잠금 |
| 예약 일시는 과거일 수 없다 | **CHECK 불가**: CHECK 안에 SYSDATE·GETDATE 같은 비결정 함수는 Oracle에서 금지(ORA-02436). SQL Server는 허용하지만 시간이 지나면 기존 행이 위반 상태가 되는 의미 문제가 있다 | 입력 시점 트리거 / 응용 검증 |
(마지막 행의 오류 코드는 공식 문서 기준이다 — 미실행.)
