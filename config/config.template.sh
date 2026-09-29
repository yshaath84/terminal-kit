# terminal-kit: your personal settings.
# Loaded before the kit in every new shell. install.sh and kit-update never change this file.

# Switch modules off. Names are the file names in ~/.terminal-kit/bashrc.d without the number:
#   laravel   art, migrate, tinker, logs, newlaravel
#   copilot   greeting, tips, goodbye, and ? / explain / ai (Claude Code, uses your credits)
#   smartcd   `cd name` jumps to a folder you visited before when it isn't here
#   notify    Windows toast when a command takes long (WSL only)
#   winpath   keep Windows folders off PATH so Tab completion stays fast (WSL only)
#   nvm       load nvm only when you first type `nvm` (saves ~2 s per new shell)
#   ble       live completion while you type (ble.sh). Off = shells start in ~0.1 s instead of ~1.5 s,
#             but no live menu, grey suggestions, collapsing prompt or Windows toasts. Keep TK_DISABLE on one line.
# TK_DISABLE=(laravel copilot)

# Name used in the greeting (default: your login name).
# TK_NAME="Sam"

# Seconds a command must run before you get a Windows toast (default 30).
# NOTIFY_AFTER=60

# Windows programs to keep runnable after winpath takes /mnt/c off PATH.
# VS Code, explorer.exe, clip.exe, cmd.exe and powershell.exe are handled for you.
# WSL_WIN_TOOLS=("mytool=/mnt/c/tools/mytool.exe")

# Anything else you want in every shell: aliases, exports, functions.
