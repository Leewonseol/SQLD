-- 07_single_row_functions/setup_sqlserver.sql : 05단원 W_CODE 를 재사용한다
PRINT N'07 uses 00_common EMP and 05_where_conditions W_CODE';
SELECT COUNT(*) AS w_code_rows FROM w_code;
