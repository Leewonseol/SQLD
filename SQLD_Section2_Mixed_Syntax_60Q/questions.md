# SQLD 20개 절 · SQL 숙어 혼합형 60문제

> 보기의 실행 DBMS는 **Oracle / SQL Server 중 문항마다 랜덤 배정**했습니다. ①에만 SQL Server가 배정되지 않습니다. 문항마다 Oracle 1~3개, SQL Server 1~3개이며 배분 비율도 바뀝니다.

> `[공통 문법]`은 두 DBMS에서 같은 SQL 형태를 쓰는 경우입니다. 오답 선지는 공통 형태라도 오류가 있을 수 있습니다. 해당 보기에도 판정을 위한 실행 환경(Oracle 또는 SQL Server)을 별도로 표시했습니다. `[전용 문법]`은 두 DBMS의 작성 방식이 다른 경우입니다.

> **SQL 기본 8절 + SQL 활용 8절 + 관리 구문 4절 = 20절, 각 절 3문제**. 별도 정답지 제공. 모든 선지는 지정된 실행 환경에서 평가합니다.

> 실습 DB 변경문(DML, TCL, DDL, DCL)은 전용 실습환경에서만 확인하고, 두 DBMS를 서로 바꿔 실행하지 마세요.

## SQL 기본 · 관계형 데이터베이스 개요 (B01)

### 01. PLAYER 릴레이션에 실제 등장하는 TEAM_ID의 중복을 제거하여 조회하는 SQL은?

**숙어:** DISTINCT (중복 제거)

**① [SQL Server · 공통 문법]**
```sql
SELECT COUNT(TEAM_ID) FROM PLAYER;
```

