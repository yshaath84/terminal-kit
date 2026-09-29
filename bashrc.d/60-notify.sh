# Windows toast for long commands (needs ble.sh)
# --- notify on long commands (Windows toast via ble.sh hooks) ---
NOTIFY_AFTER=${NOTIFY_AFTER:-30}   # seconds; set it in ~/.config/terminal-kit/config.sh
_toast() {  # _toast <title> <body>
  local t=${1//[\'\"\`\$]/} b=${2//[\'\"\`\$]/}
  powershell.exe -NoProfile -Command "[void][Windows.UI.Notifications.ToastNotificationManager,Windows.UI.Notifications,ContentType=WindowsRuntime]; \$x=[Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent('ToastText02'); \$n=\$x.GetElementsByTagName('text'); [void]\$n[0].AppendChild(\$x.CreateTextNode('$t')); [void]\$n[1].AppendChild(\$x.CreateTextNode('$b')); [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\\WindowsPowerShell\\v1.0\\powershell.exe').Show([Windows.UI.Notifications.ToastNotification]::new(\$x))" >/dev/null 2>&1 &
  disown
}
_notify_start() { _cmd_t0=$SECONDS; _cmd_txt=$1; }
_notify_end() {
  local rc=$? d; [[ -n ${_cmd_t0-} ]] || return; d=$((SECONDS - _cmd_t0)); _cmd_t0=
  (( d >= NOTIFY_AFTER )) || return
  [[ $_cmd_txt =~ ^(mc|micro|edit|lazygit|git-ui|btop|monitor|claude|ai|files|menu|less|man|ssh|vim|nano|top)([[:space:]]|$) ]] && return
  _toast "$( ((rc==0)) && echo "Done" || echo "Failed (exit $rc)" ) - $((d/60))m $((d%60))s" "${_cmd_txt:0:80}"
}
if [[ ${BLE_VERSION-} ]] && command -v powershell.exe >/dev/null; then blehook PREEXEC+=_notify_start; blehook PRECMD+=_notify_end; fi
# --- end notify ---
