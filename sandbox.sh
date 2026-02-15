#!/bin/bash

# sandbox.sh - 호스트에서 Docker sandbox를 생성하고 프로젝트를 세팅하는 wrapper
# Usage:
#   ./sandbox.sh https://github.com/user/repo   # sandbox 생성 + 프로젝트 세팅
#   ./sandbox.sh                                  # sandbox만 생성 (프로젝트 없이)

set -e

# ─── Colors ──────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info()  { echo -e "${BLUE}[*]${NC} $1"; }
ok()    { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; }

# ─── Constants ───────────────────────────────────────────
CODEBASE_REPO="https://github.com/MostlyFor/claude-code-base-repo"

# ─── Usage ───────────────────────────────────────────────
usage() {
    cat <<'EOF'
Usage: ./sandbox.sh [git-url]

Docker sandbox를 생성하고, 선택적으로 프로젝트를 세팅합니다.

Arguments:
  <git-url>       (선택) 프로젝트 Git URL — sandbox 진입 후 자동 세팅
                  생략 시 sandbox만 생성

Options:
  --help, -h      이 도움말 출력

Examples:
  ./sandbox.sh https://github.com/user/my-project   # sandbox + 프로젝트 세팅
  ./sandbox.sh                                        # sandbox만 생성
EOF
}

# ─── Argument parsing ────────────────────────────────────
PROJECT_URL=""

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-h)
            usage
            exit 0
            ;;
        -*)
            error "알 수 없는 옵션: $1"
            usage
            exit 1
            ;;
        *)
            PROJECT_URL="$1"
            shift
            ;;
    esac
done

# ─── Pre-flight checks ──────────────────────────────────
echo ""
echo -e "${BOLD}=== sandbox.sh ===${NC}"
echo ""

# 1. Docker 설치 확인
if ! command -v docker &> /dev/null; then
    error "Docker가 설치되어 있지 않습니다."
    echo ""
    echo "  Docker Desktop을 설치하세요:"
    echo "  https://www.docker.com/products/docker-desktop/"
    echo ""
    exit 1
fi
ok "Docker 설치 확인"

# 2. Docker 실행 확인
if ! docker info &> /dev/null; then
    error "Docker가 실행 중이 아닙니다. Docker Desktop을 시작하세요."
    exit 1
fi
ok "Docker 실행 확인"

# 3. docker sandbox 명령어 확인
if ! docker sandbox --help &> /dev/null 2>&1; then
    error "'docker sandbox' 명령어를 사용할 수 없습니다."
    echo ""
    echo "  Docker Desktop 최신 버전이 필요합니다."
    echo "  https://docs.docker.com/ai/sandboxes/"
    echo ""
    exit 1
fi
ok "Docker sandbox 사용 가능"

# ─── Build sandbox command ───────────────────────────────
echo ""

if [ -n "$PROJECT_URL" ]; then
    info "프로젝트와 함께 sandbox 생성: $PROJECT_URL"
    echo ""

    # sandbox 진입 후 실행할 명령어 조합
    INIT_CMD="git clone ${CODEBASE_REPO} /tmp/claude-code-base-repo && cd /tmp/claude-code-base-repo && ./codebase.sh ${PROJECT_URL}"

    info "Sandbox 시작 중..."
    echo -e "  진입 후 자동으로 프로젝트가 세팅됩니다."
    echo ""

    docker sandbox run claude --cmd "bash -c '${INIT_CMD}; exec bash'"
else
    info "프로젝트 없이 sandbox 생성"
    echo ""
    echo -e "  sandbox 안에서 수동으로 세팅하려면:"
    echo -e "    git clone ${CODEBASE_REPO}"
    echo -e "    cd claude-code-base-repo"
    echo -e "    ./codebase.sh <your-git-url>"
    echo ""

    docker sandbox run claude
fi
