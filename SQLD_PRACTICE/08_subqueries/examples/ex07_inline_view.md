# ex07 인라인 뷰 (FROM 절 서브쿼리)

> 근거: PDF추출본 E-21("동적 뷰", "다른 테이블과 조인 시 반드시 테이블 별칭", "일회성", 작가별 평균보다 비싼 그림 예, 실행 원리 (1)~(4)) · 데이터: PAINTINGS·ARTISTS — PDF 원문 값 · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* FROM 절의 서브쿼리 결과를 임시 테이블처럼 쓴다. DB에 저장되지 않는다(일회성).
* 인라인 뷰가 만든 컬럼(avg_price)은 바깥 쿼리의 **어느 절에서나** 쓸 수 있다. WHERE의 중첩 서브쿼리 결과는 그 조건 안에서만 쓰인다.
* 별칭: Oracle은 단독으로 쓰면 생략할 수 있다. 조인에서 참조하려면 필요하다. SQL Server는 항상 필수다.
* PDF의 실행 원리 (2)는 "카티션 곱 생성 → (3) WHERE로 걸러냄"으로 설명한다. 이것은 **논리적 해석**이다. 실제 DBMS는 카티션 곱을 만들지 않고 조인 조건으로 바로 결합한다(물리적 순서는 다르다).

## B. 입력 데이터
PAINTINGS·ARTISTS — PDF 원문 값 (setup_oracle.sql / setup_sqlserver.sql, 00_common)

## C. 실행 SQL
[Oracle](ex07_inline_view_oracle.sql) · [SQL Server](ex07_inline_view_sqlserver.sql)

## D. 결과 예측 문제
1. Q1 작가별 평균 가격 중 작가 1의 평균은?
2. Q2 결과는 몇 행인가? 작품이 1개뿐인 작가(2·3·4·10)는?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex07_inline_view_oracle.sql -->
```text
== [Q1] 인라인 뷰가 만드는 중간 결과: 작가별 평균 가격 (PDF 실행 원리 (1))

ARTIST_ID|AVG_PRICE
1|1225000
2|470000
3|750000
4|640000
5|650000
10|150000

6 rows selected.

== [Q2] PDF 예: 작가별 평균 가격보다 비싼 그림 (인라인 뷰 p2 와 조인)

ARTIST_ID|NAME|PRICE|AVG_PRICE
1|밤의 도시|1350000|1225000
5|밤비|920000|650000

2 rows selected.

== [Q3] 인라인 뷰의 컬럼은 바깥 쿼리 어느 절에서나 쓸 수 있다 (중첩 서브쿼리와 다른 점): SELECT·ORDER BY 에서 avg_price 사용

NAME|CNT|AVG_PRICE
이지현|2|1225000
박성진|1|750000
정하나|2|650000
백에서|1|640000
황현석|1|470000

5 rows selected.

== [Q4] Oracle 은 단독 인라인 뷰에 별칭이 없어도 된다

CNT
5

1 row selected.
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex07_inline_view_sqlserver.sql -->
```text
== [Q1] 작가별 평균 가격 (INT 평균은 정수)
artist_id|avg_price
---------|---------
1|1225000
2|470000
3|750000
4|640000
5|650000
10|150000

(6 rows affected)
== [Q2] 작가별 평균보다 비싼 그림
artist_id|name|price|avg_price
---------|----|-----|---------
1|밤의 도시|1350000|1225000
5|밤비|920000|650000

(2 rows affected)
== [Q3] 인라인 뷰 컬럼을 SELECT·ORDER BY 에서
name|cnt|avg_price
----|---|---------
이지현|2|1225000
박성진|1|750000
정하나|2|650000
백에서|1|640000
황현석|1|470000

(5 rows affected)
== [Q4] 별칭 없는 파생 테이블 -> 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near ';'.
```
<!-- /RESULT -->

**이유**
* Q1: 작가1 (1,100,000+1,350,000)/2 = 1,225,000, 작가5 (920,000+380,000)/2 = 650,000.
* Q2: 평균보다 '큰' 그림만 남는다. 작품이 하나뿐인 작가는 가격 = 평균이라 빠진다 → 102 밤의 도시, 106 밤비.
* Q3: 인라인 뷰 컬럼 avg_price로 정렬. 작가 10(108)은 ARTISTS에 없어 INNER JOIN에서 빠진다.
* SQL Server는 별칭 없는 파생 테이블에서 Msg 102(Q4). INT 평균이라 정수다(이 데이터는 나누어떨어져서 Oracle과 값이 같다).

## F. 변형 문제
1. 작가 이름과 '최고가 작품명'을 인라인 뷰로 구하라.
2. 가격 상위 3개 그림을 인라인 뷰 + ROWNUM(Oracle)으로 구하라.

G: [../exercises/ex07_inline_view.md](../exercises/ex07_inline_view.md)
