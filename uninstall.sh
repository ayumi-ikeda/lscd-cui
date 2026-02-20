#!/bin/bash

# lscd Uninstaller
# This script removes 'lscd' from the user's local bin directory.

TARGET_DIR="/usr/local/bin"
TARGET_NAME="lscd"
TARGET_PATH="$TARGET_DIR/$TARGET_NAME"

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo "Error: このスクリプトを実行するには管理者権限が必要です。"
    echo "sudo ./uninstall.sh のように実行してください。"
    exit 1
fi

echo "Uninstalling $TARGET_NAME from $TARGET_DIR..."

if [ -f "$TARGET_PATH" ]; then
    rm "$TARGET_PATH"
    echo "Successfully removed $TARGET_PATH"
else
    echo "Error: $TARGET_NAME is not found in $TARGET_DIR"
    exit 1
fi

echo "Uninstallation complete."
