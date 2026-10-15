# SQLD 랜덤 혼합형 60문제 — 정답 및 해설

각 선지는 문제지에 표시한 DBMS에서 평가합니다. `공통 문법`은 양쪽 DBMS에서 같은 형태를 쓰는 숙어입니다.

### 01. 관계형 데이터베이스 개요 — ④
- 숙어: **DISTINCT (중복 제거)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: DISTINCT는 SELECT 대상 행의 중복을 제거한다. TEAM_ID만 투영해야 팀 목록이 된다.

### 02. 관계형 데이터베이스 개요 — ②
- 숙어: **PRIMARY KEY = UNIQUE + NOT NULL**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: PRIMARY KEY는 유일성 및 NOT NULL을 강제한다. UNIQUE만으로는 NULL 금지까지 보장되지 않는다.

### 03. 관계형 데이터베이스 개요 — ②
- 숙어: **LEFT OUTER JOIN (기준 행 보존)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: LEFT JOIN은 일치하는 우측 행이 없는 T3도 NULL 확장으로 보존한다.

### 04. SELECT 문 — ①
- 숙어: **표현식 + 열 별칭**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: SALARY + 10은 급여에 정확히 10을 더한다. SUM(SALARY)은 집계 함수이며 단일 선수 계산 열로 사용할 수 없다.

### 05. SELECT 문 — ①
- 숙어: **COUNT(DISTINCT 컬럼)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: COUNT(DISTINCT POSITION)은 NULL을 제외한 서로 다른 포지션 값의 수를 센다.

### 06. SELECT 문 — ③
- 숙어: **SELECT 별칭 → ORDER BY 재사용**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: SELECT 목록의 별칭은 일반적으로 WHERE/HAVING에서 바로 참조할 수 없고 ORDER BY에서는 참조 가능하다. GROUP BY 별칭은 DBMS별 버전 차이가 있으므로 본 문제는 ORDER BY를 기준으로 한다.

### 07. 함수 — ①
- 숙어: **NULL 치환: NVL / ISNULL / COALESCE**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **전용**
- 해설: NVL/ISNULL은 NULL일 때 기본값 0을 반환한다. NULLIF는 값이 같으면 NULL로 만든다.

### 08. 함수 — ②
- 숙어: **문자 추출: SUBSTR / SUBSTRING**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **전용**
- 해설: SUBSTR(문자열,시작,길이) / SUBSTRING(문자열,시작,길이)는 시작 위치 1부터 두 문자 추출.

### 09. 함수 — ④
- 숙어: **NULLIF(0으로 나누기 방지)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: NULLIF(SALARY,0)는 연봉 0을 NULL로 바꾸어 0으로 나누기 오류를 막는다.

### 10. WHERE 절 — ④
- 숙어: **IS NULL (NULL 비교)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: SQL의 NULL 여부는 = NULL이 아니라 IS NULL로 검사한다.

### 11. WHERE 절 — ③
- 숙어: **IN + AND (조건 조합)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: IN 집합 조건과 AND 범위 조건을 함께 적용한다. OR는 결합 우선순위에 주의한다.

### 12. WHERE 절 — ④
- 숙어: **LIKE ... ESCAPE (와일드카드 이스케이프)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: LIKE에서 _는 임의의 한 글자이며, ESCAPE '!'를 지정하면 !_는 밑줄 문자 그 자체를 의미한다.

### 13. GROUP BY, HAVING 절 — ②
- 숙어: **SUM(CASE WHEN ... THEN 1 ELSE 0 END)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: ISNULL(SQL Server), NVL(Oracle), SUM(CASE ... ELSE 0 END)(공통)은 GK가 0명일 때 0을 반환한다. COUNT(CASE ... ELSE 0 END)는 ELSE 0도 NULL이 아닌 값으로 세므로 모든 선수 수를 GK로 오인한다.

### 14. GROUP BY, HAVING 절 — ②
- 숙어: **GROUP BY + HAVING COUNT(*)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: 집계 결과에 대한 조건은 HAVING에 둔다. WHERE는 개별 행 필터다.

### 15. GROUP BY, HAVING 절 — ④
- 숙어: **다중 GROUP BY**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: 집계하지 않은 SELECT 열 TEAM_ID, POSITION을 모두 GROUP BY에 나열해야 한다.

