# terminal-kit loader, sourced from ~/.bashrc. Modules load straight from the repo,
# so a `git pull` (kit-update) brings new files in with no re-linking.
for _f in ~/.terminal-kit/bashrc.d/*.sh; do . "$_f"; done; unset _f
[[ ${BLE_VERSION-} ]] && ble-attach   # must run last
