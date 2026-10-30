-- ex10 OUTER JOIN LEFT·RIGHT·FULL, Oracle (+) (PDF E-19)  | Oracle   데이터: [PDF] BOOK_LIST, PUBLISHER
PROMPT == [Q1] LEFT OUTER JOIN: 모든 책 + 짝이 없는 출판사 값은 NULL
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b LEFT JOIN publisher p ON b.publisher_id = p.publisher_id
ORDER BY b.book_id;

PROMPT == [Q2] Oracle (+): NULL 이 채워질 쪽(출판사) 컬럼에 (+)
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b, publisher p
WHERE b.publisher_id = p.publisher_id(+)
ORDER BY b.book_id;

PROMPT == [Q3] RIGHT OUTER JOIN: 모든 출판사 + 책이 없는 출판사(4 한빛미디어)는 책 쪽 NULL
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b RIGHT JOIN publisher p ON b.publisher_id = p.publisher_id
ORDER BY p.publisher_id;

PROMPT == [Q4] PDF E-19 원문 구문 "(+)b.Publisher_id = p.Publisher_id" -> 오류 ((+) 는 컬럼 뒤에 붙는다)
-- @expect-error: ORA-00936
SELECT b.book_id, p.publisher_name FROM book_list b, publisher p WHERE (+)b.publisher_id = p.publisher_id;

PROMPT == [Q5] RIGHT 의 올바른 (+) 표기: b.publisher_id(+) = p.publisher_id
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b, publisher p
WHERE b.publisher_id(+) = p.publisher_id
ORDER BY p.publisher_id;

PROMPT == [Q6] FULL OUTER JOIN: 4 + 1 = 5행 (b03 의 출판사 NULL, 한빛미디어의 책 NULL)
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b FULL JOIN publisher p ON b.publisher_id = p.publisher_id
ORDER BY b.book_id NULLS LAST;

PROMPT == [Q7] PDF 의 FULL 대체: (+) 왼쪽 + (+) 오른쪽을 UNION
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b, publisher p WHERE b.publisher_id = p.publisher_id(+)
UNION
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b, publisher p WHERE b.publisher_id(+) = p.publisher_id
ORDER BY 1 NULLS LAST;

PROMPT == [Q8] (+) 를 양쪽에 동시에 -> 오류 (FULL 을 (+) 로 직접 쓸 수 없다)
-- @expect-error: ORA-01468
SELECT b.book_id FROM book_list b, publisher p WHERE b.publisher_id(+) = p.publisher_id(+);