**② [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID FROM PLAYER;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION FROM PLAYER;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT DISTINCT TEAM_ID FROM PLAYER;
```

### 02. NULL을 허용하지 않으면서 PLAYER_ID를 행의 대표 식별자로 선언하는 구문은?

**숙어:** PRIMARY KEY = UNIQUE + NOT NULL

**① [SQL Server · 공통 문법]**
```sql
CREATE TABLE X (PLAYER_ID INTEGER NULL);
```

**② [Oracle · 공통 문법]**
```sql
CREATE TABLE X (PLAYER_ID INTEGER PRIMARY KEY);
```

**③ [SQL Server · 공통 문법]**
```sql
CREATE TABLE X (PLAYER_ID INTEGER REFERENCES X(PLAYER_ID));
```

**④ [Oracle · 공통 문법]**
```sql
CREATE TABLE X (PLAYER_ID INTEGER UNIQUE);
```

### 03. TEAM 테이블을 기준으로 선수 없는 팀(T3)까지 TEAM 행을 보존하는 SQL은?

**숙어:** LEFT OUTER JOIN (기준 행 보존)

**① [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID FROM TEAM T INNER JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID FROM TEAM T LEFT JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT T.TEAM_ID FROM TEAM T JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID WHERE P.PLAYER_ID IS NOT NULL;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID FROM TEAM T WHERE T.TEAM_ID IN (SELECT TEAM_ID FROM PLAYER);
```

## SQL 기본 · SELECT 문 (B02)

### 04. 선수 성적을 표시할 때 SALARY에 10을 더하고 BONUS는 반영하지 않는 계산 열의 SQL은?

**숙어:** 표현식 + 열 별칭

**① [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, SALARY + 10 AS PAY_PLUS_10 FROM PLAYER;
```

**② [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, SALARY - 10 AS PAY_PLUS_10 FROM PLAYER;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, SALARY + BONUS AS PAY_PLUS_10 FROM PLAYER;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, SUM(SALARY) AS PAY_PLUS_10 FROM PLAYER;
```

### 05. PLAYER에서 POSITION의 서로 다른 값 개수를 세되 NULL은 제외하는 SQL은?

**숙어:** COUNT(DISTINCT 컬럼)

**① [SQL Server · 공통 문법]**
```sql
SELECT COUNT(DISTINCT POSITION) FROM PLAYER;
```

**② [Oracle · 공통 문법]**
```sql
SELECT COUNT(*) FROM PLAYER;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT COUNT(POSITION) FROM PLAYER;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT DISTINCT COUNT(*) FROM PLAYER;
```

### 06. 선수별 연봉을 계산한 열 별칭 ANNUAL_PAY를 그대로 출력에 사용할 수 있는 위치는? 아래 SQL 중 올바른 것은?

**숙어:** SELECT 별칭 → ORDER BY 재사용

**① [SQL Server · 공통 문법]**
```sql
SELECT SALARY*12 AS ANNUAL_PAY FROM PLAYER WHERE ANNUAL_PAY > 1000;
```

**② [Oracle · 공통 문법]**
```sql
SELECT SALARY*12 AS ANNUAL_PAY FROM PLAYER GROUP BY ANNUAL_PAY;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT SALARY*12 AS ANNUAL_PAY FROM PLAYER ORDER BY ANNUAL_PAY DESC;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT SALARY*12 AS ANNUAL_PAY FROM PLAYER HAVING ANNUAL_PAY > 1000;
```

## SQL 기본 · 함수 (B03)

### 07. BONUS가 NULL인 선수의 BONUS를 0으로 치환해 조회하는 SQL은?

**숙어:** NULL 치환: NVL / ISNULL / COALESCE

**① [Oracle · 전용 문법]**
```sql
SELECT PLAYER_ID, NVL(BONUS,0) AS B FROM PLAYER;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, COUNT(BONUS) AS B FROM PLAYER;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, NULLIF(BONUS,0) AS B FROM PLAYER;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, BONUS + 0 AS B FROM PLAYER;
```

### 08. PLAYER_NAME의 앞 두 문자를 반환하는 SQL은?

**숙어:** 문자 추출: SUBSTR / SUBSTRING

**① [SQL Server · 전용 문법]**
```sql
SELECT PLAYER_ID, SUBSTRING(PLAYER_NAME,2,2) AS P FROM PLAYER;
```

**② [SQL Server · 전용 문법]**
```sql
SELECT PLAYER_ID, SUBSTRING(PLAYER_NAME,1,2) AS P FROM PLAYER;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, LENGTH(PLAYER_NAME) AS P FROM PLAYER;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, TRIM(PLAYER_NAME) AS P FROM PLAYER;
```

### 09. SALARY가 0인 경우에는 나눗셈을 수행하지 않고 NULL을 내도록 계산하는 SQL은?

**숙어:** NULLIF(0으로 나누기 방지)

**① [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, NULLIF(100,SALARY) AS R FROM PLAYER;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, 100 / SALARY AS R FROM PLAYER;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, COALESCE(SALARY,0) / 100 AS R FROM PLAYER;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, 100 / NULLIF(SALARY,0) AS R FROM PLAYER;
```

## SQL 기본 · WHERE 절 (B04)

### 10. POSITION 정보가 미상(NULL)인 선수만 찾는 SQL은?

**숙어:** IS NULL (NULL 비교)

**① [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE POSITION = NULL;
```

**② [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE POSITION IS NOT NULL;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE POSITION <> NULL;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE POSITION IS NULL;
```

### 11. TEAM_ID가 T1 또는 T2이면서 SALARY가 150 이상인 선수만 찾는 SQL은?

**숙어:** IN + AND (조건 조합)

**① [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE TEAM_ID NOT IN ('T1','T2') AND SALARY >= 150;
```

**② [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE TEAM_ID = 'T1' OR TEAM_ID = 'T2' AND SALARY < 150;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE TEAM_ID IN ('T1','T2') AND SALARY >= 150;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE TEAM_ID IN ('T1','T2') OR SALARY >= 150;
```

### 12. PLAYER_NAME에 문자 '_' 자체가 포함된 행을 찾을 때 올바른 LIKE 숙어는?

**숙어:** LIKE ... ESCAPE (와일드카드 이스케이프)

**① [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE PLAYER_NAME LIKE '%_%';
```

**② [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE PLAYER_NAME LIKE '%_%' ESCAPE '!';
```

**③ [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE PLAYER_NAME LIKE '%!_%';
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE PLAYER_NAME LIKE '%!_%' ESCAPE '!';
```

## SQL 기본 · GROUP BY, HAVING 절 (B05)

### 13. 팀별 GK 수와 전체 선수 수를 출력할 때, 다른 세 보기와 결과가 다른 SQL은? (T1에는 GK 1명, T2에는 GK 0명)

**숙어:** SUM(CASE WHEN ... THEN 1 ELSE 0 END)

**① [Oracle · 전용 문법]**
```sql
SELECT TEAM_ID, NVL(SUM(CASE WHEN POSITION='GK' THEN 1 END),0) GK, COUNT(*) TOTAL FROM PLAYER GROUP BY TEAM_ID;
```

**② [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(CASE WHEN POSITION='GK' THEN 1 ELSE 0 END) GK, COUNT(*) TOTAL FROM PLAYER GROUP BY TEAM_ID;
```

**③ [SQL Server · 전용 문법]**
```sql
SELECT TEAM_ID, ISNULL(SUM(CASE WHEN POSITION='GK' THEN 1 END),0) GK, COUNT(*) TOTAL FROM PLAYER GROUP BY TEAM_ID;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, SUM(CASE WHEN POSITION='GK' THEN 1 ELSE 0 END) GK, COUNT(*) TOTAL FROM PLAYER GROUP BY TEAM_ID;
```

### 14. 팀별 선수 수가 3명 이상인 팀만 조회하는 SQL은?

**숙어:** GROUP BY + HAVING COUNT(*)

**① [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(*) N FROM PLAYER HAVING COUNT(*) >= 3;
```

**② [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(*) N FROM PLAYER GROUP BY TEAM_ID HAVING COUNT(*) >= 3;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(*) N FROM PLAYER WHERE COUNT(*) >= 3 GROUP BY TEAM_ID;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(*) N FROM PLAYER GROUP BY TEAM_ID HAVING PLAYER_ID >= 3;
```

### 15. 팀·포지션별 인원수를 모두 구하는 SQL은?

**숙어:** 다중 GROUP BY

**① [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION, COUNT(*) N FROM PLAYER GROUP BY TEAM_ID;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION, COUNT(*) N FROM PLAYER;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION, COUNT(*) N FROM PLAYER GROUP BY POSITION;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION, COUNT(*) N FROM PLAYER GROUP BY TEAM_ID, POSITION;
```

## SQL 기본 · ORDER BY 절 (B06)

### 16. 연봉 내림차순, 동률이면 선수 번호 오름차순으로 정렬하는 SQL은?

**숙어:** 다중 ORDER BY + 안정적 동률 처리

**① [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY SALARY ASC, PLAYER_ID ASC;
```

**② [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY SALARY DESC, PLAYER_ID ASC;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY SALARY DESC, PLAYER_ID DESC;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY PLAYER_ID ASC, SALARY DESC;
```

### 17. POSITION을 FW→MF→DF→GK→기타 순서로 정렬하는 SQL은?

**숙어:** ORDER BY CASE (사용자 지정 순서)

**① [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY POSITION, PLAYER_ID;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY CASE POSITION WHEN 'FW' THEN 1 WHEN 'MF' THEN 2 WHEN 'DF' THEN 3 WHEN 'GK' THEN 4 ELSE 5 END, PLAYER_ID;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY SALARY DESC, PLAYER_ID;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY CASE POSITION WHEN 'FW' THEN 4 WHEN 'MF' THEN 3 WHEN 'DF' THEN 2 WHEN 'GK' THEN 1 ELSE 5 END, PLAYER_ID;
```

### 18. BONUS가 NULL인 선수는 가장 뒤로, 나머지는 BONUS 오름차순으로 조회하는 이식성 높은 SQL은?

**숙어:** ORDER BY CASE WHEN ... IS NULL (NULL 위치)

**① [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY CASE WHEN BONUS IS NULL THEN 0 ELSE 1 END, BONUS ASC, PLAYER_ID;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY CASE WHEN BONUS IS NULL THEN 1 ELSE 0 END, BONUS ASC, PLAYER_ID;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY BONUS ASC, PLAYER_ID;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER ORDER BY BONUS DESC, PLAYER_ID;
```

## SQL 기본 · 조인 (B07)

### 19. 선수가 없는 팀도 남긴 상태에서 TEAM_ID별 실제 선수 수를 계산하는 SQL은?

**숙어:** LEFT JOIN + COUNT(우측 PK)

**① [Oracle · 공통 문법]**
```sql
SELECT T.TEAM_ID, COUNT(P.PLAYER_ID) N FROM TEAM T LEFT JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID WHERE P.PLAYER_ID IS NOT NULL GROUP BY T.TEAM_ID;
```

**② [Oracle · 공통 문법]**
```sql
SELECT T.TEAM_ID, COUNT(P.PLAYER_ID) N FROM TEAM T INNER JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID GROUP BY T.TEAM_ID;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID, COUNT(*) N FROM TEAM T LEFT JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID GROUP BY T.TEAM_ID;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT T.TEAM_ID, COUNT(P.PLAYER_ID) N FROM TEAM T LEFT JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID GROUP BY T.TEAM_ID;
```

### 20. T2의 선수만 매칭하되 모든 TEAM 행은 보존하는 SQL은?

**숙어:** OUTER JOIN 필터 ON / WHERE 구분

**① [Oracle · 공통 문법]**
```sql
SELECT T.TEAM_ID,P.PLAYER_ID FROM TEAM T INNER JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID AND P.TEAM_ID='T2';
```

**② [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID,P.PLAYER_ID FROM TEAM T JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID WHERE P.TEAM_ID='T2';
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID,P.PLAYER_ID FROM TEAM T LEFT JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID AND P.TEAM_ID='T2';
```

**④ [Oracle · 공통 문법]**
```sql
SELECT T.TEAM_ID,P.PLAYER_ID FROM TEAM T LEFT JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID WHERE P.TEAM_ID='T2';
```

### 21. 선수가 한 명도 없는 TEAM의 TEAM_ID만 반환하는 SQL은?

**숙어:** NOT EXISTS (안티 세미 조인)

**① [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID FROM TEAM T WHERE T.TEAM_ID IN (SELECT TEAM_ID FROM PLAYER);
```

**② [Oracle · 공통 문법]**
```sql
SELECT T.TEAM_ID FROM TEAM T WHERE EXISTS (SELECT 1 FROM PLAYER P WHERE P.TEAM_ID=T.TEAM_ID);
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID FROM TEAM T WHERE NOT EXISTS (SELECT 1 FROM PLAYER P WHERE P.TEAM_ID=T.TEAM_ID);
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID FROM TEAM T INNER JOIN PLAYER P ON P.TEAM_ID=T.TEAM_ID;
```

## SQL 기본 · 표준 조인 (B08)

### 22. TEAM×DEPT의 모든 조합(3×3=9행)을 생성하는 ANSI 표준 SQL은?

**숙어:** CROSS JOIN (데카르트 곱)

**① [Oracle · 공통 문법]**
```sql
SELECT * FROM TEAM INNER JOIN DEPT ON TEAM.TEAM_ID=CAST(DEPT.DEPT_ID AS VARCHAR(4));
```

**② [SQL Server · 공통 문법]**
```sql
SELECT * FROM TEAM CROSS JOIN DEPT;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT * FROM TEAM LEFT JOIN DEPT ON TEAM.TEAM_ID=CAST(DEPT.DEPT_ID AS VARCHAR(4));
```

**④ [Oracle · 공통 문법]**
```sql
SELECT * FROM TEAM FULL OUTER JOIN DEPT ON TEAM.TEAM_ID=CAST(DEPT.DEPT_ID AS VARCHAR(4));
```

### 23. 팀과 선수의 일치 행만 얻는 ANSI 표준 내부 조인 SQL은?

**숙어:** INNER JOIN ... ON (표준 조인)

**① [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID, P.PLAYER_ID FROM TEAM T FULL OUTER JOIN PLAYER P ON T.TEAM_ID=P.TEAM_ID;
```

**② [Oracle · 공통 문법]**
```sql
SELECT T.TEAM_ID, P.PLAYER_ID FROM TEAM T LEFT JOIN PLAYER P ON T.TEAM_ID=P.TEAM_ID;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT T.TEAM_ID, P.PLAYER_ID FROM TEAM T CROSS JOIN PLAYER P;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT T.TEAM_ID, P.PLAYER_ID FROM TEAM T INNER JOIN PLAYER P ON T.TEAM_ID=P.TEAM_ID;
```

### 24. TEAM과 PLAYER에서 TEAM_ID가 일치하는 행만 조회하는 SQL은? (보기별 DBMS 문법 기준)

**숙어:** USING / ON (DBMS 표준 지원 차이)

**① [SQL Server · 전용 문법]**
```sql
SELECT T.TEAM_ID, P.PLAYER_ID FROM TEAM T LEFT JOIN PLAYER P ON T.TEAM_ID=P.TEAM_ID;
```

**② [Oracle · 전용 문법]**
```sql
SELECT TEAM_ID, PLAYER_ID FROM TEAM CROSS JOIN PLAYER;
```

**③ [SQL Server · 전용 문법]**
```sql
SELECT T.TEAM_ID, P.PLAYER_ID FROM TEAM T FULL OUTER JOIN PLAYER P ON T.TEAM_ID=P.TEAM_ID;
```

**④ [SQL Server · 전용 문법]**
```sql
SELECT T.TEAM_ID, P.PLAYER_ID FROM TEAM T INNER JOIN PLAYER P ON T.TEAM_ID=P.TEAM_ID;
```

## SQL 활용 · 서브 쿼리 (A01)

### 25. PLAYER 중 전체 선수의 평균 SALARY보다 연봉이 높은 사람만 조회하는 SQL은?

**숙어:** 비연관 스칼라 서브쿼리

**① [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE SALARY > (SELECT AVG(SALARY) FROM PLAYER);
```

**② [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE SALARY > (SELECT SALARY FROM PLAYER);
```

**③ [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE SALARY < (SELECT AVG(SALARY) FROM PLAYER);
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE SALARY > AVG(SALARY);
```

### 26. 한 번 이상 주문한 고객만 중복 없이 찾는 SQL은?

**숙어:** 상관 EXISTS (존재 여부)

**① [Oracle · 공통 문법]**
```sql
SELECT C.CUSTOMER_ID FROM CUSTOMER C WHERE NOT EXISTS (SELECT 1 FROM ORDERS O WHERE O.CUSTOMER_ID=C.CUSTOMER_ID);
```

**② [SQL Server · 공통 문법]**
```sql
SELECT C.CUSTOMER_ID FROM CUSTOMER C CROSS JOIN ORDERS O;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT C.CUSTOMER_ID FROM CUSTOMER C WHERE C.CUSTOMER_ID = (SELECT CUSTOMER_ID FROM ORDERS);
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT C.CUSTOMER_ID FROM CUSTOMER C WHERE EXISTS (SELECT 1 FROM ORDERS O WHERE O.CUSTOMER_ID=C.CUSTOMER_ID);
```

### 27. 모든 T1 선수의 연봉보다 더 높은 연봉을 가진 선수만 찾는 SQL은?

**숙어:** > ALL (전체 비교)

**① [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE SALARY > ANY (SELECT SALARY FROM PLAYER WHERE TEAM_ID='T1');
```

**② [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE SALARY > ALL (SELECT SALARY FROM PLAYER WHERE TEAM_ID='T1');
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE SALARY < ALL (SELECT SALARY FROM PLAYER WHERE TEAM_ID='T1');
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE SALARY IN (SELECT SALARY FROM PLAYER WHERE TEAM_ID='T1');
```

## SQL 활용 · 집합 연산자 (A02)

### 28. PLAYER에서 TEAM_ID가 T1이거나 T2인 행을 조회하여 팀 목록을 합치되 중복은 제거하는 SQL은?

**숙어:** UNION vs UNION ALL

**① [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID FROM PLAYER WHERE TEAM_ID='T1' UNION SELECT TEAM_ID FROM PLAYER WHERE TEAM_ID='T2';
```

**② [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID FROM PLAYER WHERE TEAM_ID='T1' UNION ALL SELECT TEAM_ID FROM PLAYER WHERE TEAM_ID='T2';
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID FROM PLAYER WHERE TEAM_ID='T1' INTERSECT SELECT TEAM_ID FROM PLAYER WHERE TEAM_ID='T2';
```

**④ [Oracle · 전용 문법]**
```sql
SELECT TEAM_ID FROM PLAYER WHERE TEAM_ID='T1' MINUS SELECT TEAM_ID FROM PLAYER WHERE TEAM_ID='T2';
```

### 29. TEAM에는 있으나 PLAYER에는 나타나지 않는 TEAM_ID를 집합 차로 구하는 SQL은?

**숙어:** MINUS / EXCEPT (차집합)

**① [Oracle · 전용 문법]**
```sql
SELECT TEAM_ID FROM TEAM MINUS SELECT TEAM_ID FROM PLAYER;
```

**② [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID FROM TEAM UNION SELECT TEAM_ID FROM PLAYER;
```

**③ [SQL Server · 전용 문법]**
```sql
SELECT TEAM_ID FROM PLAYER EXCEPT SELECT TEAM_ID FROM TEAM;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID FROM TEAM INTERSECT SELECT TEAM_ID FROM PLAYER;
```

### 30. PLAYER와 TEAM 양쪽에 등장하는 TEAM_ID만 반환하는 SQL은?

**숙어:** INTERSECT (교집합)

**① [SQL Server · 전용 문법]**
```sql
SELECT TEAM_ID FROM TEAM EXCEPT SELECT TEAM_ID FROM PLAYER;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID FROM TEAM INTERSECT SELECT TEAM_ID FROM PLAYER;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID FROM TEAM UNION ALL SELECT TEAM_ID FROM PLAYER;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID FROM TEAM UNION SELECT TEAM_ID FROM PLAYER;
```

## SQL 활용 · 그룹 함수 (A03)

### 31. 팀별 인원수와 전체 인원수를 한 번에 조회하는 GROUPING SETS는?

**숙어:** GROUPING SETS ((TEAM_ID), ())

**① [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(*) N FROM PLAYER GROUP BY TEAM_ID, POSITION;
```

**② [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(*) N FROM PLAYER GROUP BY TEAM_ID;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(*) N FROM PLAYER GROUP BY GROUPING SETS ((TEAM_ID), ());
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(*) N FROM PLAYER GROUP BY POSITION;
```

### 32. TEAM_ID→POSITION 단계별 소계와 전체 총계를 함께 구하는 SQL은?

**숙어:** ROLLUP(TEAM_ID, POSITION)

**① [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION, COUNT(*) N FROM PLAYER GROUP BY ROLLUP(TEAM_ID,POSITION);
```

**② [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION, COUNT(*) N FROM PLAYER GROUP BY TEAM_ID,POSITION;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION, COUNT(*) N FROM PLAYER GROUP BY CUBE(TEAM_ID,POSITION);
```

**④ [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION, COUNT(*) N FROM PLAYER GROUP BY ROLLUP(POSITION);
```

### 33. GROUPING SETS의 전체 총계 행을 실제 TEAM_ID NULL 값과 구별하는 표현식은?

**숙어:** GROUPING(TEAM_ID) (집계 레벨 판별)

**① [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(TEAM_ID) AS G, COUNT(*) N FROM PLAYER GROUP BY GROUPING SETS((TEAM_ID),());
```

**② [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, GROUPING(TEAM_ID) AS G, COUNT(*) N FROM PLAYER GROUP BY GROUPING SETS((TEAM_ID),());
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, COALESCE(TEAM_ID,'TOTAL') AS G, COUNT(*) N FROM PLAYER GROUP BY TEAM_ID;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, COUNT(*) AS G FROM PLAYER GROUP BY TEAM_ID;
```

## SQL 활용 · 윈도우 함수 (A04)

### 34. 팀별 SALARY 내림차순으로 선수에게 유일한 순번을 붙이되 같은 연봉이면 PLAYER_ID 오름차순을 적용하는 SQL은?

**숙어:** ROW_NUMBER() OVER(PARTITION BY ... ORDER BY ...)

**① [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, DENSE_RANK() OVER(PARTITION BY TEAM_ID ORDER BY SALARY DESC) RN FROM PLAYER;
```

**② [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, RANK() OVER(PARTITION BY TEAM_ID ORDER BY SALARY DESC) RN FROM PLAYER;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, ROW_NUMBER() OVER(PARTITION BY TEAM_ID ORDER BY SALARY DESC, PLAYER_ID) RN FROM PLAYER;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, ROW_NUMBER() OVER(ORDER BY SALARY DESC, PLAYER_ID) RN FROM PLAYER;
```

### 35. 팀별 연봉순 등수에서 동률 뒤 순위를 건너뛰지 않으려면?

**숙어:** DENSE_RANK vs RANK

**① [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, DENSE_RANK() OVER(PARTITION BY TEAM_ID ORDER BY SALARY DESC) RK FROM PLAYER;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, COUNT(*) OVER(PARTITION BY TEAM_ID) RK FROM PLAYER;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, RANK() OVER(PARTITION BY TEAM_ID ORDER BY SALARY DESC) RK FROM PLAYER;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, ROW_NUMBER() OVER(PARTITION BY TEAM_ID ORDER BY SALARY DESC) RK FROM PLAYER;
```

### 36. 선수 번호순으로 팀별 연봉 누계를 명시적 ROWS 프레임으로 구하는 SQL은?

**숙어:** SUM(...) OVER(... ROWS UNBOUNDED PRECEDING)

**① [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, AVG(SALARY) OVER(PARTITION BY TEAM_ID ORDER BY PLAYER_ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) RUNNING_PAY FROM PLAYER;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, SUM(SALARY) OVER(ORDER BY PLAYER_ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) RUNNING_PAY FROM PLAYER;
```

**③ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID, SUM(SALARY) OVER(PARTITION BY TEAM_ID ORDER BY PLAYER_ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) RUNNING_PAY FROM PLAYER;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID, SUM(SALARY) OVER(PARTITION BY TEAM_ID) RUNNING_PAY FROM PLAYER;
```

## SQL 활용 · Top N 쿼리 (A05)

### 37. 전체 선수 중 SALARY 최고 3명(동률은 PLAYER_ID 오름차순)의 정확히 3행을 반환하는 SQL은?

**숙어:** TOP / FETCH FIRST + ORDER BY

**① [Oracle · 전용 문법]**
```sql
SELECT PLAYER_ID,SALARY FROM PLAYER ORDER BY SALARY DESC, PLAYER_ID FETCH FIRST 1 ROW WITH TIES;
```

**② [Oracle · 전용 문법]**
```sql
SELECT PLAYER_ID,SALARY FROM PLAYER FETCH FIRST 3 ROWS ONLY;
```

**③ [SQL Server · 전용 문법]**
```sql
SELECT TOP (3) PLAYER_ID,SALARY FROM PLAYER ORDER BY SALARY ASC, PLAYER_ID;
```

**④ [Oracle · 전용 문법]**
```sql
SELECT PLAYER_ID,SALARY FROM PLAYER ORDER BY SALARY DESC, PLAYER_ID FETCH FIRST 3 ROWS ONLY;
```

### 38. SALARY 내림차순, PLAYER_ID 오름차순으로 정렬된 결과에서 4~6번째 행을 반환하는 SQL은?

**숙어:** OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY

**① [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID FROM PLAYER ORDER BY SALARY DESC,PLAYER_ID OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY;
```

**② [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID FROM PLAYER ORDER BY SALARY DESC,PLAYER_ID OFFSET 3 ROWS FETCH NEXT 4 ROWS ONLY;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID FROM PLAYER ORDER BY SALARY DESC,PLAYER_ID OFFSET 4 ROWS FETCH NEXT 3 ROWS ONLY;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID FROM PLAYER ORDER BY SALARY DESC,PLAYER_ID FETCH FIRST 3 ROWS ONLY;
```

### 39. 팀별 가장 연봉이 높은 선수 1명씩을 결정적으로 선택하는 SQL은?

**숙어:** ROW_NUMBER + WHERE RN=1 (그룹별 Top1)

**① [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID,TEAM_ID FROM (SELECT P.*,RANK() OVER(PARTITION BY TEAM_ID ORDER BY SALARY DESC) RN FROM PLAYER P) X WHERE RN=1;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID,TEAM_ID FROM PLAYER WHERE SALARY=(SELECT MAX(SALARY) FROM PLAYER);
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID,TEAM_ID FROM (SELECT P.*,ROW_NUMBER() OVER(PARTITION BY TEAM_ID ORDER BY SALARY DESC,PLAYER_ID) RN FROM PLAYER P) X WHERE RN=1;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID,TEAM_ID FROM (SELECT P.*,ROW_NUMBER() OVER(ORDER BY SALARY DESC,PLAYER_ID) RN FROM PLAYER P) X WHERE RN=1;
```

## SQL 활용 · 계층형 질의와 셀프 조인 (A06)

### 40. PLAYER.MANAGER_ID가 가리키는 상사의 이름을 선수와 함께 표시하는 SQL은?

**숙어:** SELF JOIN (자기참조)

**① [Oracle · 공통 문법]**
```sql
SELECT P.PLAYER_NAME, M.PLAYER_NAME MANAGER_NAME FROM PLAYER P LEFT JOIN PLAYER M ON P.MANAGER_ID=M.PLAYER_ID;
```

**② [Oracle · 공통 문법]**
```sql
SELECT P.PLAYER_NAME, M.PLAYER_NAME MANAGER_NAME FROM PLAYER P INNER JOIN PLAYER M ON P.MANAGER_ID=M.PLAYER_ID;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT P.PLAYER_NAME, M.PLAYER_NAME MANAGER_NAME FROM PLAYER P CROSS JOIN PLAYER M;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT P.PLAYER_NAME, M.PLAYER_NAME MANAGER_NAME FROM PLAYER P LEFT JOIN PLAYER M ON P.PLAYER_ID=M.PLAYER_ID;
```

### 41. MANAGER_ID가 NULL인 루트부터 아래로 내려가는 계층을 1부터 표시하는 SQL은?
**숙어:** CONNECT BY PRIOR / 재귀 CTE

**① [SQL Server · 전용 문법]**
```sql
WITH H AS (SELECT PLAYER_ID,MANAGER_ID,1 AS LV FROM PLAYER WHERE MANAGER_ID IS NOT NULL UNION ALL SELECT P.PLAYER_ID,P.MANAGER_ID,H.LV+1 FROM PLAYER P JOIN H ON P.MANAGER_ID=H.PLAYER_ID) SELECT * FROM H;
```

**② [Oracle · 전용 문법]**
```sql
SELECT PLAYER_ID, MANAGER_ID, LEVEL LV FROM PLAYER START WITH MANAGER_ID IS NULL CONNECT BY PRIOR MANAGER_ID=PLAYER_ID;
```

**③ [SQL Server · 전용 문법]**
```sql
SELECT PLAYER_ID,MANAGER_ID,1 LV FROM PLAYER WHERE MANAGER_ID IS NULL;
```

**④ [Oracle · 전용 문법]**
```sql
SELECT PLAYER_ID, MANAGER_ID, LEVEL LV FROM PLAYER START WITH MANAGER_ID IS NULL CONNECT BY PRIOR PLAYER_ID=MANAGER_ID;
```

### 42. 직속 상사 PLAYER_ID가 1인 선수만 찾는 (재귀 없이 한 단계) SQL은?

**숙어:** Adjacency list (부모 참조 FK)

**① [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID FROM PLAYER WHERE MANAGER_ID<>1;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID FROM PLAYER WHERE PLAYER_ID=1;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT PLAYER_ID FROM PLAYER WHERE MANAGER_ID=1;
```

**④ [Oracle · 공통 문법]**
```sql
SELECT PLAYER_ID FROM PLAYER WHERE MANAGER_ID IS NULL;
```

## SQL 활용 · PIVOT 절과 UNPIVOT 절 (A07)

### 43. TEAM_ID별 FW/MF 선수 수를 두 열로 펼치는 올바른 PIVOT SQL은?

**숙어:** PIVOT (행의 범주→열)

**① [Oracle · 전용 문법]**
```sql
SELECT * FROM (SELECT TEAM_ID,POSITION,PLAYER_ID FROM PLAYER) S PIVOT (SUM(POSITION) FOR PLAYER_ID IN ('FW' AS FW,'MF' AS MF));
```

**② [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID,COUNT(*) FW,COUNT(*) MF FROM PLAYER GROUP BY TEAM_ID;
```

**③ [Oracle · 전용 문법]**
```sql
SELECT * FROM (SELECT TEAM_ID,POSITION,PLAYER_ID FROM PLAYER) S PIVOT (COUNT(PLAYER_ID) FOR POSITION IN ('FW' AS FW,'MF' AS MF));
```

**④ [SQL Server · 전용 문법]**
```sql
SELECT TEAM_ID,POSITION FROM PLAYER UNPIVOT (PLAYER_ID FOR POSITION IN ([FW],[MF])) U;
```

### 44. 두 열 FW, MF가 있는 WIDE_COUNTS에서 이를 POSITION, CNT 두 열로 세로 변환하는 SQL은?

**숙어:** UNPIVOT (열→행)

**① [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID, FW, MF FROM WIDE_COUNTS;
```

**② [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION, CNT FROM WIDE_COUNTS PIVOT (COUNT(CNT) FOR POSITION IN (FW,MF));
```

**③ [Oracle · 전용 문법]**
```sql
SELECT TEAM_ID, POSITION, CNT FROM WIDE_COUNTS UNPIVOT (CNT FOR POSITION IN (FW,MF)) U;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID, POSITION, CNT FROM WIDE_COUNTS CROSS JOIN TEAM;
```

### 45. PIVOT 없이 조건부 집계로 TEAM_ID별 FW/MF 선수 수를 두 열로 만드는 SQL은?

**숙어:** 조건부 집계 = 정적 PIVOT 대안

**① [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID,COUNT(CASE WHEN POSITION='FW' THEN 1 ELSE 0 END) FW,COUNT(CASE WHEN POSITION='MF' THEN 1 ELSE 0 END) MF FROM PLAYER GROUP BY TEAM_ID;
```

**② [Oracle · 공통 문법]**
```sql
SELECT TEAM_ID,POSITION,COUNT(*) FW FROM PLAYER GROUP BY TEAM_ID,POSITION;
```

**③ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID,SUM(CASE WHEN POSITION='FW' THEN 1 ELSE 0 END) FW,SUM(CASE WHEN POSITION='MF' THEN 1 ELSE 0 END) MF FROM PLAYER GROUP BY TEAM_ID;
```

**④ [SQL Server · 공통 문법]**
```sql
SELECT TEAM_ID,COUNT(*) FW,COUNT(*) MF FROM PLAYER GROUP BY TEAM_ID;
```

## SQL 활용 · 정규 표현식 (A08)

### 46. PLAYER_NAME이 대문자 A로 시작하는 선수만 찾는 SQL은? (Oracle 정규식 / SQL Server LIKE 패턴)

**숙어:** REGEXP_LIKE / LIKE (패턴 매칭)

**① [Oracle · 공통 문법]**
```sql
SELECT * FROM PLAYER WHERE PLAYER_NAME='A';
```

**② [Oracle · 전용 문법]**
```sql
SELECT * FROM PLAYER WHERE REGEXP_LIKE(PLAYER_NAME,'^A');
```

**③ [Oracle · 전용 문법]**
```sql
SELECT * FROM PLAYER WHERE REGEXP_LIKE(PLAYER_NAME,'^Z');
```

**④ [SQL Server · 전용 문법]**
```sql
SELECT * FROM PLAYER WHERE PLAYER_NAME COLLATE Latin1_General_100_BIN2 LIKE '%A';
```

### 47. PLAYER_NAME이 알파벳 대문자로만 이루어진 (1자 이상) 문자열인 행만 찾는 SQL은?

**숙어:** ^...+$ / 부정 문자 클래스 찾기

**① [SQL Server · 전용 문법]**
```sql
SELECT * FROM PLAYER WHERE PLAYER_NAME COLLATE Latin1_General_100_BIN2 LIKE '%[a-z]%';
```

**② [SQL Server · 전용 문법]**
```sql
SELECT * FROM PLAYER WHERE PLAYER_NAME COLLATE Latin1_General_100_BIN2 NOT LIKE '%[^A-Z]%' AND PLAYER_NAME<>'';
```

**③ [Oracle · 전용 문법]**
```sql
SELECT * FROM PLAYER WHERE REGEXP_LIKE(PLAYER_NAME,'[A-Z]');
```

**④ [Oracle · 전용 문법]**
```sql
SELECT * FROM PLAYER WHERE REGEXP_LIKE(PLAYER_NAME,'^[0-9]+$');
```

### 48. 문자열에 숫자가 연속 두 자리 이상 들어있는지 판단하는 SQL은?

**숙어:** {2,} 수량자 / LIKE 숫자 클래스 2회

**① [Oracle · 전용 문법]**
```sql
SELECT * FROM CUSTOMER WHERE REGEXP_LIKE(CUSTOMER_NAME,'[0-9]');
```

**② [SQL Server · 전용 문법]**
```sql
SELECT * FROM CUSTOMER WHERE CUSTOMER_NAME COLLATE Latin1_General_100_BIN2 LIKE '[A-Z]%';
```

**③ [SQL Server · 전용 문법]**
```sql
SELECT * FROM CUSTOMER WHERE CUSTOMER_NAME COLLATE Latin1_General_100_BIN2 LIKE '%[0-9][0-9]%';
```

**④ [SQL Server · 전용 문법]**
```sql
SELECT * FROM CUSTOMER WHERE CUSTOMER_NAME COLLATE Latin1_General_100_BIN2 LIKE '[0-9]';
```

## 관리 구문 · DML (M01)

### 49. SALARY가 150 미만인 선수의 BONUS를 0으로 바꾸되 나머지 선수는 유지하는 구문은?

**숙어:** UPDATE ... SET ... WHERE

**① [Oracle · 공통 문법]**
```sql
DELETE FROM PLAYER WHERE SALARY<150;
```

**② [SQL Server · 공통 문법]**
```sql
UPDATE PLAYER SET SALARY=0 WHERE BONUS<150;
```

**③ [Oracle · 공통 문법]**
```sql
UPDATE PLAYER SET BONUS=0;
```

**④ [Oracle · 공통 문법]**
```sql
UPDATE PLAYER SET BONUS=0 WHERE SALARY<150;
```

*실행 주의: 변경형 SQL: 연습 시 트랜잭션 내 실행 후 ROLLBACK 권장*

### 50. TEAM 테이블에서 선수가 없는 T3에 대해 PLAYER 테이블을 변경하지 않고 해당 팀을 삭제하는 문장은?

**숙어:** DELETE ... WHERE + NOT EXISTS

**① [SQL Server · 공통 문법]**
```sql
DELETE FROM PLAYER WHERE TEAM_ID='T3';
```

**② [Oracle · 공통 문법]**
```sql
DELETE FROM TEAM WHERE TEAM_ID='T1';
```

**③ [Oracle · 공통 문법]**
```sql
DELETE FROM TEAM WHERE TEAM_ID='T3' AND NOT EXISTS (SELECT 1 FROM PLAYER WHERE PLAYER.TEAM_ID=TEAM.TEAM_ID);
```

**④ [SQL Server · 공통 문법]**
```sql
UPDATE TEAM SET TEAM_ID='T3' WHERE TEAM_ID='T1';
```

*실행 주의: 변경형 SQL: 데이터 보존하려면 테스트 후 ROLLBACK*

### 51. 다른 테이블에서 가져온 값으로 신규 팀을 하나 삽입하는 INSERT ... SELECT 숙어는?

**숙어:** INSERT INTO ... SELECT

**① [SQL Server · 공통 문법]**
```sql
INSERT INTO TEAM (TEAM_ID,TEAM_NAME) SELECT 'T4','TEST' FROM TEAM WHERE TEAM_ID='T3';
```

**② [Oracle · 공통 문법]**
```sql
UPDATE TEAM SET TEAM_ID='T4' WHERE TEAM_ID='T3';
```

**③ [SQL Server · 공통 문법]**
```sql
INSERT INTO TEAM (TEAM_ID) SELECT TEAM_ID FROM TEAM WHERE TEAM_ID='T1';
```

**④ [SQL Server · 공통 문법]**
```sql
INSERT INTO TEAM (TEAM_ID,TEAM_NAME) VALUES (SELECT 'T4','TEST' FROM TEAM WHERE TEAM_ID='T3');
```

*실행 주의: 변경형 SQL: 반복 실행 시 PK 중복 발생 가능*

## 관리 구문 · TCL (M02)

### 52. UPDATE 후 되돌릴 여지를 남긴 채 명시적으로 트랜잭션을 종료하지 않는 순서는?

**숙어:** 트랜잭션 시작 + UPDATE (미확정 상태)

**① [Oracle · 전용 문법]**
```sql
SAVEPOINT SP1; UPDATE PLAYER SET BONUS=0 WHERE PLAYER_ID=1;
```

**② [SQL Server · 전용 문법]**
```sql
BEGIN TRANSACTION; UPDATE PLAYER SET BONUS=0 WHERE PLAYER_ID=1; COMMIT TRANSACTION;
```

**③ [Oracle · 전용 문법]**
```sql
UPDATE PLAYER SET BONUS=0 WHERE PLAYER_ID=1; COMMIT; ROLLBACK;
```

**④ [Oracle · 전용 문법]**
```sql
UPDATE PLAYER SET BONUS=0 WHERE PLAYER_ID=1; ROLLBACK;
```

*실행 주의: ③ 실행 시 열린 트랜잭션을 반드시 ROLLBACK하여 종료할 것*

### 53. 저장점 SP1이 설정된 트랜잭션에서 전체가 아니라 SP1 뒤의 변경만 취소하는 문장은?

**숙어:** SAVEPOINT + ROLLBACK TO

**① [Oracle · 전용 문법]**
```sql
ROLLBACK;
```

**② [SQL Server · 전용 문법]**
```sql
COMMIT TRANSACTION;
```

**③ [SQL Server · 전용 문법]**
```sql
SAVE TRANSACTION SP2;
```

**④ [Oracle · 전용 문법]**
```sql
ROLLBACK TO SP1;
```

### 54. 하나의 트랜잭션에서 모든 변경을 확정하는 문장은?

**숙어:** COMMIT (변경 확정)

**① [SQL Server · 공통 문법]**
```sql
SELECT * FROM PLAYER;
```

**② [Oracle · 전용 문법]**
```sql
SAVEPOINT SP1;
```

**③ [SQL Server · 전용 문법]**
```sql
ROLLBACK TRANSACTION;
```

**④ [SQL Server · 전용 문법]**
```sql
COMMIT TRANSACTION;
```

## 관리 구문 · DDL (M03)

### 55. ID가 기본키이고 V가 NULL 불가인 실습 테이블을 생성하는 DDL은?

**숙어:** CREATE TABLE + PK + NOT NULL

**① [Oracle · 공통 문법]**
```sql
CREATE TABLE DDL_LAB (ID INTEGER PRIMARY KEY, V INTEGER NOT NULL);
```

**② [Oracle · 공통 문법]**
```sql
CREATE TABLE DDL_LAB (ID INTEGER UNIQUE, V INTEGER);
```

**③ [Oracle · 공통 문법]**
```sql
CREATE TABLE DDL_LAB (ID INTEGER, V INTEGER);
```

**④ [SQL Server · 공통 문법]**
```sql
CREATE TABLE DDL_LAB (ID INTEGER, V INTEGER NULL);
```

*실행 주의: 반복 생성 시 DROP TABLE DDL_LAB 후 재실행*

### 56. 기존 TEAM과 참조 무결성을 유지하는 FK를 가진 테이블을 만드는 SQL은?

**숙어:** FOREIGN KEY ... REFERENCES

**① [SQL Server · 전용 문법]**
```sql
CREATE TABLE FK_LAB (ID INTEGER PRIMARY KEY, TEAM_ID VARCHAR(4));
```

**② [Oracle · 전용 문법]**
```sql
CREATE TABLE FK_LAB (ID NUMBER PRIMARY KEY, TEAM_ID VARCHAR2(4) NOT NULL);
```

**③ [Oracle · 전용 문법]**
```sql
CREATE TABLE FK_LAB (ID NUMBER PRIMARY KEY, TEAM_ID VARCHAR2(4) REFERENCES TEAM(TEAM_ID));
```

**④ [SQL Server · 전용 문법]**
```sql
CREATE TABLE FK_LAB (ID INTEGER PRIMARY KEY, TEAM_ID VARCHAR(4) UNIQUE);
```

*실행 주의: 반복 생성 시 DROP TABLE FK_LAB 후 재실행*

### 57. 기존 TEAM에 길이 20의 REGION 열을 추가하는 DDL은?

**숙어:** ALTER TABLE ... ADD (새 열)

**① [SQL Server · 공통 문법]**
```sql
UPDATE TEAM SET REGION=NULL;
```

**② [SQL Server · 전용 문법]**
```sql
ALTER TABLE TEAM ADD REGION VARCHAR(20);
```

**③ [SQL Server · 공통 문법]**
```sql
ALTER TABLE TEAM DROP COLUMN REGION;
```

**④ [Oracle · 전용 문법]**
```sql
ALTER TABLE TEAM ADD (TEAM_ID VARCHAR2(20));
```

*실행 주의: DDL은 실제 스키마 변경. Oracle DDL 전후 암묵 COMMIT에 주의*

## 관리 구문 · DCL (M04)

### 58. 이미 존재하는 사용자/역할 REPORT_READER에게 TEAM의 SELECT 권한만 부여하는 구문은?

**숙어:** GRANT SELECT ON ... TO ...

**① [Oracle · 공통 문법]**
```sql
GRANT SELECT ON TEAM TO REPORT_READER;
```

**② [SQL Server · 공통 문법]**
```sql
GRANT ALL ON TEAM TO REPORT_READER;
```

**③ [Oracle · 공통 문법]**
```sql
REVOKE SELECT ON TEAM FROM REPORT_READER;
```

**④ [Oracle · 공통 문법]**
```sql
GRANT INSERT ON TEAM TO REPORT_READER;
```

*실행 주의: REPORT_READER 계정/역할 및 권한 부여 권한이 사전에 있어야 함*

### 59. REPORT_READER에게 부여했던 TEAM 읽기 권한을 회수하는 구문은?

**숙어:** REVOKE SELECT ON ... FROM ...

**① [Oracle · 공통 문법]**
```sql
REVOKE SELECT ON TEAM FROM REPORT_READER;
```

**② [SQL Server · 공통 문법]**
```sql
GRANT SELECT ON TEAM TO REPORT_READER;
```

**③ [SQL Server · 공통 문법]**
```sql
COMMIT;
```

**④ [Oracle · 공통 문법]**
```sql
GRANT DELETE ON TEAM TO REPORT_READER;
```

*실행 주의: 계정·역할 존재 및 권한 필요*

### 60. 이미 존재하는 사용자 REPORT_READER에게 TEAM SELECT를 부여하면서 다른 사용자에게 재부여할 권한도 주는 SQL은?

**숙어:** GRANT ... WITH GRANT OPTION

**① [SQL Server · 전용 문법]**
```sql
GRANT SELECT ON OBJECT::dbo.TEAM TO REPORT_READER AS dbo;
```

**② [SQL Server · 전용 문법]**
```sql
GRANT SELECT ON OBJECT::dbo.TEAM TO REPORT_READER;
```

**③ [Oracle · 전용 문법]**
```sql
REVOKE SELECT ON TEAM FROM REPORT_READER;
```

**④ [SQL Server · 전용 문법]**
```sql
GRANT SELECT ON OBJECT::dbo.TEAM TO REPORT_READER WITH GRANT OPTION;
```

*실행 주의: SQL Server REPORT_READER는 DB 사용자, Oracle도 DB 사용자. 계정이 있어야 실행 가능*
