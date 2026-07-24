# SQL 관리 구문

## 1. DML(Data Manipulation Language)

- 테이블의 행 데이터를 삽입·수정·삭제

### INSERT

- 행 삽입
- 기본형
    
    ```sql
    INSERT INTO 테이블명 (컬럼1, 컬럼2)
    VALUES (값1, 값2);
    ```
    
- 컬럼 목록 생략 가능
    - 전체 컬럼의 순서·자료형·개수를 정확히 맞춰야 함
- 일부 컬럼 생략
    - DEFAULT 지정 → 기본값
    - DEFAULT 없음 → NULL
- INSERT ~ SELECT
    - SELECT 결과 여러 행을 한 번에 삽입
- 오류
    - PK에 NULL
    - NOT NULL 컬럼에 NULL
    - 자료형 불일치
    - 식별자 중복
    - 컬럼 수 ≠ 값 수

### UPDATE

- 기존 행의 값 수정

```sql
UPDATE 테이블
SET 컬럼 = 값
WHERE 조건;
```

- WHERE 생략 → 모든 행 수정

### DELETE

- 특정 행 삭제

```sql
DELETE FROM 테이블
WHERE 조건;
```

- WHERE 생략 → 모든 행 삭제
- 테이블 구조는 유지
- ROLLBACK 가능

### MERGE

- 대상 테이블 + 소스 테이블 병합
- 조건 일치(MATCHED)
    - UPDATE 또는 DELETE
- 조건 불일치(NOT MATCHED)
    - INSERT

## 2. TCL(Transaction Control Language)

- 하나의 논리적 작업 단위인 트랜잭션을 제어

### 트랜잭션

- 하나 이상의 SQL 문을 묶은 작업 단위
- 전부 성공하거나 전부 취소
- 명시적 트랜잭션(Explicit)
    - BEGIN TRANSACTION
    - COMMIT / ROLLBACK으로 직접 종료
- 묵시적 트랜잭션(Implicit)
    - DML 실행 시 자동 시작
    - COMMIT / ROLLBACK 전까지 유지

### COMMIT

- 변경 내용을 DB에 영구 반영
- 이후 ROLLBACK 불가
- 다른 사용자가 변경 결과 조회 가능

### ROLLBACK

- 트랜잭션 변경 내용 취소
- 마지막 COMMIT 시점으로 복구

### SAVEPOINT

- 트랜잭션 중간 저장점
- Oracle
    
    ```sql
    SAVEPOINT SV1;
    ROLLBACK TO SV1;
    ```
    
- SQL Server
    
    ```sql
    SAVE TRANSACTION SV1;
    ROLLBACK TRANSACTION SV1;
    ```
    

### ACID

- A: Atomicity(원자성)
    - 전부 성공 또는 전부 실패(All or Nothing)
- C: Consistency(일관성)
    - 실행 전후 DB의 규칙·제약조건 유지
- I: Isolation(고립성)
    - 동시에 수행되는 트랜잭션 간 간섭 방지
- D: Durability(지속성)
    - COMMIT 결과는 영구 보존

### LOCK

- 특정 행이나 범위를 다른 트랜잭션이 변경하지 못하게 함
- COMMIT 또는 ROLLBACK 시 해제

### 격리 수준(Isolation Level)

- Level 0: Read Uncommitted
    - 커밋되지 않은 데이터도 읽음
    - Dirty Read 발생
- Level 1: Read Committed
    - 커밋된 데이터만 읽음
    - Dirty Read 방지
    - Non-repeatable Read 발생 가능
- Level 2: Repeatable Read
    - 같은 행을 반복 조회해도 같은 결과
    - Dirty Read 방지
    - Non-repeatable Read 방지
    - Phantom Read 발생 가능
- Level 3: Serializable
    - 가장 높은 격리 수준
    - Dirty / Non-repeatable / Phantom 모두 방지
    - 동시성·성능 저하

### 동시성 문제

