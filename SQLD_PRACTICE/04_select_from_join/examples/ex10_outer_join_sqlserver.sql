-- ex10 OUTER JOIN (PDF E-19)  | SQL Server : (+) 표기 없음. 옛 *= 표기는 현재 호환성 수준(160)에서 구문 오류
PRINT N'== [Q1] LEFT OUTER JOIN';
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b LEFT JOIN publisher p ON b.publisher_id = p.publisher_id
ORDER BY b.book_id;
PRINT N'== [Q3] RIGHT OUTER JOIN';
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b RIGHT JOIN publisher p ON b.publisher_id = p.publisher_id
ORDER BY p.publisher_id;
PRINT N'== [Q6] FULL OUTER JOIN (NULLS LAST 가 없으므로 CASE 로 NULL 을 뒤로)';
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b FULL JOIN publisher p ON b.publisher_id = p.publisher_id
ORDER BY CASE WHEN b.book_id IS NULL THEN 1 ELSE 0 END, b.book_id;
PRINT N'== [Q7] LEFT UNION RIGHT 로 FULL 흉내';
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b LEFT JOIN publisher p ON b.publisher_id = p.publisher_id
UNION
SELECT b.book_id, b.book_name, b.writer, b.publisher_id, p.publisher_name
FROM book_list b RIGHT JOIN publisher p ON b.publisher_id = p.publisher_id
ORDER BY 1;
GO
PRINT N'== [Q2] Oracle (+) 표기 -> 오류';
GO
-- @expect-error: MSG-102
SELECT b.book_id FROM book_list b, publisher p WHERE b.publisher_id = p.publisher_id(+);
GO
PRINT N'== [Q9] 옛 *= 표기 -> 오류';
GO
-- @expect-error: MSG-102
SELECT b.book_id FROM book_list b, publisher p WHERE b.publisher_id *= p.publisher_id;
GO
