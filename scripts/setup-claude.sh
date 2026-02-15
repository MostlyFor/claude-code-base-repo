#!/bin/bash

# setup-claude.sh - Claude Code 설정을 대상 프로젝트에 주입하는 유틸리티
# Usage: ./scripts/setup-claude.sh <target-dir>

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ─── Colors ──────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

ok()   { echo -e "${GREEN}[+]${NC} $1"; }
skip() { echo -e "${YELLOW}[-]${NC} $1 (이미 존재, 스킵)"; }

# ─── Argument check ─────────────────────────────────────
TARGET_DIR="$1"

if [ -z "$TARGET_DIR" ]; then
    echo "Usage: $0 <target-dir>"
    echo ""
    echo "대상 프로젝트 디렉토리에 .claude/ 설정을 주입합니다."
    exit 1
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "[x] 디렉토리가 존재하지 않습니다: $TARGET_DIR"
    exit 1
fi

# ─── Create .claude directory ────────────────────────────
mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/.claude/agents"

# ─── Copy skills (skip existing) ────────────────────────
for skill in "$REPO_DIR/.claude/skills/"*.md; do
    [ -f "$skill" ] || continue
    name=$(basename "$skill")
    if [ -f "$TARGET_DIR/.claude/skills/$name" ]; then
        skip "skills/$name"
    else
        cp "$skill" "$TARGET_DIR/.claude/skills/$name"
        ok "skills/$name 복사 완료"
    fi
done

# ─── Copy agents (skip existing) ────────────────────────
for agent in "$REPO_DIR/.claude/agents/"*.md; do
    [ -f "$agent" ] || continue
    name=$(basename "$agent")
    if [ -f "$TARGET_DIR/.claude/agents/$name" ]; then
        skip "agents/$name"
    else
        cp "$agent" "$TARGET_DIR/.claude/agents/$name"
        ok "agents/$name 복사 완료"
    fi
done

# ─── Copy settings.json (skip if exists) ────────────────
if [ -f "$TARGET_DIR/.claude/settings.json" ]; then
    skip "settings.json"
else
    cp "$REPO_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
    ok "settings.json 복사 완료"
fi

# ─── Create CLAUDE.md from template (skip if exists) ────
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    skip "CLAUDE.md"
else
    if [ -f "$REPO_DIR/CLAUDE.md.template" ]; then
        cp "$REPO_DIR/CLAUDE.md.template" "$TARGET_DIR/CLAUDE.md"
        ok "CLAUDE.md 생성 완료 (템플릿에서 복사)"
    fi
fi

ok "설정 주입 완료"