- Dirty Read: 아직 COMMIT되지 않은 값을 읽음
- Non-repeatable Read: 같은 행을 다시 읽었는데 값이 달라짐
- Phantom Read: 같은 조건 조회에서 행이 추가·삭제되어 결과 집합이 달라짐

### AUTO COMMIT

- SQL문 실행 직후 자동 COMMIT 여부
- Oracle
    - 기본적으로 DML 자동 COMMIT 아님
    - DDL 실행 시 자동 COMMIT
- SQL Server
    - 기본적으로 AUTO COMMIT
    - BEGIN TRANSACTION을 명시하면 수동 제어 가능

## 3. DDL(Data Definition Language)

- 테이블·뷰 등의 객체와 구조를 정의·변경·삭제

### CREATE

- 객체 생성: TABLE, VIEW
- CREATE TABLE 기본 구조
    
    ```sql
    CREATE TABLE 테이블명 (
    	컬럼명 자료형 [제약조건],
    	...
    );
    ```
    
- 자료형
    - 문자: VARCHAR2(N), CHAR(N)
    - 숫자: NUMBER(m,n)
    - 날짜: DATE, TIMESTAMP
- 테이블·컬럼 작성 규칙
    - 테이블명은 일반적으로 중복 불가
    - 한 테이블 안에서 컬럼명 중복 불가
    - 컬럼명과 자료형은 필수
    - NOT NULL·DEFAULT는 선택
    - 일부 특수문자만 허용
- 제약조건(Constraint)
    - PRIMARY KEY: 중복 X, NULL X, 테이블당 하나(복합키 가능)
    - UNIQUE: 중복 X, NULL O, 테이블당 여러 개(복합 UNIQUE 가능)
    - NOT NULL: NULL 입력 금지
    - CHECK: 지정한 조건·범위의 값만 허용
    - FOREIGN KEY: 참조 무결성 보장 (CASCADE / SET NULL / SET DEFAULT / NO ACTION·RESTRICT)

### ALTER

- 기존 객체의 구조 변경
- 컬럼 추가: ALTER TABLE 테이블 ADD ...
- 컬럼 삭제: ALTER TABLE 테이블 DROP ...
- 자료형·속성 변경: Oracle(MODIFY) / SQL Server(ALTER COLUMN)
- 컬럼 이름 변경: Oracle(RENAME COLUMN) / SQL Server(sp_rename)
- 제약조건 추가: ALTER TABLE 테이블 ADD CONSTRAINT ...

### DROP

- 테이블 객체 자체 삭제 (데이터+구조 삭제)
- 실행 후 테이블 존재 X
- 일반적으로 ROLLBACK 불가
- CASCADE CONSTRAINTS: 참조 제약조건도 함께 삭제

### RENAME

- 테이블 이름 변경

### TRUNCATE

- 테이블의 모든 행 삭제 (WHERE 불가)
- 테이블 구조는 유지
- 일반적으로 ROLLBACK 불가

### 삭제 명령 비교

- DELETE: DML, WHERE 가능, 테이블 유지, ROLLBACK 가능
- TRUNCATE: DDL, WHERE 불가, 테이블 유지, ROLLBACK 불가
- DROP: DDL, 테이블 자체 삭제, ROLLBACK 불가

## VIEW

- SELECT 문을 저장해 가상 테이블처럼 사용하는 객체

### 특징

- 실제 행 데이터를 직접 저장하지 않음
- 실행할 때 저장된 SELECT를 다시 수행
- CREATE VIEW로 생성
- 단순 뷰는 DML 가능
- 복합 뷰는 DML 제한
- 뷰 자체에는 인덱스 생성 불가

### 장점

- 편의성: 복잡한 쿼리 재사용
- 보안성: 필요한 컬럼만 노출
- 독립성: 테이블 구조 일부 변경의 영향 감소

### 단점

- 객체이므로 일정 용량 사용
- 뷰가 많아지면 관리 복잡
- 물리 데이터·자체 인덱스 없음

### 인라인 뷰와 차이

- VIEW: SELECT 문을 DB 객체로 저장
