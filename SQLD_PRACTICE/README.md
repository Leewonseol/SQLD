# SQLD 전범위 데이터 모델링·SQL 실행 실험실

`2024개정판_SQLD_개념정리.pdf`(103쪽)의 개념을 실습으로 바꾼 저장소다. 대상은 업무 규칙 → ERD → DDL → 정규화 → SQL 실행 → 결과 검증 전 과정이고, 각 개념은 Oracle과 SQL Server에서 **실제로 실행해** 확인한다.

> **원본 접근 한계 (먼저 읽기)**
> 원본 PDF(17 MB)는 이 세션에서 **내려받지 못했다.** Drive 커넥터는 10 MB 넘는 파일을 거부했고, 직접 다운로드는 네트워크 정책(403)에 막혔다. 그래서 페이지 이미지를 확인하지 못했다.
> 확보한 것은 Drive가 돌려준 **텍스트 추출본(약 25 KB, 페이지 번호 없음)** 뿐이다. 이 저장소는 103쪽 전수조사를 마친 결과가 **아니다.**
> * `coverage_matrix.csv`의 `원본 PDF 페이지` 열은 모든 행이 `미확인`이다. 페이지를 짐작해 채우지 않았다.
> * `근거구분` 열에서 `PDF추출본(E-xx)`는 추출본에 실제로 있는 내용이다. `요구목록(§n)`은 추출본에서 찾지 못한 항목이다.
> * 판독하지 못한 구간과 PDF를 넘겨주는 방법은 [_source/SOURCE_ACCESS_REPORT.md](_source/SOURCE_ACCESS_REPORT.md)에 있다. 추출본 조각 E-01~E-38은 [_source/extract_index.md](_source/extract_index.md)에 있다.
> * PDF에 없는 예제 데이터는 모두 **학습용 가상 데이터**로 표시했다.

## 1. 검증 환경

| DBMS | 버전 | 컨테이너 | 실습 계정 | 비고 |
|---|---|---|---|---|
| Oracle | Database 21c XE 21.3.0.0.0 | `gvenzl/oracle-xe:21-slim` (`sqld_ora`, PDB `XEPDB1`) | `sqld_lab` / 보조 `sqld_lab_u2`, `sqld_lab_u3` | 기본 검증 엔진 |
| Oracle | Database 23ai Free | `gvenzl/oracle-free:23-slim` (`sqld_ora23`, `FREEPDB1`) | 같음 | `*_oracle23ai.sql` 파일만. 버전 차이 확인용 |
| SQL Server | 2022 Developer 16.0.4305.5 (RTM-CU27-GDR) | `mcr.microsoft.com/mssql/server:2022-latest` (`sqld_mssql`) | 로그인 `sqld_lab`(DB `SQLD_LAB`의 db_owner만) / 보조 `sqld_lab_u2`, `sqld_lab_u3` | |

* **Oracle 19c에서는 실행하지 않았다.** 과제 기준은 19c이지만 이 환경에는 19c 이미지가 없다. 21c에서 확인한 결과를 19c 결과로 보지 않는다. 19c와 다를 수 있는 기능은 해당 실습에 적어 두었다(`EXCEPT`는 21c부터, `FROM` 없는 `SELECT`는 23ai부터 등).
* 같은 개념이라도 DBMS마다 결과가 같다고 가정하지 않는다. 모든 실습은 `*_oracle.sql`과 `*_sqlserver.sql`을 따로 두고 각각 실행했다.

## 2. 디렉터리 구조

```
SQLD_PRACTICE/
├── README.md                 이 문서
├── coverage_matrix.csv       개념 ↔ 실습 대응표 (tools/build_matrix.py 로 생성, Excel 호환 UTF-8 BOM)
├── curriculum.md             학습 순서와 분기, 작성·논리·물리 순서 구분
├── verification_report.csv   마지막 실행 결과 (파일별 OK/NG, 예상 오류, CHECK_PASS 수)
├── _source/                  원본 접근 보고서, 추출본 조각 색인
├── tools/                    실행기·생성기·관리자 부트스트랩
├── 00_common/                공통 도우미(lab_drop, lab_check)와 SCOTT 데이터(EMP·DEPT·SALGRADE)
├── 01_modeling … 15_integrated_exam
│   ├── setup_oracle.sql / setup_sqlserver.sql   단원 데이터 (다시 실행 가능)
│   ├── examples/      exNN_주제.md (A~H 구조) + exNN_주제_oracle.sql / _sqlserver.sql
│   ├── exercises/     직접 작성 문제 (정답 없음)
│   ├── answers/       정답 SQL(자동 채점 lab_check 포함) 또는 정답 md
│   ├── expected_results/  실제 실행 출력 전문 (.txt)
│   └── explanation.md 단원 안내: 위치, 실습 목록, PDF와 실행 결과가 다른 점
```

## 3. 실행 방법

### 3-1. 실습 DB 준비 (관리자 계정으로 1회)
```bash
docker run -d --name sqld_ora -p 1521:1521 -e ORACLE_PASSWORD=SqldLab2026 gvenzl/oracle-xe:21-slim
```
```bash
docker run -d --name sqld_mssql -p 1433:1433 -e ACCEPT_EULA=Y -e MSSQL_SA_PASSWORD='Sqld_Lab_2026!' mcr.microsoft.com/mssql/server:2022-latest
```
```bash
docker exec -i sqld_ora sqlplus -s system/SqldLab2026@//localhost/XEPDB1 < tools/bootstrap_oracle_admin.sql
```
```bash
docker exec -i sqld_mssql /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P 'Sqld_Lab_2026!' -C -f 65001 < tools/bootstrap_sqlserver_admin.sql
```
부트스트랩은 실습 전용 스키마·DB·계정이 없을 때만 만든다. 이미 있는 사용자 객체는 지우지 않는다.

