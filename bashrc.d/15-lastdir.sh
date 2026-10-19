# lastdir: a new terminal opens where you last were. Turn off with TK_DISABLE=(lastdir); `cd` alone goes home.
# Only when the shell starts at a default place (~, or the Windows home /mnt/c/Users/NAME): a terminal
# opened in a folder on purpose (VS Code, `work`'s tmux panes) stays there.
_tk_lastdir=${XDG_STATE_HOME:-$HOME/.local/state}/terminal-kit/lastdir

# restore
if [[ $PWD == "$HOME" || $PWD =~ ^/mnt/[a-z]/Users/[^/]+$ ]] && [ -r "$_tk_lastdir" ]; then
  read -r _d < "$_tk_lastdir"
  [[ -n $_d && $_d != "$PWD" && -d $_d ]] && builtin cd -- "$_d"
  unset _d
fi

# save on every prompt, but only write when the folder changed (a builtin printf, no fork)
_tk_lastdir_saved=$PWD
_tk_lastdir_save() {
  [[ $PWD == "$_tk_lastdir_saved" ]] && return
  _tk_lastdir_saved=$PWD
  [ -d "${_tk_lastdir%/*}" ] || mkdir -p "${_tk_lastdir%/*}"
  printf '%s\n' "$PWD" > "$_tk_lastdir"
}
if [[ ${BLE_VERSION-} ]]; then blehook PRECMD+=_tk_lastdir_save
else PROMPT_COMMAND="_tk_lastdir_save${PROMPT_COMMAND:+;$PROMPT_COMMAND}"; fi
