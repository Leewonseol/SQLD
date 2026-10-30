# 15 정답 (H)
* Q1~Q8의 정답과 오답 해설은 각 문제 문서의 ⑥에 있다. 정답 보기는 실행 결과 비교표(MATCH)와 lab_check(CHECK_PASS)로 검증했다.
* X1 `SELECT t.genre, COUNT(*) FROM x15_content t WHERE EXISTS (SELECT 1 FROM x15_wish s WHERE s.content_id = t.content_id) AND NOT EXISTS (SELECT 1 FROM x15_watch w WHERE w.content_id = t.content_id) GROUP BY t.genre;` → SHOW 1(T4)
* X2 윈도우: `SELECT cust_id, watch_dt, title FROM (SELECT w.cust_id, w.watch_dt, t.title, ROW_NUMBER() OVER (PARTITION BY w.cust_id ORDER BY w.watch_dt DESC) rn FROM x15_watch w JOIN x15_content t ON t.content_id = w.content_id) WHERE rn = 1;` → C1 3/5 SQL 강의, C2 3/3 액션 영화, C3 3/4 바다 다큐
  (SQL Server는 인라인 뷰에 별칭이 필요하다. 이 답안은 **미실행·문법 검토**)
* X3 Oracle `NVL(grade, '미지정')`, SQL Server `ISNULL(grade, N'미지정')`. 단, grade가 VARCHAR(5)인 SQL Server에서는 ISNULL 결과가 VARCHAR(5)로 바뀌어 '??'가 될 수 있다(10단원 ex02). `COALESCE(CAST(grade AS NVARCHAR(10)), N'미지정')`로 쓴다 → GOLD 2, VIP 1, 미지정 1 (**미실행·문법 검토**)