### 16. ORDER BY 절 — ②
- 숙어: **다중 ORDER BY + 안정적 동률 처리**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: 정렬 우선순위는 ORDER BY에 적은 순서다. 동률 정렬을 정해야 Top N 결과도 재현 가능하다.

### 17. ORDER BY 절 — ②
- 숙어: **ORDER BY CASE (사용자 지정 순서)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: CASE가 포지션을 우선순위 숫자로 치환하므로 DBMS 기본 문자열 정렬에 의존하지 않는다.

### 18. ORDER BY 절 — ②
- 숙어: **ORDER BY CASE WHEN ... IS NULL (NULL 위치)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: Oracle과 SQL Server의 NULL 기본 정렬 차이를 피하려면 CASE로 NULL의 위치를 명시한다.

### 19. 조인 — ④
- 숙어: **LEFT JOIN + COUNT(우측 PK)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: COUNT(*)는 NULL 확장 행을 1로 세지만 COUNT(우측 PK)는 NULL을 세지 않아 빈 팀이 0이다.

### 20. 조인 — ③
- 숙어: **OUTER JOIN 필터 ON / WHERE 구분**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: OUTER JOIN에서 우측 행 필터를 WHERE에 두면 NULL 확장 행이 제거된다. 매칭만 제한하려면 ON에 둔다.

### 21. 조인 — ③
- 숙어: **NOT EXISTS (안티 세미 조인)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: NOT EXISTS는 연관된 선수 행이 없는 팀만 반환한다.

### 22. 표준 조인 — ②
- 숙어: **CROSS JOIN (데카르트 곱)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: CROSS JOIN은 조인 조건 없이 두 테이블 행의 모든 조합을 만든다.

### 23. 표준 조인 — ④
- 숙어: **INNER JOIN ... ON (표준 조인)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: INNER JOIN은 양쪽 조인 조건이 참인 행만 출력한다.

### 24. 표준 조인 — ④
- 숙어: **USING / ON (DBMS 표준 지원 차이)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **전용**
- 해설: Oracle에서는 JOIN ... USING(TEAM_ID)이 가능하며 SQL Server에서는 동일 조인에 ON을 사용한다. CROSS JOIN은 불필요한 조합을 만들고 FULL/LEFT JOIN은 비일치 행까지 포함한다.

### 25. 서브 쿼리 — ①
- 숙어: **비연관 스칼라 서브쿼리**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: 평균은 스칼라 서브쿼리로 한 값만 반환한다. 두 번째 문장은 WHERE에 집계 함수를 직접 쓴 오류다.

### 26. 서브 쿼리 — ④
- 숙어: **상관 EXISTS (존재 여부)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: EXISTS는 상관 조건에 일치하는 행 존재 여부만 검사하며 고객행을 증식시키지 않는다.

### 27. 서브 쿼리 — ②
- 숙어: **> ALL (전체 비교)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: > ALL은 비교 대상의 모든 값보다 큰 경우에만 참이다. > ANY와 다르다.

### 28. 집합 연산자 — ①
- 숙어: **UNION vs UNION ALL**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: UNION은 결과 중복을 제거한다. UNION ALL은 중복 보존이다.

### 29. 집합 연산자 — ①
- 숙어: **MINUS / EXCEPT (차집합)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **전용**
- 해설: Oracle의 MINUS / SQL Server의 EXCEPT는 왼쪽 결과에서 오른쪽과 일치하는 행을 제거한다.

### 30. 집합 연산자 — ②
- 숙어: **INTERSECT (교집합)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: INTERSECT는 공통 행만 돌려준다. 대체로 중복도 제거된다.

### 31. 그룹 함수 — ③
- 숙어: **GROUPING SETS ((TEAM_ID), ())**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: (TEAM_ID)는 팀별 집계, ()는 전체 총계를 의미한다.

### 32. 그룹 함수 — ①
- 숙어: **ROLLUP(TEAM_ID, POSITION)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: ROLLUP(T,P)는 (T,P), (T), () 수준을 만든다. CUBE는 (P) 집계도 포함하므로 결과가 다르다.

