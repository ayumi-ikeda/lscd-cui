# Specification: lscd (Directory Changer)

## 1. Project Overview

A CLI tool that provides a TUI menu for selecting subdirectories within the current directory and launching a subshell in the selected location.

## 2. Requirements

### A. Directory Discovery

* **Source:** Must list subdirectories from the current working directory.
* **Arguments:** Support standard `ls` flags (e.g., `-a` to show hidden directories).
* **Extraction Logic:** * Correctly identify only directories (avoid listing regular files).
* Exclude current (`.`) and parent (`..`) directories from the list.
* Output must be a clean list of names (no permissions, sizes, or timestamps) to be passed to `whiptail`.

### B. User Interface (TUI)

* **Tool:** Use `whiptail`.
* **Selection Menu:** Display a list of discovered directories.
* **Error Handling:** If no subdirectories are found, display a `whiptail --msgbox` with the message: `"ディレクトリがありません"` (There are no directories).

### C. Subshell Execution

* **Navigation:** `cd` into the user-selected directory.
* **Shell Persistence:** * Determine the user's current shell (e.g., `bash`, `zsh`).
* Launch a new instance of the **same shell** in the target directory.

* **Visual Indicator (Prompt):**
* Prepend `[lscd]` to the `$PS1` prompt in the subshell.
* The prefix `[lscd]` must be colored **Yellow** (`\e[1;33m`).

* **Exit Guide:** Print a message to `stdout` upon subshell start: `"終了して戻るには Ctrl+D または exit"` (Type Ctrl+D or exit to return).

## 3. CLI Interface

* `-h, --help`: Display usage.
* `-v, --version`: Display version (`0.0.1`).
* Supports pass-through options for the underlying `ls` command.

## 4. Technical Constraints

* Ensure compatibility with spaces in directory names (proper quoting).
* The command must terminate cleanly when the subshell is exited, returning the user to the original parent shell and directory.