### 3-2. 실습 실행
```bash
python3 tools/run_labs.py
```
```bash
python3 tools/run_labs.py 05_where_conditions 11_window_functions/examples/ex02_rows_range_oracle.sql
```
```bash
python3 tools/run_labs.py --inject-only
```
* 실행 순서: `00_common` → 단원별 `setup` → `examples` → `answers`.
* 결과: `expected_results/<파일명>.txt`, `verification_report.csv`. md 안의 `<!-- RESULT: … -->` 블록은 실제 출력으로 바뀐다.
* 손으로 실행할 때 Oracle은 `NLS_LANG=AMERICAN_AMERICA.AL32UTF8`로 실행한다. SQL Server는 `sqlcmd -C -I -d SQLD_LAB -f 65001`로 실행한다(`-I`는 QUOTED_IDENTIFIER ON이다. 필터 인덱스 실습에 필요하다).

### 3-3. 생성기
| 스크립트 | 만드는 것 |
|---|---|
| `tools/gen_answers.py` | 04~12단원 `answers/*_answer_{oracle,sqlserver}.sql` (명세: `tools/answer_specs/uNN.py`) |
| `tools/gen_exam.py` | 15단원 문제 SQL·md (명세: `tools/answer_specs/exam15.py`) |
| `tools/build_matrix.py` | `coverage_matrix.csv` (원천: `tools/concept_rows.py` + `verification_report.csv`) |
| `tools/concurrency_demo.py` | 14단원 두 세션 동시성 실험 출력 |

## 4. 안전 규칙
* **모든 DDL·DML·권한 실험은 실습 전용 스키마 `SQLD_LAB`(Oracle) / 실습 전용 DB `SQLD_LAB`(SQL Server)에서만 실행한다.**
* Oracle `lab_drop`은 접속 사용자가 `SQLD_LAB`이 아니면 아무것도 지우지 않는다. SQL Server 정리 구문은 같은 배치에서 `IF DB_NAME() <> N'SQLD_LAB' THROW`로 막는다.
* 지우는 객체는 실습이 만든 이름 접두사(`L02_`, `N03_`, `X15_` 등) 객체뿐이다. 모든 `setup`과 예제는 몇 번을 다시 실행해도 같은 결과가 나온다.
* 권한 실습(14단원)은 보조 계정 `sqld_lab_u2`, `sqld_lab_u3`에만 권한을 주고 회수한다.

## 5. 표기 규칙
| 표기 | 뜻 |
|---|---|
| `-- @expect-error: ORA-00918, MSG-209` | 이 파일에서 **일부러** 내는 오류다. 실행기는 예상 오류가 모두 났는지, 예상하지 않은 오류가 없는지 판정한다. |
| `CHECK_PASS` / `CHECK_FAIL` | `lab_check`가 정답 뷰와 기대 결과 뷰를 양방향 차집합과 행 수로 비교한 결과다. |
| `미실행·문법 검토` | DBMS에서 실행하지 않은 코드다. 문법만 검토했다. |
| `학습용 가상 데이터` | PDF 추출본에 없는 데이터다. |
| `PDF와 다름` | 추출본의 서술과 실제 실행 결과가 다른 곳이다. 근거 출력은 해당 실습에 있다. |
| 행 순서 | 결과의 행 순서는 `ORDER BY`가 있을 때만 단정한다. |
| `SYS_C008958`, `PK__d14_acc__…` | 이름 없이 만든 제약조건에 DBMS가 붙인 이름이다. 실행할 때마다 바뀌므로 비교하지 않는다. 오류 번호만 비교한다. |

## 6. 현재 검증 상태 요약
* 실행 파일은 Oracle 21c `*_oracle.sql`, SQL Server `*_sqlserver.sql`, Oracle 23ai `*_oracle23ai.sql`이다. 결과는 `verification_report.csv`에서 확인한다. 마지막 전체 실행에서 NG는 0건이고 CHECK_FAIL도 0건이다.
* 개념별 상태(완료(실행 검증) / 완료(설계·이론 검증) / 미실행(이론만) / 부분(원문 판독 불가))는 `coverage_matrix.csv`의 `실습 완료 상태` 열에 있다.
* 실행해서 확인한 PDF 서술 오류와 DBMS별 차이는 각 단원 `explanation.md`의 "PDF와 실행 결과가 다른 점"에 모았다. 예: SELF JOIN 조건 오기(E-12), 윈도우 결과표 수치 오기(E-32·E-33), SQL Server도 FIRST_VALUE·LAST_VALUE·NTILE을 지원함(E-34·E-35), DDL 자동 커밋은 Oracle에만 해당(E-04).
* 실행 중 발견한 엔진 동작:
  * Oracle 21.3 XE: `HAVING` 절의 집계 서브쿼리와 `ORDER BY`를 함께 쓰면 정렬이 틀린 결과가 나왔다(08단원 ex08). 23ai에서는 정상이었다.
  * Oracle: 자식 테이블이 비어 있으면 FK 부모 테이블도 `TRUNCATE`된다. SQL Server는 항상 Msg 4712로 거부한다.
