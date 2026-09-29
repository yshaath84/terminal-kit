# WSL only. Windows folders on PATH make Tab-completion of commands take MINUTES (every folder is scanned
# over the slow /mnt/c filesystem: 106 s measured for `compgen -c`, 0.1 s without). So drop them from PATH
# and expose just the few Windows tools you need as functions.
# Add your own in ~/.bashrc BEFORE the terminal-kit loader:
#   WSL_WIN_TOOLS=("code=/mnt/c/Program Files/Microsoft VS Code/bin/code" "mytool=/mnt/c/tools/mytool.exe")
[[ -n ${WSL_DISTRO_NAME-} ]] || return 0
IFS=: read -ra _dirs <<< "$PATH"; _p=
for _d in "${_dirs[@]}"; do [[ $_d == /mnt/* ]] || _p+=${_p:+:}$_d; done
PATH=$_p; unset _dirs _p _d
_wintool() { [ -x "$2" ] && eval "$1() { \"$2\" \"\$@\"; }"; }   # _wintool <name> <full path>
_wintool powershell.exe /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
_wintool cmd.exe        /mnt/c/Windows/System32/cmd.exe
_wintool explorer.exe   /mnt/c/Windows/explorer.exe
_wintool clip.exe       /mnt/c/Windows/System32/clip.exe
for _e in "${WSL_WIN_TOOLS[@]}"; do _wintool "${_e%%=*}" "${_e#*=}"; done; unset _e
