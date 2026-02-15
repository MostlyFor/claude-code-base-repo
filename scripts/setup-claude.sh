#!/bin/bash

# Claude Code Template Setup Script

set -e

echo "=== Claude Code Template Setup ==="
echo ""

# Check if CLAUDE.md exists
if [ -f "CLAUDE.md" ]; then
    echo "[!] CLAUDE.md already exists. Skipping..."
else
    if [ -f "CLAUDE.md.template" ]; then
        echo "[*] Creating CLAUDE.md from template..."
        cp CLAUDE.md.template CLAUDE.md
        echo "[+] CLAUDE.md created. Please customize it for your project."
    else
        echo "[!] CLAUDE.md.template not found."
    fi
fi

# Check .claude directory
if [ -d ".claude" ]; then
    echo "[+] .claude directory found."

    # List skills
    if [ -d ".claude/skills" ]; then
        echo ""
        echo "Available skills:"
        for skill in .claude/skills/*.md; do
            if [ -f "$skill" ]; then
                name=$(basename "$skill" .md)
                echo "  - /$name"
            fi
        done
    fi

    # List agents
    if [ -d ".claude/agents" ]; then
        echo ""
        echo "Available agents:"
        for agent in .claude/agents/*.md; do
            if [ -f "$agent" ]; then
                name=$(basename "$agent" .md)
                echo "  - $name"
            fi
        done
    fi
else
    echo "[!] .claude directory not found."
fi

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "1. Edit CLAUDE.md to match your project"
echo "2. Run 'claude' to start Claude Code"
echo "3. Use '/skills' to see available skills"
echo "4. Use '/agents' to see available agents"
