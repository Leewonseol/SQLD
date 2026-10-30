-- H. 정답 및 검증 | 01 ex02 | Oracle : 구현 DDL + 거부되어야 할 INSERT 가 실제로 거부되는지 확인
EXEC lab_drop('M01_G_PRESC')
EXEC lab_drop('M01_G_APPT')
EXEC lab_drop('M01_G_DOCTOR')
EXEC lab_drop('M01_G_PATIENT')
EXEC lab_drop('M01_G_DEPT')
CREATE TABLE m01_g_dept    (dept_cd VARCHAR2(5) PRIMARY KEY, dept_nm VARCHAR2(20 CHAR) NOT NULL);
CREATE TABLE m01_g_patient (patient_id NUMBER PRIMARY KEY, name VARCHAR2(20 CHAR) NOT NULL);
CREATE TABLE m01_g_doctor  (doctor_id NUMBER PRIMARY KEY, name VARCHAR2(20 CHAR) NOT NULL,
-- 의사 쪽 필수
                            dept_cd VARCHAR2(5) NOT NULL REFERENCES m01_g_dept(dept_cd));
CREATE TABLE m01_g_appt    (appt_id NUMBER PRIMARY KEY,
-- 예약 쪽 필수
                            patient_id NUMBER NOT NULL REFERENCES m01_g_patient(patient_id),
                            doctor_id  NUMBER NOT NULL REFERENCES m01_g_doctor(doctor_id),
                            appt_at DATE NOT NULL, status VARCHAR2(10) NOT NULL CHECK (status IN ('예약', '완료', '취소')),
-- 규칙 6
                            CONSTRAINT uq_m01_g_appt_slot UNIQUE (doctor_id, appt_at));
CREATE TABLE m01_g_presc   (presc_id NUMBER PRIMARY KEY,
-- 예약당 최대 1장
                            appt_id NUMBER NOT NULL UNIQUE REFERENCES m01_g_appt(appt_id));
INSERT INTO m01_g_dept VALUES ('IM', '내과');
INSERT INTO m01_g_patient VALUES (1, '환자1');
INSERT INTO m01_g_doctor VALUES (10, '의사A', 'IM');
INSERT INTO m01_g_appt VALUES (100, 1, 10, DATE '2024-05-01', '완료');
INSERT INTO m01_g_presc VALUES (1000, 100);
COMMIT;
PROMPT == G2 거부되어야 할 INSERT 3건 (진료과 없는 의사 / 없는 환자의 예약 / 같은 예약 두 번째 처방전)
-- @expect-error: ORA-01400, ORA-02291, ORA-00001
INSERT INTO m01_g_doctor VALUES (11, '의사B', NULL);
INSERT INTO m01_g_appt VALUES (101, 999, 10, DATE '2024-05-02', '예약');
INSERT INTO m01_g_presc VALUES (1001, 100);
PROMPT == 규칙 6: 같은 의사·같은 일시 두 번째 예약도 거부
-- @expect-error: ORA-00001
INSERT INTO m01_g_appt VALUES (102, 1, 10, DATE '2024-05-01', '예약');
CREATE OR REPLACE VIEW ans01_02_g2 AS
SELECT (SELECT COUNT(*) FROM m01_g_doctor) d, (SELECT COUNT(*) FROM m01_g_appt) a, (SELECT COUNT(*) FROM m01_g_presc) p FROM dual;
CREATE OR REPLACE VIEW exp01_02_g2 (d, a, p) AS SELECT 1, 1, 1 FROM dual;
EXEC lab_check('01-ex02-G2', 'ANS01_02_G2', 'EXP01_02_G2')
