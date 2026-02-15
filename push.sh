#!/bin/bash

# push.sh - sandbox 안의 커밋을 호스트를 통해 안전하게 push
# 인증 정보가 sandbox 안으로 들어가지 않습니다.
#
# Usage:
#   ./push.sh                              # sandbox + 프로젝트 자동 감지
#   ./push.sh <sandbox-name>               # sandbox 지정
#   ./push.sh <sandbox-name> <project-path> # 모두 지정

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

usage() {
    cat <<'EOF'
Usage: ./push.sh [sandbox-name] [project-path]

sandbox 안의 git 커밋을 호스트를 통해 안전하게 push합니다.
인증 정보(토큰, SSH 키)는 sandbox에 들어가지 않습니다.

Arguments:
  <sandbox-name>    (선택) sandbox 이름 — 생략 시 자동 감지
  <project-path>    (선택) sandbox 내 프로젝트 경로 — 생략 시 .last_project에서 읽기

Options:
  --help, -h        이 도움말 출력

동작 흐름:
  1. sandbox에서 git bundle 생성 (커밋만 추출)
  2. bundle을 호스트로 복사
  3. 호스트에서 push (호스트의 git 인증 사용)
  4. 임시 파일 정리
EOF
}

# ─── Argument parsing ────────────────────────────────────
SANDBOX_NAME=""
PROJECT_PATH=""

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
            if [ -z "$SANDBOX_NAME" ]; then
                SANDBOX_NAME="$1"
            elif [ -z "$PROJECT_PATH" ]; then
                PROJECT_PATH="$1"
            fi
            shift
            ;;
    esac
done

echo ""
echo -e "${BOLD}=== push.sh ===${NC}"
echo ""

# ─── Pre-flight checks ──────────────────────────────────
if ! command -v docker &> /dev/null; then
    error "Docker가 설치되어 있지 않습니다."
    exit 1
fi

if ! docker info &> /dev/null; then
    error "Docker가 실행 중이 아닙니다."
    exit 1
fi

# ─── Find sandbox ────────────────────────────────────────
if [ -z "$SANDBOX_NAME" ]; then
    info "실행 중인 sandbox 검색 중..."
    SANDBOX_NAME=$(docker sandbox ls -q 2>/dev/null | head -1)

    if [ -z "$SANDBOX_NAME" ]; then
        error "실행 중인 sandbox를 찾을 수 없습니다."
        echo ""
        echo "  sandbox 목록 확인: docker sandbox ls"
        echo "  직접 지정:        ./push.sh <sandbox-name>"
        echo ""
        exit 1
    fi
fi
ok "Sandbox: $SANDBOX_NAME"

# ─── Find project path ──────────────────────────────────
if [ -z "$PROJECT_PATH" ]; then
    info "프로젝트 경로 감지 중..."

    # sandbox.sh가 clone한 경로에서 .last_project 읽기
    PROJECT_PATH=$(docker sandbox exec "$SANDBOX_NAME" \
        cat /tmp/claude-code-base-repo/.last_project 2>/dev/null || echo "")

    if [ -z "$PROJECT_PATH" ]; then
        error "프로젝트 경로를 자동 감지할 수 없습니다."
        echo ""
        echo "  직접 지정: ./push.sh $SANDBOX_NAME /path/to/project"
        echo ""
        exit 1
    fi
fi
ok "프로젝트: $PROJECT_PATH"

# ─── Get git info ────────────────────────────────────────
REMOTE_URL=$(docker sandbox exec "$SANDBOX_NAME" \
    git -C "$PROJECT_PATH" remote get-url origin 2>/dev/null || echo "")

if [ -z "$REMOTE_URL" ]; then
    error "git remote URL을 가져올 수 없습니다."
    exit 1
fi

BRANCH=$(docker sandbox exec "$SANDBOX_NAME" \
    git -C "$PROJECT_PATH" branch --show-current 2>/dev/null || echo "main")

info "Remote: $REMOTE_URL"
info "Branch: $BRANCH"

# ─── Check for unpushed commits ──────────────────────────
COMMIT_COUNT=$(docker sandbox exec "$SANDBOX_NAME" \
    git -C "$PROJECT_PATH" rev-list --count "origin/${BRANCH}..${BRANCH}" 2>/dev/null || echo "0")

if [ "$COMMIT_COUNT" = "0" ]; then
    ok "push할 커밋이 없습니다."
    exit 0
fi

info "${COMMIT_COUNT}개의 커밋을 push합니다."

# ─── Create bundle in sandbox ────────────────────────────
info "Git bundle 생성 중..."
docker sandbox exec "$SANDBOX_NAME" \
    git -C "$PROJECT_PATH" bundle create /tmp/push.bundle "origin/${BRANCH}..${BRANCH}"

# ─── Copy bundle to host ────────────────────────────────
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

info "Bundle을 호스트로 복사 중..."
docker sandbox exec "$SANDBOX_NAME" cat /tmp/push.bundle > "$TEMP_DIR/push.bundle"

# ─── Push from host ──────────────────────────────────────
info "호스트에서 push 중... (호스트의 git 인증 사용)"

git clone --depth 1 --branch "$BRANCH" "$REMOTE_URL" "$TEMP_DIR/repo" 2>/dev/null
cd "$TEMP_DIR/repo"
git pull "$TEMP_DIR/push.bundle" "$BRANCH" --ff-only
git push origin "$BRANCH"

# ─── Cleanup sandbox ────────────────────────────────────
docker sandbox exec "$SANDBOX_NAME" rm -f /tmp/push.bundle 2>/dev/null || true

echo ""
ok "Push 완료! (${COMMIT_COUNT}개 커밋)"
echo ""
