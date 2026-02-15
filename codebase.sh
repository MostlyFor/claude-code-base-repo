#!/bin/bash

# codebase.sh - Docker sandbox로 안전한 바이브 코딩을 시작하는 CLI 도구
# Usage: ./codebase.sh <git-url|local-path|--resume> [options]

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE_DIR="$SCRIPT_DIR/workspace"
LAST_PROJECT_FILE="$SCRIPT_DIR/.last_project"

# ─── Colors ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ─── Helper functions ────────────────────────────────────
info()  { echo -e "${BLUE}[*]${NC} $1"; }
ok()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

usage() {
    cat <<'EOF'
Usage: ./codebase.sh <target> [options]

Target:
  <git-url>       Git 레포지토리 URL (workspace/에 clone)
  <local-path>    로컬 프로젝트 경로
  --resume        마지막 프로젝트 이어서 작업

Options:
  --help, -h      이 도움말 출력
  --dry-run       실제 sandbox 실행 없이 설정만 확인

Examples:
  ./codebase.sh https://github.com/user/repo
  ./codebase.sh ~/my-project
  ./codebase.sh --resume
EOF
}

# ─── Argument parsing ────────────────────────────────────
TARGET=""
DRY_RUN=false

if [ $# -eq 0 ]; then
    usage
    exit 1
fi

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            usage
            exit 0
            ;;
        --resume)
            if [ ! -f "$LAST_PROJECT_FILE" ]; then
                error "이전 프로젝트 기록이 없습니다. (.last_project 파일 없음)"
                exit 1
            fi
            TARGET="$(cat "$LAST_PROJECT_FILE")"
            info "마지막 프로젝트 이어서 작업: $TARGET"
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -*)
            error "알 수 없는 옵션: $1"
            usage
            exit 1
            ;;
        *)
            TARGET="$1"
            shift
            ;;
    esac
done

if [ -z "$TARGET" ]; then
    error "대상을 지정해주세요. (git URL, 로컬 경로, 또는 --resume)"
    usage
    exit 1
fi

# ─── Prerequisite checks ────────────────────────────────
echo ""
echo -e "${BOLD}=== codebase.sh ===${NC}"
echo ""

# Check Docker Desktop
info "Docker Desktop 확인 중..."
if ! command -v docker &> /dev/null; then
    error "Docker가 설치되어 있지 않습니다."
    echo "  설치: https://docs.docker.com/desktop/install/mac-install/"
    exit 1
fi

if ! docker info &> /dev/null 2>&1; then
    error "Docker Desktop이 실행 중이 아닙니다. Docker Desktop을 시작해주세요."
    exit 1
fi

# Check docker sandbox command
if ! docker sandbox ls &> /dev/null 2>&1; then
    error "docker sandbox 명령을 사용할 수 없습니다."
    echo "  Docker Desktop 4.57 이상이 필요합니다."
    echo "  확인: docker --version"
    exit 1
fi
ok "Docker Desktop 준비 완료"

# ─── Resolve project path ───────────────────────────────
PROJECT_PATH=""

# Check if target is a git URL
if [[ "$TARGET" =~ ^https?:// ]] || [[ "$TARGET" =~ ^git@ ]]; then
    # Extract repo name from URL
    REPO_NAME=$(basename "$TARGET" .git)

    info "Git 레포지토리 감지: $REPO_NAME"

    mkdir -p "$WORKSPACE_DIR"
    PROJECT_PATH="$WORKSPACE_DIR/$REPO_NAME"

    if [ -d "$PROJECT_PATH" ]; then
        info "기존 clone 발견. 최신 코드 pull 중..."
        git -C "$PROJECT_PATH" pull --ff-only 2>/dev/null || warn "pull 실패 (오프라인이거나 충돌). 기존 코드로 진행합니다."
    else
        info "Clone 중... $TARGET"
        git clone "$TARGET" "$PROJECT_PATH"
    fi
    ok "프로젝트 준비 완료: $PROJECT_PATH"
else
    # Local path
    # Expand ~ to home directory
    TARGET="${TARGET/#\~/$HOME}"

    if [ ! -d "$TARGET" ]; then
        error "디렉토리가 존재하지 않습니다: $TARGET"
        exit 1
    fi

    PROJECT_PATH="$(cd "$TARGET" && pwd)"
    ok "로컬 프로젝트: $PROJECT_PATH"
fi

# ─── Inject .claude/ config ─────────────────────────────
info "Claude Code 설정 주입 중..."
"$SCRIPT_DIR/scripts/setup-claude.sh" "$PROJECT_PATH"

# ─── Save last project ──────────────────────────────────
echo "$PROJECT_PATH" > "$LAST_PROJECT_FILE"

# ─── Summary ─────────────────────────────────────────────
echo ""
echo -e "${BOLD}=== 준비 완료 ===${NC}"
echo ""
echo -e "  프로젝트:  ${GREEN}$PROJECT_PATH${NC}"
echo -e "  Skills:    /fix-issue, /review"
echo -e "  Agents:    test-runner"
echo -e "  Hooks:     Python auto-lint (ruff)"
echo ""

# ─── Launch sandbox ──────────────────────────────────────
if [ "$DRY_RUN" = true ]; then
    info "[dry-run] 다음 명령어가 실행될 예정입니다:"
    echo "  docker sandbox run claude $PROJECT_PATH"
    exit 0
fi

info "Docker Sandbox 시작 중..."
echo ""
exec docker sandbox run claude "$PROJECT_PATH"
