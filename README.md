# Claude Code Template

Claude Code 프로젝트를 위한 템플릿 레포지토리입니다.

## Quick Start

### 1. API 키 설정
```bash
echo 'export ANTHROPIC_API_KEY=sk-ant-api03-your-key' >> ~/.zshrc
source ~/.zshrc
# Docker Desktop 재시작!
```

### 2. Docker Sandbox로 실행
```bash
docker sandbox run claude ~/my-project
```

끝! 🎉

## 상세 가이드

- **Docker Sandbox 사용법**: [DOCKER_SANDBOX_GUIDE.md](./DOCKER_SANDBOX_GUIDE.md)

## 포함된 구성

### Skills (`.claude/skills/`)
| 스킬 | 설명 | 호출 |
|------|------|------|
| fix-issue | GitHub 이슈 수정 | `/fix-issue <issue-number>` |
| review | 코드 리뷰 | `/review <file-or-path>` |

### Agents (`.claude/agents/`)
| 에이전트 | 설명 |
|----------|------|
| test-runner | 테스트 실행 및 수정 |

### Hooks
- Python 파일 수정 시 자동 lint/format (ruff)

## 프로젝트 구조

```
.
├── CLAUDE.md.template      # 프로젝트 CLAUDE.md 템플릿
├── DOCKER_SANDBOX_GUIDE.md # Docker Sandbox 가이드
├── .claude/
│   ├── settings.json       # Claude Code 설정
│   ├── skills/             # 스킬 파일들
│   └── agents/             # 에이전트 파일들
└── scripts/
    └── setup-claude.sh     # 초기 설정 스크립트
```

## 새 프로젝트 시작 방법

### GitHub Template 사용 시
1. "Use this template" 클릭
2. 새 레포 생성
3. `./scripts/setup-claude.sh` 실행
4. `docker sandbox run claude .`

### 수동 설정 시
```bash
git clone https://github.com/your/claude-code-template my-project
cd my-project
mv CLAUDE.md.template CLAUDE.md
# CLAUDE.md 수정
docker sandbox run claude .
```

## 참고 리소스

- [Docker Sandboxes 공식 문서](https://docs.docker.com/ai/sandboxes/)
- [Claude Code 공식 문서](https://code.claude.com/docs)
- [anthropics/skills](https://github.com/anthropics/skills) - 공식 스킬 패턴
