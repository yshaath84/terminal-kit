#!/usr/bin/env bash
# terminal-kit installer. Safe to run twice.
# Flags: --dry-run (print every change, write nothing)  --no-apt (skip apt)  --no-download (skip starship/delta/ble.sh)
set -euo pipefail
KIT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BIN=$HOME/.local/bin; APT=1; DL=1; DRY=0
for a in "$@"; do case $a in --no-apt) APT=0;; --no-download) DL=0;; --dry-run) DRY=1;; *) echo "unknown flag: $a" >&2; exit 1;; esac; done
say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
# run <cmd...>: execute, or just print it under --dry-run
run() { if [ $DRY = 1 ]; then echo "  would: $*"; else "$@"; fi; }
run mkdir -p "$BIN" "$HOME/.config" "$HOME/.bashrc.d"

# link <src> <dst>: symlink; anything already there (not our link) is moved to <dst>.bak.<time>
link() {
  local src=$1 dst=$2
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then return; fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then run mv "$dst" "$dst.bak.$(date +%s)"; say "backed up $dst"; fi
  run ln -s "$src" "$dst"
}

if [ $APT = 1 ] && command -v apt-get >/dev/null; then
  say "installing packages with apt (asks for your sudo password)"
  if [ $DRY = 1 ]; then echo "  would: sudo apt-get install git curl make gawk lsof bsdextrautils tmux fzf zoxide bat eza fd-find mc micro lazygit btop"; else
  sudo apt-get update -qq
  for p in git curl make gawk lsof bsdextrautils tmux fzf zoxide bat eza fd-find mc micro lazygit btop; do
    if sudo apt-get install -y -qq "$p" >/dev/null 2>&1; then echo "  ok    $p"; else echo "  skip  $p (not available on your system)"; fi
  done
  fi
fi

if [ $DL = 1 ] && [ $DRY = 1 ]; then
  say "would install starship, delta, ble.sh if missing"
elif [ $DL = 1 ]; then
  if ! command -v starship >/dev/null; then
    say "installing starship"; curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$BIN" >/dev/null
  fi
  if ! command -v delta >/dev/null && [ ! -x "$BIN/delta" ]; then
    say "installing delta (pretty git diffs)"
    arch=$(uname -m); tmp=$(mktemp -d)
    url=$(curl -fsSL https://api.github.com/repos/dandavison/delta/releases/latest | grep -o "https://[^\"]*${arch}-unknown-linux-gnu.tar.gz" | head -1 || true)
    if [ -n "$url" ] && curl -fsSL "$url" | tar xz -C "$tmp"; then install -m755 "$tmp"/delta-*/delta "$BIN/delta"; else echo "  skip  delta (download failed)"; fi
    rm -rf "$tmp"
  fi
  if [ ! -r "$HOME/.local/share/blesh/ble.sh" ]; then
    say "installing ble.sh (live completion while you type)"
    tmp=$(mktemp -d)
    if git clone -q --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git "$tmp/ble" && make -s -C "$tmp/ble" install PREFIX="$HOME/.local" >/dev/null; then :; else echo "  skip  ble.sh (build failed)"; fi
    rm -rf "$tmp"
  fi
fi

say "linking config"
for f in "$KIT"/bashrc.d/*.sh; do link "$f" "$HOME/.bashrc.d/$(basename "$f")"; done
link "$KIT/config/starship.toml" "$HOME/.config/starship.toml"
link "$KIT/config/blerc"         "$HOME/.blerc"
link "$KIT/config/tmux.conf"     "$HOME/.tmux.conf"

# git: include our aliases/colors; add the delta look only if delta exists. Your name/email are never touched.
include() { git config --global --get-all include.path 2>/dev/null | grep -qxF "$1" || run git config --global --add include.path "$1"; }
include "$KIT/config/gitconfig"
{ command -v delta >/dev/null || [ -x "$BIN/delta" ]; } && include "$KIT/config/gitconfig-delta"

# ~/.bashrc: two small marked blocks (ble.sh must load first and attach last)
RC=$HOME/.bashrc; [ $DRY = 1 ] || touch "$RC"
if ! grep -qs 'terminal-kit:ble' "$RC"; then
  if [ $DRY = 1 ]; then echo "  would: back up $RC and add the ble.sh line at its top"; else
  cp "$RC" "$RC.bak.$(date +%s)"
  { printf '%s\n' '# terminal-kit:ble  (load ble.sh first; it is attached at the end of this file)' \
                  '[[ $- == *i* && -r ~/.local/share/blesh/ble.sh ]] && source ~/.local/share/blesh/ble.sh --noattach' ''; cat "$RC"; } > "$RC.new"
  mv "$RC.new" "$RC"
  fi
fi
if ! grep -qs 'terminal-kit:loader' "$RC"; then
  if [ $DRY = 1 ]; then echo "  would: append the loader block to $RC"; else
  cat >> "$RC" <<'RCEOF'

# terminal-kit:loader
for _f in ~/.bashrc.d/*.sh; do [ -r "$_f" ] && . "$_f"; done; unset _f
[[ ${BLE_VERSION-} ]] && ble-attach   # keep this last
RCEOF
  fi
fi

if [ $DRY = 1 ]; then say "dry run: nothing was changed"; else say "done. Run:  exec bash   (and set a Nerd Font in your terminal - see README)"; fi
