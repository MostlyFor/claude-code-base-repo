---
name: review
description: 코드 리뷰 수행
disable-model-invocation: true
---
# Code Review

코드 리뷰를 수행합니다: $ARGUMENTS

## Checklist

### 코드 품질
- [ ] 함수/클래스 단일 책임 원칙
- [ ] 네이밍이 명확한가
- [ ] 코드 중복 없는가
- [ ] 불필요한 복잡도 없는가

### 타입 안전성
- [ ] Type hints 정확한가
- [ ] Optional 처리 적절한가
- [ ] Any 타입 남용 없는가

### 에러 처리
- [ ] 예외 처리 적절한가
- [ ] 에러 메시지 명확한가
- [ ] 빈 except 절 없는가

### 보안
- [ ] SQL Injection 가능성
- [ ] Command Injection 가능성
- [ ] 하드코딩된 시크릿 없는가
- [ ] 사용자 입력 검증

### 테스트
- [ ] 테스트 커버리지 충분한가
- [ ] 엣지 케이스 테스트
- [ ] 테스트 가독성

### 성능
- [ ] N+1 쿼리 문제
- [ ] 불필요한 반복문
- [ ] 메모리 누수 가능성

## Output Format

```
## Summary
[전체 평가 1-2문장]

## Issues Found

### [Priority: HIGH/MEDIUM/LOW]
- File: path/to/file.py:line
- Issue: [문제 설명]
- Suggestion: [수정 제안]

## Positive Aspects
- [잘된 점]

## Recommended Actions
1. [우선 수정 항목]
```
