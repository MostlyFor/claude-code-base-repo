---
name: fix-issue
description: GitHub 이슈 분석 및 수정
disable-model-invocation: true
---
# Fix GitHub Issue

GitHub 이슈를 분석하고 수정합니다: $ARGUMENTS

## Workflow

1. **이슈 분석**
   ```bash
   gh issue view $ARGUMENTS
   ```
   - 이슈 내용 파악
   - 재현 조건 확인
   - 기대 동작 파악

2. **관련 코드 탐색**
   - 에러 메시지로 검색
   - 관련 파일 식별
   - 기존 테스트 확인

3. **테스트 작성**
   - 실패하는 테스트 먼저 작성
   - 엣지 케이스 포함

4. **수정 구현**
   - 최소한의 변경으로 수정
   - 기존 코드 스타일 유지

5. **검증**
   ```bash
   pytest -v  # 테스트 통과 확인
   ruff check .  # 린트 통과 확인
   ```

6. **커밋 및 PR**
   - 이슈 번호 참조하여 커밋
   - PR 생성 시 이슈 링크

## Commit Message Format
```
fix: <description>

Fixes #<issue-number>

Co-Authored-By: Claude <noreply@anthropic.com>
```
