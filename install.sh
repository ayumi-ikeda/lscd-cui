#!/bin/bash

# lscd Installer
# This script installs 'lscd' to the user's local bin directory.

TARGET_DIR="/usr/local/bin"
SOURCE_FILE="lscd.sh"
TARGET_NAME="lscd"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: このスクリプトを実行するには管理者権限が必要です。"
    echo "sudo ./install.sh のように実行してください。"
    exit 1
fi

echo "Installing $TARGET_NAME to $TARGET_DIR..."

# Check if source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: $SOURCE_FILE not found in the current directory."
    exit 1
fi

# Copy and rename
cp "$SOURCE_FILE" "$TARGET_DIR/$TARGET_NAME"
chmod +x "$TARGET_DIR/$TARGET_NAME"

echo "Successfully installed to $TARGET_DIR/$TARGET_NAME"

# Check if TARGET_DIR is in PATH
if [[ ":$PATH:" != *":$TARGET_DIR:"* ]]; then
    echo ""
    echo "Warning: $TARGET_DIR is not in your PATH."
    echo "You may need to add the following line to your .bashrc or .zshrc:"
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

echo ""
echo "You can now run '$TARGET_NAME' from your terminal."
