# completion: Tab menu settings
# --- Tab completion menu: list candidates, Tab cycles, Shift-Tab goes back ---
bind 'set colored-stats on' 'set colored-completion-prefix on' 'set mark-directories on' \
     'set completion-map-case on' 'set menu-complete-display-prefix on' 'set completion-query-items 200'
[[ ${BLE_VERSION-} ]] || bind 'TAB:menu-complete' '"\e[Z":menu-complete-backward'
