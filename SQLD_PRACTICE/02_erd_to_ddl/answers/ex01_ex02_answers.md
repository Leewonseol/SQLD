# 02단원 정답 (H)
## ex01
* DDL은 `../../01_modeling/answers/ex02_cardinality_optionality_answer_oracle.sql`(Oracle)과 `…_sqlserver.sql`(SQL Server)에 작성했다. 거부되어야 할 INSERT 4건이 실제로 거부되는 것을 lab_check로 검증했다(CHECK_PASS).
* 대응표(요약)

| 규칙 | 구현 |
|---|---|
| 의사는 진료과 필수 | doctor.dept_cd NOT NULL + FK |
| 예약은 환자·의사 필수 | appt.patient_id·doctor_id NOT NULL + FK |
| 상태는 예약·완료·취소 | CHECK (status IN (…)) |
| 같은 의사·같은 일시 중복 금지 | UNIQUE (doctor_id, appt_at) |
| 처방전은 예약당 최대 1장, 반드시 예약 소속 | presc.appt_id NOT NULL + UNIQUE + FK |
| 처방전–약품 M:N, 용량 | presc_item(presc_id, drug_cd) 복합 PK + 두 FK + dose NOT NULL |
| 완료된 예약에만 처방전 / 처방전에 약품 ≥ 1 | 구현 불가 → 트리거 |

## ex02
| 값 | Oracle | SQL Server |
|---|---|---|
| 이름(한글 20자) | VARCHAR2(20 CHAR) | NVARCHAR(20) |
| 금액(원) | NUMBER(8) | INT(또는 DECIMAL(8,0)) |
| 이율 | NUMBER(6,4) | DECIMAL(6,4) |
| 예약 일시(분) | DATE | DATETIME2(0) 또는 SMALLDATETIME |
| 성별 코드 | CHAR(1) + CHECK (IN ('M','F')) | CHAR(1) + CHECK |
* G2: VARCHAR2(20)은 기본이 20 **바이트**다. AL32UTF8에서 한글은 3바이트라 6자까지만 들어간다. 7자부터 ORA-12899가 난다(ex02 Q1에서 실행 확인).
