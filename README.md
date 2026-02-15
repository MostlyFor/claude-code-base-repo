# claude-code-base-repo

명령어 하나로 Docker sandbox를 구축하고, 보안 걱정 없이 바이브 코딩을 시작하세요.

## 왜 이 도구를 쓰는가?

`docker sandbox run claude` 만으로도 sandbox를 실행할 수 있습니다. 하지만 매번 프로젝트를 연결하고, skills/agents를 설정하고, CLAUDE.md를 작성하는 건 번거롭습니다.

**이 도구가 해결하는 것:**

1. **명령어 하나로 끝** - git URL 또는 로컬 경로만 주면 clone → 설정 주입 → sandbox 실행까지 자동
2. **내장 skills** - GitHub 이슈 수정(`/fix-issue`), 코드 리뷰(`/review`) 즉시 사용
3. **내장 agent** - 테스트 실행 및 자동 수정(`test-runner`)
4. **자동 lint hook** - Python 파일 수정 시 ruff로 자동 포맷팅

## Quick Start

### 사전 준비

- **Docker Desktop 4.57+** ([설치](https://docs.docker.com/desktop/install/mac-install/))
- **Anthropic 계정** - sandbox 실행 후 안내에 따라 로그인

### 시작하기

```bash
# 1. 이 레포를 clone
git clone https://github.com/your/claude-code-base-repo
cd claude-code-base-repo

# 2. 프로젝트와 함께 실행
./codebase.sh https://github.com/user/my-project
```

끝! sandbox 안에서 skills, agents, hooks가 모두 준비된 상태로 Claude Code가 시작됩니다.

## 사용법

```bash
# git repo URL로 새 프로젝트 시작
./codebase.sh https://github.com/user/repo

# 로컬 경로로 기존 프로젝트 사용
./codebase.sh ~/my-project

# 마지막 프로젝트 이어서 작업
./codebase.sh --resume

# 실제 실행 없이 설정만 확인
./codebase.sh --resume --dry-run
```

### 동작 흐름

1. Docker Desktop, API 키 사전 검증
2. git URL → `workspace/`에 clone (이미 있으면 pull)
3. 대상 프로젝트에 `.claude/` 설정 주입 (skills, agents, hooks)
4. `CLAUDE.md`가 없으면 템플릿에서 생성
5. `docker sandbox run claude <project-path>` 실행

## 내장 구성

### Skills (`.claude/skills/`)

| 스킬 | 호출 | 설명 |
|------|------|------|
| fix-issue | `/fix-issue <issue-number>` | GitHub 이슈 분석 → 테스트 작성 → 수정 → 검증 |
| review | `/review <file-or-path>` | 코드 품질, 보안, 성능 체크리스트 기반 리뷰 |

### Agents (`.claude/agents/`)

| 에이전트 | 설명 |
|----------|------|
| test-runner | 테스트 실행 → 실패 분석 → 자동 수정 → 재검증 |

### Hooks (`.claude/settings.json`)

| 트리거 | 동작 |
|--------|------|
| Python 파일 Edit/Write 후 | `ruff check --fix` + `ruff format` 자동 실행 |

## 커스터마이즈

이 도구는 기본 설정을 주입하지만, 기존 파일을 덮어쓰지 않습니다. 프로젝트에 맞게 자유롭게 수정하세요.

### 새 skill 추가

`.claude/skills/` 디렉토리에 마크다운 파일을 추가하면 됩니다:

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

`.claude/agents/` 디렉토리에 마크다운 파일을 추가합니다:

```markdown
# .claude/agents/code-reviewer.md

## Role
코드 리뷰 전문가

## Tools
Read, Grep, Glob
```

### hooks 수정

`.claude/settings.json`에서 hooks 설정을 변경합니다:

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
├── codebase.sh              # 메인 CLI 도구
├── CLAUDE.md.template       # 프로젝트 CLAUDE.md 템플릿
├── scripts/
│   └── setup-claude.sh      # 설정 주입 유틸리티
├── .claude/
│   ├── settings.json        # hooks 설정
│   ├── skills/
│   │   ├── fix-issue.md     # 이슈 수정 스킬
│   │   └── review.md        # 코드 리뷰 스킬
│   └── agents/
│       └── test-runner.md   # 테스트 실행 에이전트
└── workspace/               # clone된 프로젝트 (git-ignored)
```

## Troubleshooting

### `docker sandbox` 명령을 사용할 수 없음

Docker Desktop 4.57 이상이 필요합니다:
```bash
docker --version
```

### 첫 실행이 느림

정상입니다. microVM 초기화 및 이미지 다운로드가 필요합니다. 이후 실행은 빠릅니다.

### 파일 접근 안됨

프로젝트 폴더 경로를 절대 경로로 지정하세요:
```bash
./codebase.sh ~/my-project           # O
./codebase.sh /Users/name/my-project # O
```

### sandbox 관리

```bash
# 실행 중인 sandbox 목록
docker sandbox ls

# sandbox 중지
docker sandbox stop <name>

# sandbox 삭제
docker sandbox rm <name>
```

## 참고 리소스

- [Docker Sandboxes 공식 문서](https://docs.docker.com/ai/sandboxes/)
- [Claude Code 공식 문서](https://code.claude.com/docs)
- [anthropics/skills](https://github.com/anthropics/skills) - 공식 스킬 패턴
