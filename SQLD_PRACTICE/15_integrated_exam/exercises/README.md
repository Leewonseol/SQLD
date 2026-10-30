# 15 직접 작성 문제
각 문제(examples/qNN_*.md)의 **③ 요구되는 조회 결과**만 보고 보기를 보기 전에 SQL을 직접 작성하라.
검증: `tools/answer_specs/exam15.py`에서 해당 문제의 보기 하나를 자기 SQL로 바꾸고 `python3 tools/gen_exam.py && python3 tools/run_labs.py 15_integrated_exam`을 실행한다. 비교표에서 그 보기가 MATCH인지 확인한다.

추가 직접 작성 문제(정답은 ../answers/README.md)
* X1. 장르별로 '찜은 됐지만 한 번도 시청되지 않은 콘텐츠 수'를 구하라.
* X2. 고객별 마지막 시청일과, 마지막 시청 콘텐츠의 제목을 구하라(윈도우 함수와 서브쿼리 두 방법).
* X3. 등급별 고객 수를 구하라. 등급이 없는 고객은 '미지정'으로 한 그룹에 넣는다.
