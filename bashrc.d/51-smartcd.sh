# smartcd: turn off with TK_DISABLE=(smartcd)
# cd: if the folder isn't here, jump to the best zoxide match (and say where)
cd() {
  builtin cd "$@" 2>/dev/null && return
  local t; t=$(zoxide query -- "${1%/}" 2>/dev/null) && [ -d "$t" ] && { echo "→ $t"; builtin cd "$t" || return 1; return 0; }
  builtin cd "$@" || return
}
