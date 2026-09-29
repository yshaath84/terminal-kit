# winpath (WSL only). Windows folders on PATH make Tab-completion of commands take MINUTES (every folder
# is scanned over the slow /mnt/c filesystem: 106 s measured for `compgen -c`, 0.1 s without). So drop them
# from PATH and keep the common Windows programs runnable as functions. Add your own in config.sh:
#   WSL_WIN_TOOLS=("mytool=/mnt/c/tools/mytool.exe")      (a glob like /mnt/c/Users/*/... works too)
[[ -n ${WSL_DISTRO_NAME-} ]] || return 0
IFS=: read -ra _dirs <<< "$PATH"; _p=
for _d in "${_dirs[@]}"; do [[ $_d == /mnt/* ]] || _p+=${_p:+:}$_d; done
PATH=$_p; unset _dirs _p _d

# _winfind <path-or-glob>...: print the first one that exists. Runs when the tool is used, not at startup.
_winfind() { local IFS= p c; for p in "$@"; do for c in $p; do [ -x "$c" ] && { echo "$c"; return; }; done; done; return 1; }
# _wintool <name> <path-or-glob>...: define <name> as a function that runs the first match
_wintool() {
  local n=$1 q; shift
  type -P "$n" >/dev/null && return   # a Linux build of it already exists; keep that
  printf -v q '%q ' "$@"
  eval "$n() { local e; e=\$(_winfind $q) || { echo '$n: not found on Windows' >&2; return 127; }; \"\$e\" \"\$@\"; }"
}
_wintool code          "/mnt/c/Users/*/AppData/Local/Programs/Microsoft VS Code/bin/code" \
                       "/mnt/c/Program Files/Microsoft VS Code/bin/code"
_wintool explorer.exe  /mnt/c/Windows/explorer.exe
_wintool clip.exe      /mnt/c/Windows/System32/clip.exe
_wintool cmd.exe       /mnt/c/Windows/System32/cmd.exe
_wintool powershell.exe /mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
for _e in "${WSL_WIN_TOOLS[@]}"; do _wintool "${_e%%=*}" "${_e#*=}"; done; unset _e
