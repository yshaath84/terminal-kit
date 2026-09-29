# nvm: loading nvm.sh costs ~2 s in every new shell. Put your default node on PATH now and load nvm
# itself the first time you type `nvm`. install.sh comments out the usual nvm lines in ~/.bashrc
# (tagged terminal-kit:nvm-off) so this can take over; TK_DISABLE=(nvm) + kit-update puts them back.
export NVM_DIR=${NVM_DIR:-$HOME/.nvm}
[ -s "$NVM_DIR/nvm.sh" ] || return 0
[[ $(type -t nvm) == function ]] && return 0   # nvm was loaded some other way; leave it alone
# ponytail: only an exact default like v24.1.0 is honoured; "lts/*" or "24" fall back to the newest installed
_nv=$(cat "$NVM_DIR/alias/default" 2>/dev/null)
[ -n "$_nv" ] && [ -d "$NVM_DIR/versions/node/$_nv" ] || _nv=$(ls -1v "$NVM_DIR/versions/node" 2>/dev/null | tail -1)
[ -n "$_nv" ] && PATH="$NVM_DIR/versions/node/$_nv/bin:$PATH"; unset _nv
nvm() {
  unset -f nvm
  . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  nvm "$@"
}