### 33. 그룹 함수 — ②
- 숙어: **GROUPING(TEAM_ID) (집계 레벨 판별)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: GROUPING()은 해당 열이 집계로 소거된 소계/총계 행에서 1을 반환한다.

### 34. 윈도우 함수 — ③
- 숙어: **ROW_NUMBER() OVER(PARTITION BY ... ORDER BY ...)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: ROW_NUMBER는 동률에도 서로 다른 번호를 준다. PARTITION BY로 팀마다 순번을 재시작한다.

### 35. 윈도우 함수 — ①
- 숙어: **DENSE_RANK vs RANK**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: DENSE_RANK는 같은 값에 같은 등수를 주고 다음 순위를 건너뛰지 않는다. RANK는 건너뛴다.

### 36. 윈도우 함수 — ③
- 숙어: **SUM(...) OVER(... ROWS UNBOUNDED PRECEDING)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: PARTITION BY 팀 + ORDER BY 선수 + 명시적 ROWS로 행단위 팀별 누계를 구한다.

### 37. Top N 쿼리 — ④
- 숙어: **TOP / FETCH FIRST + ORDER BY**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **전용**
- 해설: ORDER BY를 명시하고 ONLY를 쓰면 정확히 3행을 뽑는다. WITH TIES는 동률이 있으면 추가 행 가능.

### 38. Top N 쿼리 — ①
- 숙어: **OFFSET 3 ROWS FETCH NEXT 3 ROWS ONLY**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: OFFSET은 건너뛸 행 수이므로 4번째부터 3행은 OFFSET 3 FETCH 3이다.

### 39. Top N 쿼리 — ③
- 숙어: **ROW_NUMBER + WHERE RN=1 (그룹별 Top1)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: 팀별 PARTITION+동률 결정열 PLAYER_ID를 넣은 ROW_NUMBER로 팀당 정확히 한 명만 반환한다.

### 40. 계층형 질의와 셀프 조인 — ①
- 숙어: **SELF JOIN (자기참조)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: 자기 조인에서 P.MANAGER_ID가 M.PLAYER_ID를 참조한다. LEFT JOIN은 최상위 관리자도 보존한다.

### 41. 계층형 질의와 셀프 조인 — ④
- 숙어: **CONNECT BY PRIOR / 재귀 CTE**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **전용**
- 해설: Oracle에서 START WITH는 루트, CONNECT BY PRIOR 부모 PK=자식 FK로 방향을 정한다.

### 42. 계층형 질의와 셀프 조인 — ③
- 숙어: **Adjacency list (부모 참조 FK)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: 직속 부하를 찾을 때 자식의 MANAGER_ID=부모 PLAYER_ID로 필터한다.

### 43. PIVOT 절과 UNPIVOT 절 — ③
- 숙어: **PIVOT (행의 범주→열)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **전용**
- 해설: Oracle PIVOT은 집계함수 + FOR 범주열 + IN 값/별칭을 사용한다.

### 44. PIVOT 절과 UNPIVOT 절 — ③
- 숙어: **UNPIVOT (열→행)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **전용**
- 해설: UNPIVOT은 FW/MF라는 열 이름을 POSITION 값으로 내리고 열 값을 CNT에 담는다.

### 45. PIVOT 절과 UNPIVOT 절 — ③
- 숙어: **조건부 집계 = 정적 PIVOT 대안**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: SUM(CASE...)는 범주별 인원수를 열로 바꾸는 공통 SQL 숙어다.

### 46. 정규 표현식 — ②
- 숙어: **REGEXP_LIKE / LIKE (패턴 매칭)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **전용**
- 해설: ^A는 문자열 시작이 A라는 뜻이다. SQL Server 기본 LIKE 패턴은 정규표현식과 다르다.

### 47. 정규 표현식 — ②
- 숙어: **^...+$ / 부정 문자 클래스 찾기**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **전용**
- 해설: Oracle ^[A-Z]+$는 전체 문자열이 1자 이상 대문자임을 의미한다. c는 대소문자 민감 매칭 옵션.

### 48. 정규 표현식 — ③
- 숙어: **{2,} 수량자 / LIKE 숫자 클래스 2회**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **전용**
- 해설: Oracle [0-9]{2,}는 연속된 숫자 최소 2자리를 뜻한다. SQL Server에서는 LIKE 숫자 클래스 두 개로 구현.

