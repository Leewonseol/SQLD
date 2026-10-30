# ex05 직접 작성 문제
G1. D13_G_STU(id PK, email UNIQUE, age 0~150 CHECK, NOT NULL name)를 만들고 아래 5행을 각각 입력하라. 성공한 행의 id가 정답이다(Oracle과 SQL Server의 결과가 다를 수 있다).
  (1, 'a', 'a@x', 20) / (2, 'b', NULL, 30) / (3, 'c', NULL, 40) / (4, NULL, 'd@x', 50) / (5, 'e', 'e@x', 200)   — 순서: (id, name, email, age)
  열: `id`
