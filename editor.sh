#!/bin/bash
#
# Opens a file within neovim for editing from GODOT
# 
# This is a very bodged solution, it will simply open neovim using the
# file path passed from Godot.
#
# Usage:
#			Within Godot:
#				Editor -> Editor Settings -> Dotnet -> Editor
#
#				set External Editor to Custom
#				set Custom Exec Path to the location of this script
#				set Custom Exec Path Args to {file}
#
# References:
#     I used this website 
#     https://iterm2.com/documentation-scripting.html
# 

# OSX only
[ `uname -s` != "Darwin" ] && return

function launchEditor () {
    local filePath="$@"

    osascript &>/dev/null <<EOF
			#use application iTerm (change to iTerm2 if needed)
			tell application "iTerm"
			
				if name of current session of current window contains "nvim" then
				#already in nvim just split the window (I prefer vsplit)

					tell current session of current window
						write text ":vsplit $filePath"
					end tell

				else
				#need to open nvim 

					tell current session of current window
						write text "nvim $filePath"
					end tell

				end if

				#focus the window
				activate current window 

			end tell
EOF
}

launchEditor $@
