# claude-code-base-repo

Docker sandbox 안에서 프로젝트를 세팅하고, 내장된 skills/agents/hooks로 바로 바이브 코딩을 시작하세요.

## Quick Start

```bash
# 방법 1: 한 줄로 sandbox + 프로젝트 세팅
./sandbox.sh https://github.com/user/my-project

# 방법 2: sandbox만 생성
./sandbox.sh
```

### 글로벌 설치 (선택)

```bash
# 설치 후 어디서든 codebase 명령어 사용
curl -fsSL https://raw.githubusercontent.com/MostlyFor/claude-code-base-repo/main/install.sh | bash

# 이후
codebase https://github.com/user/my-project
```

### sandbox 안에서 직접 사용

```bash
# sandbox 안에서 이 레포를 직접 사용할 수도 있습니다
git clone https://github.com/MostlyFor/claude-code-base-repo
cd claude-code-base-repo
./codebase.sh https://github.com/user/my-project
cd workspace/my-project
```

## 왜 이 도구를 쓰는가?

sandbox 안에서 직접 프로젝트를 clone하고 작업할 수 있지만, 매번 skills/agents를 설정하고 CLAUDE.md를 작성하는 건 번거롭습니다.

**이 도구가 해결하는 것:**

1. **명령어 하나로 끝** - git URL만 주면 sandbox 생성 → clone → 설정 주입까지 자동
2. **내장 skills** - 이슈 수정, 코드 리뷰, 테스트 생성, 디버깅, 리팩토링 즉시 사용
3. **내장 agent** - 테스트 실행 및 자동 수정(`test-runner`)
4. **자동 lint hook** - Python 파일 수정 시 ruff로 자동 포맷팅

## sandbox.sh 사용법

호스트 머신에서 Docker sandbox를 한 줄로 생성합니다.

```bash
# sandbox + 프로젝트 세팅
./sandbox.sh https://github.com/user/repo

# sandbox만 생성 (프로젝트 없이)
./sandbox.sh
```

**동작 흐름:**
1. Docker Desktop 설치/실행 여부 확인
2. `docker sandbox` 명령어 사용 가능 여부 확인
3. sandbox 진입 → 자동으로 이 레포 clone → `codebase.sh`로 프로젝트 세팅

**사전 요구사항:**
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) 설치 및 실행
- [Docker Sandbox](https://docs.docker.com/ai/sandboxes/) 기능 활성화

## codebase.sh 사용법

sandbox 내부에서 프로젝트를 세팅하는 CLI 도구입니다.

```bash
# git repo URL로 새 프로젝트 시작
./codebase.sh https://github.com/user/repo

# 로컬 경로로 기존 프로젝트 사용
./codebase.sh ./my-project

# 마지막 프로젝트 이어서 작업
./codebase.sh --resume
```

### 동작 흐름

1. git URL → `workspace/`에 clone (이미 있으면 pull)
2. 대상 프로젝트에 `.claude/` 설정 주입 (skills, agents, hooks)
3. `CLAUDE.md`가 없으면 템플릿에서 생성

## 내장 구성

### Skills (`.claude/skills/`)

| 스킬 | 호출 | 설명 |
|------|------|------|
| fix-issue | `/fix-issue <issue-number>` | GitHub 이슈 분석 → 테스트 작성 → 수정 → 검증 |
| review | `/review <file-or-path>` | 코드 품질, 보안, 성능 체크리스트 기반 리뷰 |
| test-gen | `/test-gen <file-or-function>` | 코드 분석 → 테스트 케이스 자동 생성 |
| debug | `/debug <설명>` | 버그 재현 → 원인 분석 → 수정 → 회귀 테스트 |
| refactor | `/refactor <대상>` | 코드 스멜 분석 → 리팩토링 계획 → 점진적 수정 → 검증 |

### Agents (`.claude/agents/`)

| 에이전트 | 설명 |
|----------|------|
| test-runner | 테스트 실행 → 실패 분석 → 자동 수정 → 재검증 |

### Hooks (`.claude/settings.json`)

| 트리거 | 동작 |
|--------|------|
| Python 파일 Edit/Write 후 | `ruff check --fix` + `ruff format` 자동 실행 |

## 커스터마이즈

기본 설정을 주입하지만, 기존 파일을 덮어쓰지 않습니다. 프로젝트에 맞게 자유롭게 수정하세요.

### 새 skill 추가

`.claude/skills/` 디렉토리에 마크다운 파일을 추가:

```markdown
# .claude/skills/deploy.md

## Trigger
/deploy <environment>

## Instructions
1. 테스트 실행
2. 빌드 생성
3. 배포 실행
```

### 새 agent 추가

`.claude/agents/` 디렉토리에 마크다운 파일을 추가:

```markdown
# .claude/agents/code-reviewer.md

## Role
코드 리뷰 전문가

## Tools
Read, Grep, Glob
```

### hooks 수정

`.claude/settings.json`에서 hooks 설정을 변경:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "your-lint-command"
          }
        ]
      }
    ]
  }
}
```

## 프로젝트 구조

```
claude-code-base-repo/
├── sandbox.sh               # 호스트용 sandbox 생성 wrapper
├── install.sh               # 글로벌 설치 스크립트
├── codebase.sh              # sandbox 내부 프로젝트 세팅 CLI
├── CLAUDE.md.template       # 프로젝트 CLAUDE.md 템플릿
├── scripts/
│   └── setup-claude.sh      # 설정 주입 유틸리티
├── .claude/
│   ├── settings.json        # hooks 설정
│   ├── skills/
│   │   ├── fix-issue.md     # 이슈 수정 스킬
│   │   ├── review.md        # 코드 리뷰 스킬
│   │   ├── test-gen.md      # 테스트 생성 스킬
│   │   ├── debug.md         # 디버깅 스킬
│   │   └── refactor.md      # 리팩토링 스킬
│   └── agents/
│       └── test-runner.md   # 테스트 실행 에이전트
└── workspace/               # clone된 프로젝트 (git-ignored)
```

## 참고 리소스

- [Docker Sandboxes 공식 문서](https://docs.docker.com/ai/sandboxes/)
- [Claude Code 공식 문서](https://code.claude.com/docs)
- [anthropics/skills](https://github.com/anthropics/skills) - 공식 스킬 패턴
