---
name: debug
description: 버그 분석 및 수정
disable-model-invocation: true
---
# Debug

버그를 분석하고 수정합니다: $ARGUMENTS

## Workflow

1. **버그 재현**
   - 설명된 증상 파악
   - 관련 코드 탐색 (에러 메시지, 스택 트레이스 기반)
   - 재현 가능한 테스트 케이스 작성 (실패 확인)

2. **원인 분석**
   - 스택 트레이스 추적
   - 관련 함수/모듈 코드 읽기
   - 데이터 흐름 분석
   - 근본 원인(root cause) 식별

3. **수정**
   - 최소한의 변경으로 수정
   - 기존 코드 스타일 유지
   - 사이드 이펙트 없는지 확인

4. **회귀 테스트 작성**
   - 수정된 버그를 검증하는 테스트 추가
   - 같은 종류의 버그를 방지하는 엣지 케이스 포함

5. **검증**
   - CLAUDE.md에 정의된 테스트 명령어 실행 (없으면 `pytest -v`)
   - 전체 테스트 통과 확인
   - CLAUDE.md에 정의된 린터 실행

## Output Format
```
## Bug Report

### Symptom
[증상 설명]

### Root Cause
[근본 원인]

### Fix
- File: <path>:<line>
- Change: [변경 내용]

### Regression Test
- File: <test-path>
- test_<name>: [테스트 설명]

### Verification
[테스트 실행 결과]
```
