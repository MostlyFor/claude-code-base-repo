---
name: test-gen
description: 코드 분석 후 테스트 케이스 자동 생성
disable-model-invocation: true
---
# Test Generation

대상 코드를 분석하고 테스트 케이스를 생성합니다: $ARGUMENTS

## Workflow

1. **대상 코드 분석**
   - 파일 또는 함수 읽기
   - 입력/출력 타입 파악
   - 의존성 및 사이드 이펙트 확인
   - 기존 테스트 패턴 확인 (있으면 따름)

2. **테스트 케이스 설계**
   - **Happy path**: 정상 동작 케이스
   - **Edge cases**: 경계값, 빈 입력, None/null
   - **Error handling**: 예외 발생 케이스, 잘못된 입력
   - 기존 프로젝트의 테스트 구조와 네이밍 컨벤션을 따름

3. **테스트 작성**
   - CLAUDE.md에 정의된 테스트 프레임워크 사용 (없으면 pytest 기본)
   - 기존 테스트 파일 위치 패턴을 따름
   - fixture/mock은 필요한 경우에만 사용
   - 각 테스트에 명확한 이름 부여 (`test_<동작>_<조건>_<기대결과>`)

4. **검증**
   - CLAUDE.md에 정의된 테스트 명령어로 실행 (없으면 `pytest -v`)
   - 모든 테스트 통과 확인
   - CLAUDE.md에 정의된 린터로 스타일 검사

## Output Format
```
## Generated Tests

### File: <test-file-path>
- test_<name>: <설명>
- test_<name>: <설명>
...

### Coverage
- Happy path: N tests
- Edge cases: N tests
- Error handling: N tests

### Run Result
[테스트 실행 결과]
```
