# Docker Sandbox 사용 가이드

Docker Sandbox로 Claude Code를 안전하게 격리된 환경에서 실행하는 방법입니다.

## 사전 준비

### 1. Docker Desktop 설치
- macOS: [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/)
- 버전 4.57 이상 필요

### 2. API 키 설정 (중요!)

Docker Sandbox는 별도 프로세스에서 실행되므로 환경 변수를 **전역으로** 설정해야 합니다.

```bash
# ~/.zshrc 또는 ~/.bashrc에 추가
echo 'export ANTHROPIC_API_KEY=sk-ant-api03-your-key-here' >> ~/.zshrc

# 적용
source ~/.zshrc

# Docker Desktop 재시작 필요!
```

## 기본 사용법

### Sandbox 생성 및 실행

```bash
# 프로젝트 폴더와 함께 실행
docker sandbox run claude ~/my-project

# 이름 지정하여 실행
docker sandbox run --name my-sandbox claude ~/my-project
```

### Sandbox 관리

```bash
# 실행 중인 sandbox 목록
docker sandbox ls

# sandbox 중지
docker sandbox stop <sandbox-name>

# sandbox 삭제
docker sandbox rm <sandbox-name>

# 중지된 sandbox 재시작
docker sandbox start <sandbox-name>
```

### 프롬프트와 함께 실행

```bash
# 직접 명령 전달
docker sandbox run claude ~/my-project -- "테스트 코드 작성해줘"

# 파일에서 프롬프트 읽기
docker sandbox run claude ~/my-project -- "$(cat prompt.txt)"
```

### 기존 세션 이어서 하기

```bash
docker sandbox run claude ~/my-project -- --continue
```

## 보안 특징

| 보호 영역 | 설명 |
|----------|------|
| 파일시스템 | 마운트된 프로젝트 폴더만 접근 가능 |
| 네트워크 | 격리된 환경에서 실행 |
| 권한 | `--dangerously-skip-permissions` 기본 활성화 |
| 격리 수준 | microVM (컨테이너보다 강력) |

## 주의사항

1. **sandbox는 `docker ps`에 안 보임** → `docker sandbox ls` 사용
2. **첫 실행 시 오래 걸림** → microVM 초기화 + 이미지 다운로드
3. **Docker Desktop 재시작 후 API 키 인식** → 환경 변수 설정 후 필수

## 실제 워크플로우 예시

### 새 프로젝트 시작

```bash
# 1. 프로젝트 폴더 생성
mkdir ~/projects/my-app
cd ~/projects/my-app

# 2. sandbox에서 Claude Code 실행
docker sandbox run claude .

# 3. Claude에게 작업 지시
# (sandbox 안에서 Claude가 실행됨)
```

### 여러 프로젝트 동시 작업

```bash
# 프로젝트 A
docker sandbox run --name project-a claude ~/projects/project-a

# 프로젝트 B (새 터미널에서)
docker sandbox run --name project-b claude ~/projects/project-b

# 목록 확인
docker sandbox ls
```

### 작업 종료

```bash
# sandbox 중지
docker sandbox stop project-a

# 또는 삭제 (데이터는 프로젝트 폴더에 남음)
docker sandbox rm project-a
```

## Troubleshooting

### API 키 인식 안됨
```bash
# 환경 변수 확인
echo $ANTHROPIC_API_KEY

# Docker Desktop 완전 종료 후 재시작
# (메뉴바에서 Quit Docker Desktop)
```

### sandbox가 느림
- 첫 실행 시 정상 (이미지 다운로드)
- 이후 실행은 빠름

### 파일 접근 안됨
- 프로젝트 폴더가 올바르게 마운트되었는지 확인
- 절대 경로 사용 권장: `~/my-project` 또는 `/Users/name/my-project`

## 참고

- [Docker Sandboxes 공식 문서](https://docs.docker.com/ai/sandboxes/)
- [Claude Code 설정 가이드](https://docs.docker.com/ai/sandboxes/claude-code/)
