#!/bin/bash

# install.sh - claude-code-base-repo 글로벌 설치 스크립트
# Usage: curl -fsSL https://raw.githubusercontent.com/MostlyFor/claude-code-base-repo/main/install.sh | bash

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
REPO_URL="https://github.com/MostlyFor/claude-code-base-repo"
INSTALL_DIR="$HOME/.claude-codebase"
BIN_DIR="$HOME/.local/bin"

echo ""
echo -e "${BOLD}=== claude-code-base-repo 설치 ===${NC}"
echo ""

# ─── Clone or update ─────────────────────────────────────
if [ -d "$INSTALL_DIR" ]; then
    info "기존 설치 발견. 업데이트 중..."
    git -C "$INSTALL_DIR" pull --ff-only 2>/dev/null || {
        warn "업데이트 실패. 기존 버전으로 유지합니다."
    }
    ok "업데이트 완료"
else
    info "레포지토리 clone 중..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    ok "Clone 완료: $INSTALL_DIR"
fi

# ─── Create bin directory ────────────────────────────────
mkdir -p "$BIN_DIR"

# ─── Create symlinks ─────────────────────────────────────
# codebase 명령어
ln -sf "$INSTALL_DIR/sandbox.sh" "$BIN_DIR/codebase"
chmod +x "$INSTALL_DIR/sandbox.sh"
chmod +x "$INSTALL_DIR/codebase.sh"
ok "심볼릭 링크 생성: $BIN_DIR/codebase → sandbox.sh"

# ─── Check PATH ──────────────────────────────────────────
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    warn "$BIN_DIR 이 PATH에 포함되어 있지 않습니다."
    echo ""
    echo "  아래 줄을 셸 설정 파일에 추가하세요:"
    echo ""

    SHELL_NAME=$(basename "$SHELL")
    case "$SHELL_NAME" in
        zsh)
            echo "    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.zshrc"
            echo "    source ~/.zshrc"
            ;;
        bash)
            echo "    echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc"
            echo "    source ~/.bashrc"
            ;;
        *)
            echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
            ;;
    esac
    echo ""
fi

# ─── Done ─────────────────────────────────────────────────
echo ""
echo -e "${BOLD}=== 설치 완료 ===${NC}"
echo ""
echo -e "  사용법:"
echo -e "    ${BOLD}codebase https://github.com/user/repo${NC}   # sandbox + 프로젝트 세팅"
echo -e "    ${BOLD}codebase${NC}                                  # sandbox만 생성"
echo ""
