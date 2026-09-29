# terminal-kit loader, sourced from ~/.bashrc. Modules load straight from the repo,
# so a `git pull` (kit-update) brings new files in with no re-linking.
# Your settings load first, so they can switch modules off: TK_DISABLE=(laravel copilot ...)
# shellcheck source=/dev/null  # the user's own file
[ -r ~/.config/terminal-kit/config.sh ] && . ~/.config/terminal-kit/config.sh
for _f in ~/.terminal-kit/bashrc.d/*.sh; do
  _m=${_f##*/}; _m=${_m#*-}; _m=${_m%.sh}          # 41-laravel.sh -> laravel
  # shellcheck source=/dev/null  # every module in bashrc.d; each is linted on its own
  [[ " ${TK_DISABLE[*]-} " == *" $_m "* ]] || . "$_f"
done; unset _f _m
[[ ${BLE_VERSION-} ]] && ble-attach   # must run last