### 49. DML — ④
- 숙어: **UPDATE ... SET ... WHERE**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: UPDATE WHERE를 생략하면 전체 행이 바뀐다. DELETE는 행 자체를 제거한다.
- 실행 주의: 변경형 SQL: 연습 시 트랜잭션 내 실행 후 ROLLBACK 권장

### 50. DML — ③
- 숙어: **DELETE ... WHERE + NOT EXISTS**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: 참조되는 선수가 없는 T3만 삭제할 수 있고 PLAYER는 수정하지 않는다.
- 실행 주의: 변경형 SQL: 데이터 보존하려면 테스트 후 ROLLBACK

### 51. DML — ①
- 숙어: **INSERT INTO ... SELECT**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **공통**
- 해설: INSERT ... SELECT는 SELECT가 반환하는 행 수만큼 INSERT한다. 예제에서 T3가 존재해 T4가 한 행 추가된다.
- 실행 주의: 변경형 SQL: 반복 실행 시 PK 중복 발생 가능

### 52. TCL — ①
- 숙어: **트랜잭션 시작 + UPDATE (미확정 상태)**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **전용**
- 해설: Oracle에서 DML은 명시적 COMMIT 전까지 미확정이며 SAVEPOINT는 중간 복구 지점을 남긴다. SQL Server에서는 BEGIN TRANSACTION이 별도로 필요하다.
- 실행 주의: ③ 실행 시 열린 트랜잭션을 반드시 ROLLBACK하여 종료할 것

### 53. TCL — ④
- 숙어: **SAVEPOINT + ROLLBACK TO**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **전용**
- 해설: ROLLBACK TO는 지정 SAVEPOINT 이후 변경을 되돌리고 트랜잭션은 유지한다.

### 54. TCL — ④
- 숙어: **COMMIT (변경 확정)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **전용**
- 해설: COMMIT은 미확정 변경을 확정한다. 저장점 선언은 확정이 아니다.

### 55. DDL — ①
- 숙어: **CREATE TABLE + PK + NOT NULL**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: PRIMARY KEY는 ID 중복/NULL 불허, V NOT NULL은 별도 제약이다.
- 실행 주의: 반복 생성 시 DROP TABLE DDL_LAB 후 재실행

### 56. DDL — ③
- 숙어: **FOREIGN KEY ... REFERENCES**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **전용**
- 해설: REFERENCES TEAM(TEAM_ID)는 실제 부모 키를 참조하도록 제약한다.
- 실행 주의: 반복 생성 시 DROP TABLE FK_LAB 후 재실행

### 57. DDL — ②
- 숙어: **ALTER TABLE ... ADD (새 열)**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **전용**
- 해설: ALTER TABLE ... ADD로 기존 테이블에 새 열을 추가한다.
- 실행 주의: DDL은 실제 스키마 변경. Oracle DDL 전후 암묵 COMMIT에 주의

### 58. DCL — ①
- 숙어: **GRANT SELECT ON ... TO ...**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: GRANT SELECT로 필요한 읽기 권한만 부여한다.
- 실행 주의: REPORT_READER 계정/역할 및 권한 부여 권한이 사전에 있어야 함

### 59. DCL — ①
- 숙어: **REVOKE SELECT ON ... FROM ...**
- 정답 보기의 실행 환경: **Oracle**, 문법 분류: **공통**
- 해설: REVOKE는 객체 권한을 회수한다. 객체/권한자/시스템 권한 설정에 따라 효과는 다를 수 있다.
- 실행 주의: 계정·역할 존재 및 권한 필요

### 60. DCL — ④
- 숙어: **GRANT ... WITH GRANT OPTION**
- 정답 보기의 실행 환경: **SQL Server**, 문법 분류: **전용**
- 해설: 객체 권한을 다른 사용자에게 재부여하려면 WITH GRANT OPTION을 사용한다. WITH ADMIN OPTION은 여기서 같은 뜻이 아니다.
- 실행 주의: SQL Server REPORT_READER는 DB 사용자, Oracle도 DB 사용자. 계정이 있어야 실행 가능
