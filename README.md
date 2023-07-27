# Neovim as a Godot editor

## Shell

Add to `~/.zshrc`:

    alias gnvim='nvim --listen /tmp/godot-nvim.sock'

Use `gnvim` to open Neovim for Godot work. If not running, the script launches one automatically.

## Godot

    Editor -> Editor Settings -> Text Editor -> External
    External Editor: Custom
    Exec Path:       /path/to/editor.sh
    Exec Flags:      {file} {line} {col}
