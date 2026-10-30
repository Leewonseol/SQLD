-- H. 정답 및 검증 | 01 ex02 | SQL Server
DROP VIEW IF EXISTS ans01_02_g2, exp01_02_g2;
DROP TABLE IF EXISTS m01_g_presc, m01_g_appt, m01_g_doctor, m01_g_patient, m01_g_dept;
CREATE TABLE m01_g_dept    (dept_cd VARCHAR(5) PRIMARY KEY, dept_nm NVARCHAR(20) NOT NULL);
CREATE TABLE m01_g_patient (patient_id INT PRIMARY KEY, name NVARCHAR(20) NOT NULL);
CREATE TABLE m01_g_doctor  (doctor_id INT PRIMARY KEY, name NVARCHAR(20) NOT NULL, dept_cd VARCHAR(5) NOT NULL REFERENCES m01_g_dept(dept_cd));
CREATE TABLE m01_g_appt    (appt_id INT PRIMARY KEY, patient_id INT NOT NULL REFERENCES m01_g_patient(patient_id),
                            doctor_id INT NOT NULL REFERENCES m01_g_doctor(doctor_id), appt_at DATETIME2(0) NOT NULL,
                            status NVARCHAR(10) NOT NULL CHECK (status IN (N'예약', N'완료', N'취소')),
                            CONSTRAINT uq_m01_g_appt_slot UNIQUE (doctor_id, appt_at));
CREATE TABLE m01_g_presc   (presc_id INT PRIMARY KEY, appt_id INT NOT NULL UNIQUE REFERENCES m01_g_appt(appt_id));
INSERT INTO m01_g_dept VALUES ('IM', N'내과');
INSERT INTO m01_g_patient VALUES (1, N'환자1');
INSERT INTO m01_g_doctor VALUES (10, N'의사A', 'IM');
INSERT INTO m01_g_appt VALUES (100, 1, 10, '2024-05-01', N'완료');
INSERT INTO m01_g_presc VALUES (1000, 100);
GO
-- @expect-error: MSG-515, MSG-547, MSG-2627
INSERT INTO m01_g_doctor VALUES (11, N'의사B', NULL);
GO
INSERT INTO m01_g_appt VALUES (101, 999, 10, '2024-05-02', N'예약');
GO
INSERT INTO m01_g_presc VALUES (1001, 100);
GO
INSERT INTO m01_g_appt VALUES (102, 1, 10, '2024-05-01', N'예약');
GO
CREATE OR ALTER VIEW ans01_02_g2 AS SELECT (SELECT COUNT(*) FROM m01_g_doctor) d, (SELECT COUNT(*) FROM m01_g_appt) a, (SELECT COUNT(*) FROM m01_g_presc) p;
GO
CREATE OR ALTER VIEW exp01_02_g2 (d, a, p) AS SELECT 1, 1, 1;
GO
EXEC lab_check N'01-ex02-G2', N'ans01_02_g2', N'exp01_02_g2';
GO
