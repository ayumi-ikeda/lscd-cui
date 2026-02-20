#!/bin/bash

# lscd - Directory Changer CLI Tool
# Version: 0.0.1
# Specification: Based on lscd_spec.md

VERSION="0.0.1"

# Function to display help
show_help() {
    cat << EOF
Usage: lscd [OPTION]... [ls OPTION]...

A CLI tool that provides a TUI menu for selecting subdirectories within the current directory and launching a subshell in the selected location.

Options:
  -h, --help     Display this help and exit
  -v, --version  Display version ($VERSION) and exit

Standard 'ls' flags (e.g., -a, -t) are supported and passed to the underlying discovery logic.

Example:
  lscd -a        Include hidden directories in the menu
EOF
}

# Parse command line arguments
LS_OPTS=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            echo "lscd version $VERSION"
            exit 0
            ;;
        *)
            LS_OPTS+=("$1")
            shift
            ;;
    esac
done

# 1. Directory Discovery
# Use 'ls -1p' to get a single-column list with directory markers (/).
# '--color=never' ensures that escape sequences don't break our grep/sed processing.
# Filter for directories (lines ending in /), then remove the marker.
# We also exclude '.' and '..' as per requirements.
mapfile -t dir_list < <(ls -1p --color=never "${LS_OPTS[@]}" 2>/dev/null | grep '/$' | sed 's|/$||' | grep -vE '^\.$|^\.\.$')

# 2. User Interface (TUI)
# If no subdirectories are found, show a message box.
if [[ ${#dir_list[@]} -eq 0 ]]; then
    whiptail --title "lscd" --msgbox "ディレクトリがありません" 8 40
    exit 0
fi

# Prepare menu items for whiptail (tag and item pairs)
menu_items=()
for dir in "${dir_list[@]}"; do
    menu_items+=("$dir" "")
done

# Display the selection menu
# Heights and widths are chosen for a balanced look.
SELECTED_DIR=$(whiptail --title "lscd - Directory Changer" \
    --menu "移動先のディレクトリを選択してください" 20 70 12 \
    "${menu_items[@]}" \
    3>&1 1>&2 2>&3)

# Exit cleanly if the user cancels or presses ESC
[[ -z "$SELECTED_DIR" ]] && exit 0

# 3. Subshell Execution
# Determine the shell (use $SHELL or fallback to bash)
USER_SHELL="${SHELL:-/bin/bash}"
SHELL_NAME=$(basename "$USER_SHELL")

# Prompt prefix with Yellow color (\e[1;33m)
# For Bash, we wrap non-printing characters in \[ \] and for Zsh in %{ %}.
BASH_PREFIX="\[\e[1;33m\][lscd]\[\e[0m\] "
ZSH_PREFIX="%{\e[1;33m%}[lscd]%{\e[0m%} "

# Navigate to the chosen directory
cd "$SELECTED_DIR" || { echo "Error: Cannot enter directory: $SELECTED_DIR"; exit 1; }

# Start-up message
echo "終了して戻るには Ctrl+D または exit"

# Launch the subshell with the modified prompt
if [[ "$SHELL_NAME" == "bash" ]]; then
    # Use a temporary rc file to load the user's settings and then prepend to PS1
    TMP_RC=$(mktemp)
    [[ -f ~/.bashrc ]] && echo "source ~/.bashrc" > "$TMP_RC"
    echo "export PS1=\"$BASH_PREFIX\$PS1\"" >> "$TMP_RC"
    "$USER_SHELL" --rcfile "$TMP_RC"
    rm "$TMP_RC"
elif [[ "$SHELL_NAME" == "zsh" ]]; then
    # For zsh, we use ZDOTDIR to point to a temporary configuration that sources the original
    TMP_ZDIR=$(mktemp -d)
    if [[ -f ~/.zshrc ]]; then
        echo "source ~/.zshrc" > "$TMP_ZDIR/.zshrc"
    fi
    # Prepend to both PS1 and PROMPT to be thorough with different themes
    echo "export PS1=\"$ZSH_PREFIX\$PS1\"" >> "$TMP_ZDIR/.zshrc"
    echo "export PROMPT=\"$ZSH_PREFIX\$PROMPT\"" >> "$TMP_ZDIR/.zshrc"
    ZDOTDIR="$TMP_ZDIR" "$USER_SHELL"
    rm -rf "$TMP_ZDIR"
else
    # Basic fallback for other shells
    export PS1="[lscd] $PS1"
    "$USER_SHELL"
fi