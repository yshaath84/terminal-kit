# completion: Tab menu settings, smart cd (zoxide fallback)
# --- Tab completion menu: list candidates, Tab cycles, Shift-Tab goes back ---
bind 'set colored-stats on' 'set colored-completion-prefix on' 'set mark-directories on' \
     'set completion-map-case on' 'set menu-complete-display-prefix on' 'set completion-query-items 200'
[[ ${BLE_VERSION-} ]] || bind 'TAB:menu-complete' '"\e[Z":menu-complete-backward'

# cd: if the folder isn't here, jump to the best zoxide match (and say where)
cd() {
  builtin cd "$@" 2>/dev/null && return
  local t; t=$(zoxide query -- "${1%/}" 2>/dev/null) && [ -d "$t" ] && { echo "→ $t"; builtin cd "$t"; return; }
  builtin cd "$@"
}
