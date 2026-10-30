# ex10 OUTER JOIN (LEFT·RIGHT·FULL)과 Oracle (+)

> 근거: PDF추출본 E-19 · 데이터: **PDF 원문 값**(BOOK_LIST 4행, PUBLISHER 4행) · 검증: Oracle 21c / SQL Server 2022 실행

## A. 개념 설명
* **무엇을 하는가**: 짝이 없는 행도 버리지 않는다. 기준 테이블의 행을 모두 남기고, 반대쪽 컬럼은 NULL로 채운다.
  * LEFT: 왼쪽 테이블의 모든 행 / RIGHT: 오른쪽 테이블의 모든 행 / FULL: 양쪽 모든 행(LEFT ∪ RIGHT)
* **Oracle (+)**: NULL로 **채워질 쪽**(짝이 없을 수 있는 쪽) 컬럼 뒤에 붙인다. `b.pid = p.pid(+)`는 LEFT와 같다. 양쪽에 동시에 붙일 수 없어서 FULL은 두 쿼리를 UNION 해야 한다(PDF 방식).
* **SQL Server**: ANSI 구문만 쓴다. `(+)`도 옛 `*=`도 구문 오류다.

## B. 입력 데이터 (PDF)
| BOOK_LIST(book_id PK, book_name, writer, publisher_id) | PUBLISHER(publisher_id PK, publisher_name) |
|---|---|
| b01 데미안 1 / b02 어린왕자 2 / **b03 1984 8** / b04 나미야 잡화점의 기적 3 | 1 열린책들 / 2 민음사 / 3 현대문학 / **4 한빛미디어** |

b03의 출판사 8은 PUBLISHER에 없다(그래서 FK를 두지 않았다. FK가 있었다면 입력 단계에서 거부된다 → 02단원). 4 한빛미디어는 책이 없다.

## C. 실행 SQL
[Oracle](ex10_outer_join_oracle.sql) · [SQL Server](ex10_outer_join_sqlserver.sql)

## D. 결과 예측 문제
1. LEFT·RIGHT·FULL 결과의 행 수를 각각 예측하라.
2. RIGHT JOIN 결과에 b03이 나오는가?
3. PDF의 RIGHT 표기 `WHERE (+)b.Publisher_id = p.Publisher_id`는 실행되는가?

## E. 실제 출력
Oracle 21c XE
<!-- RESULT: ex10_outer_join_oracle.sql -->
```text
== [Q1] LEFT OUTER JOIN: 모든 책 + 짝이 없는 출판사 값은 NULL

BOOK_ID|BOOK_NAME|WRITER|PUBLISHER_ID|PUBLISHER_NAME
b01|데미안|헤르만 헤세|1|열린책들
b02|어린왕자|앙투안 드 생텍쥐페리|2|민음사
b03|1984|조지 오웰|8|(null)
b04|나미야 잡화점의 기적|히가시노 게이고|3|현대문학

4 rows selected.

== [Q2] Oracle (+): NULL 이 채워질 쪽(출판사) 컬럼에 (+)

BOOK_ID|BOOK_NAME|WRITER|PUBLISHER_ID|PUBLISHER_NAME
b01|데미안|헤르만 헤세|1|열린책들
b02|어린왕자|앙투안 드 생텍쥐페리|2|민음사
b03|1984|조지 오웰|8|(null)
b04|나미야 잡화점의 기적|히가시노 게이고|3|현대문학

4 rows selected.

== [Q3] RIGHT OUTER JOIN: 모든 출판사 + 책이 없는 출판사(4 한빛미디어)는 책 쪽 NULL

BOOK_ID|BOOK_NAME|WRITER|PUBLISHER_ID|PUBLISHER_NAME
b01|데미안|헤르만 헤세|1|열린책들
b02|어린왕자|앙투안 드 생텍쥐페리|2|민음사
b04|나미야 잡화점의 기적|히가시노 게이고|3|현대문학
(null)|(null)|(null)|(null)|한빛미디어

4 rows selected.

== [Q4] PDF E-19 원문 구문 "(+)b.Publisher_id = p.Publisher_id" -> 오류 ((+) 는 컬럼 뒤에 붙는다)
SELECT b.book_id, p.publisher_name FROM book_list b, publisher p WHERE (+)b.publisher_id = p.publisher_id
                                                                         *
ERROR at line 1:
ORA-00936: missing expression

== [Q5] RIGHT 의 올바른 (+) 표기: b.publisher_id(+) = p.publisher_id

BOOK_ID|BOOK_NAME|WRITER|PUBLISHER_ID|PUBLISHER_NAME
b01|데미안|헤르만 헤세|1|열린책들
b02|어린왕자|앙투안 드 생텍쥐페리|2|민음사
b04|나미야 잡화점의 기적|히가시노 게이고|3|현대문학
(null)|(null)|(null)|(null)|한빛미디어

4 rows selected.

== [Q6] FULL OUTER JOIN: 4 + 1 = 5행 (b03 의 출판사 NULL, 한빛미디어의 책 NULL)

BOOK_ID|BOOK_NAME|WRITER|PUBLISHER_ID|PUBLISHER_NAME
b01|데미안|헤르만 헤세|1|열린책들
b02|어린왕자|앙투안 드 생텍쥐페리|2|민음사
b03|1984|조지 오웰|8|(null)
b04|나미야 잡화점의 기적|히가시노 게이고|3|현대문학
(null)|(null)|(null)|(null)|한빛미디어

5 rows selected.

== [Q7] PDF 의 FULL 대체: (+) 왼쪽 + (+) 오른쪽을 UNION

BOOK_ID|BOOK_NAME|WRITER|PUBLISHER_ID|PUBLISHER_NAME
b01|데미안|헤르만 헤세|1|열린책들
b02|어린왕자|앙투안 드 생텍쥐페리|2|민음사
b03|1984|조지 오웰|8|(null)
b04|나미야 잡화점의 기적|히가시노 게이고|3|현대문학
(null)|(null)|(null)|(null)|한빛미디어

5 rows selected.

== [Q8] (+) 를 양쪽에 동시에 -> 오류 (FULL 을 (+) 로 직접 쓸 수 없다)
SELECT b.book_id FROM book_list b, publisher p WHERE b.publisher_id(+) = p.publisher_id(+)
                                                                       *
ERROR at line 1:
ORA-01468: a predicate may reference only one outer-joined table
```
<!-- /RESULT -->

