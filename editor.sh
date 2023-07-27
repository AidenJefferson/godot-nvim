#!/bin/bash
#
# Opens a file in Neovim from Godot, jumping to the correct line and column.
#
# Setup in Godot:
#   Editor -> Editor Settings -> Text Editor -> External
#   - External Editor: Custom
#   - Exec Path: /path/to/this/editor.sh
#   - Exec Flags: {file} {line} {col}
#
# In your shell config (~/.zshrc or ~/.bashrc), add:
#   alias gnvim='nvim --listen /tmp/godot-nvim.sock'
# Then always launch Neovim for Godot work via `gnvim` so this script can find it.

[ "$(uname -s)" != "Darwin" ] && exit 1

FILE="$1"
LINE="${2:-1}"
COL="${3:-1}"
NVIM_SOCKET="/tmp/godot-nvim.sock"

# Walk up from the file's directory to find the Godot project root (contains project.godot).
find_project_root() {
    local dir
    dir="$(dirname "$1")"
    while [[ "$dir" != "/" ]]; do
        [[ -f "$dir/project.godot" ]] && echo "$dir" && return
        dir="$(dirname "$dir")"
    done
    echo "$(dirname "$1")"
}

PROJECT_ROOT="$(find_project_root "$FILE")"

focus_nvim_window() {
    osascript <<EOF
tell application "Terminal"
    repeat with w in windows
        if name of w contains "nvim" then
            set frontmost of w to true
            exit repeat
        end if
    end repeat
    activate
end tell
EOF
}

if [[ -S "$NVIM_SOCKET" ]]; then
    # Open the file and jump to the correct line and column.
    nvim --server "$NVIM_SOCKET" --remote-send "<cmd>cd $PROJECT_ROOT<CR>"
    nvim --server "$NVIM_SOCKET" --remote "$FILE"
    nvim --server "$NVIM_SOCKET" --remote-send "${LINE}G${COL}|"
    focus_nvim_window
else
    # No existing Neovim instance — launch one in a new Terminal window.
    osascript <<EOF
tell application "Terminal"
    activate
    do script "nvim --listen $NVIM_SOCKET -c 'cd $PROJECT_ROOT' '$FILE' +$LINE"
end tell
EOF
fi
