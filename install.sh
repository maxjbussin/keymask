#!/usr/bin/env bash
# keymask installer
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/maxjbussin/keymask/main/install.sh | bash
#
# Or manually:
#   git clone https://github.com/maxjbussin/keymask.git
#   cd keymask && ./install.sh

set -e

REPO_RAW="https://raw.githubusercontent.com/maxjbussin/keymask/main"
INSTALL_DIR="${KEYMASK_INSTALL_DIR:-$HOME/.local/bin}"
SCRIPT_PATH="$INSTALL_DIR/keymask"
SHELL_RC=""

if [ -n "$ZSH_VERSION" ] || [ "$(basename "$SHELL")" = "zsh" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ] || [ "$(basename "$SHELL")" = "bash" ]; then
    SHELL_RC="$HOME/.bashrc"
fi

echo "keymask installer"
echo "  install dir: $INSTALL_DIR"
echo "  shell rc:    ${SHELL_RC:-(none detected, skipping)}"
echo ""

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: python3 is required but not found in PATH"
    exit 1
fi

mkdir -p "$INSTALL_DIR"

if [ -f "./keymask" ]; then
    echo "→ installing from local ./keymask"
    cp ./keymask "$SCRIPT_PATH"
else
    echo "→ downloading from $REPO_RAW"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$REPO_RAW/keymask" -o "$SCRIPT_PATH"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "$REPO_RAW/keymask" -O "$SCRIPT_PATH"
    else
        echo "ERROR: need curl or wget"
        exit 1
    fi
fi

chmod +x "$SCRIPT_PATH"
echo "→ installed: $SCRIPT_PATH"

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    if [ -n "$SHELL_RC" ] && ! grep -q "$INSTALL_DIR" "$SHELL_RC" 2>/dev/null; then
        echo "" >> "$SHELL_RC"
        echo "# keymask" >> "$SHELL_RC"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
        echo "→ added $INSTALL_DIR to PATH in $SHELL_RC"
        echo "  run \`source $SHELL_RC\` (or open a new terminal) to pick it up"
    else
        echo "→ NOTE: add this to your shell rc:"
        echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
fi

if [ "$(uname)" = "Darwin" ] && [ -n "$SHELL_RC" ] && ! grep -q "pbredact" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" << 'RCEOF'

# keymask: sanitize clipboard in place (macOS)
pbredact() {
    pbpaste | keymask | pbcopy
}
RCEOF
    echo "→ added pbredact() shell function"
fi

echo ""
echo "✓ done. test it:"
echo "    echo 'OPENROUTER_API_KEY=sk-or-v1-FAKEabc1234567890fakedef1234567890abc' | keymask"