SQL Server 2022
<!-- RESULT: ex10_outer_join_sqlserver.sql -->
```text
== [Q1] LEFT OUTER JOIN
book_id|book_name|writer|publisher_id|publisher_name
-------|---------|------|------------|--------------
b01|데미안|헤르만 헤세|1|열린책들
b02|어린왕자|앙투안 드 생텍쥐페리|2|민음사
b03|1984|조지 오웰|8|NULL
b04|나미야 잡화점의 기적|히가시노 게이고|3|현대문학

(4 rows affected)
== [Q3] RIGHT OUTER JOIN
book_id|book_name|writer|publisher_id|publisher_name
-------|---------|------|------------|--------------
b01|데미안|헤르만 헤세|1|열린책들
b02|어린왕자|앙투안 드 생텍쥐페리|2|민음사
b04|나미야 잡화점의 기적|히가시노 게이고|3|현대문학
NULL|NULL|NULL|NULL|한빛미디어

(4 rows affected)
== [Q6] FULL OUTER JOIN (NULLS LAST 가 없으므로 CASE 로 NULL 을 뒤로)
book_id|book_name|writer|publisher_id|publisher_name
-------|---------|------|------------|--------------
b01|데미안|헤르만 헤세|1|열린책들
b02|어린왕자|앙투안 드 생텍쥐페리|2|민음사
b03|1984|조지 오웰|8|NULL
b04|나미야 잡화점의 기적|히가시노 게이고|3|현대문학
NULL|NULL|NULL|NULL|한빛미디어

(5 rows affected)
== [Q7] LEFT UNION RIGHT 로 FULL 흉내
book_id|book_name|writer|publisher_id|publisher_name
-------|---------|------|------------|--------------
NULL|NULL|NULL|NULL|한빛미디어
b01|데미안|헤르만 헤세|1|열린책들
b02|어린왕자|앙투안 드 생텍쥐페리|2|민음사
b03|1984|조지 오웰|8|NULL
b04|나미야 잡화점의 기적|히가시노 게이고|3|현대문학

(5 rows affected)
== [Q2] Oracle (+) 표기 -> 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near ')'.
== [Q9] 옛 *= 표기 -> 오류
Msg 102, Level 15, State 1, Server a70f428a7f8a, Line 2
Incorrect syntax near '*='.
```
<!-- /RESULT -->

**이유와 외부검증**
* LEFT 4행: b03은 출판사가 없어 publisher_name NULL. RIGHT 4행: 한빛미디어는 책이 없어 책 쪽 NULL, b03은 빠진다. FULL 5행 = 양쪽에서 짝지어진 3행 + b03 + 한빛미디어. PDF 결과표 세 개와 일치한다.
* Q4: PDF 원문 `(+)b.publisher_id`는 ORA-00936 missing expression이다. `(+)`는 컬럼 **뒤**에 붙인다(Q5). PDF 표기 오류로 판단한다.
* Q7: PDF의 FULL 대체(LEFT UNION RIGHT)는 5행으로 같다. UNION은 중복을 없애므로, 완전히 같은 행이 원래 두 번 있었다면 하나로 줄어든다. 이 데이터에서는 차이가 없다.
* Q8: 양쪽에 (+) → ORA-01468.
* SQL Server의 FULL 정렬은 `NULLS LAST` 대신 CASE를 썼다. SQL Server는 NULL을 가장 작은 값으로 정렬해 맨 앞에 둔다(06단원 ex05).

## F. 변형 문제
1. PUBLISHER에 `5 길벗`을 추가하면 LEFT·RIGHT·FULL 행 수는?
2. Q1에 `WHERE p.publisher_name IS NULL`을 추가하면? (출판사가 없는 책 = 안티 조인)
3. Q2의 `(+)`를 반대쪽으로 옮기면 어떤 조인이 되는가?

G: [exercises/ex10_outer_join.md](../exercises/ex10_outer_join.md)
