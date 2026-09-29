#!/usr/bin/env bash
# terminal-kit installer. Safe to run twice.
# Flags: --dry-run (print every change, write nothing)  --uninstall (undo everything install did)  --no-apt (skip apt)  --no-download (skip starship/delta/ble.sh)
set -euo pipefail
KIT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
if ! [ "$KIT" -ef "$HOME/.terminal-kit" ]; then
  echo "terminal-kit must live in ~/.terminal-kit (it is in $KIT). Clone it there:" >&2
  echo "  git clone https://github.com/yshaath84/terminal-kit ~/.terminal-kit && ~/.terminal-kit/install.sh" >&2
  exit 1
fi
KIT=$HOME/.terminal-kit
BIN=$HOME/.local/bin; APT=1; DL=1; DRY=0; UNINSTALL=0
for a in "$@"; do case $a in --no-apt) APT=0;; --no-download) DL=0;; --dry-run) DRY=1;; --uninstall) UNINSTALL=1;; *) echo "unknown flag: $a" >&2; exit 1;; esac; done
say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
# run <cmd...>: execute, or just print it under --dry-run
run() { if [ $DRY = 1 ]; then echo "  would: $*"; else "$@"; fi; }
# --uninstall: undo exactly what install did. Keeps your config.sh, the downloaded tools and ~/.terminal-kit.
if [ $UNINSTALL = 1 ]; then
  say "uninstalling terminal-kit"
  for d in "$HOME/.config/starship.toml" "$HOME/.blerc" "$HOME/.tmux.conf"; do
    [ -L "$d" ] && [[ $(readlink "$d") == "$KIT"/* ]] || continue
    run rm "$d"
    b=$(printf '%s\n' "$d".bak.* | sort -V | tail -1)          # the newest backup install made
    if [ -e "$b" ]; then run mv "$b" "$d"; say "restored $d"; fi
  done
  RC=$HOME/.bashrc
  if grep -qs 'terminal-kit:' "$RC"; then
    run cp "$RC" "$RC.bak.$(date +%s)"
    run sed -i -e '/^# terminal-kit:ble/,+1d' -e '/^# terminal-kit:loader/,+1d' -e 's/^# terminal-kit:nvm-off //' "$RC"
    say "removed the terminal-kit lines from ~/.bashrc (nvm lines restored)"
  fi
  git config --global --get-all include.path 2>/dev/null | grep -F "$KIT/" | while IFS= read -r i; do
    run git config --global --fixed-value --unset include.path "$i"
  done
  say "done. Kept: ~/.config/terminal-kit/config.sh, tools in ~/.local, and ~/.terminal-kit (delete it when you like)."
  [ $DRY = 1 ] || say "Run:  exec bash"
  exit 0
fi

run mkdir -p "$BIN" "$HOME/.config"

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
  # ble.sh is pinned to a commit tested with config/blerc: it handles every keypress, so an untested
  # upstream change could break typing. To move the pin: test a new commit, then change BLE_REF.
  BLE_REF=d81fd54feb0d996fdff20dca27eaf0201f7015cc
  BLE_STAMP=$HOME/.local/share/blesh/.terminal-kit-ref
  if [ "$(cat "$BLE_STAMP" 2>/dev/null)" != "$BLE_REF" ]; then
    say "installing ble.sh ${BLE_REF:0:7} (live completion while you type)"
    tmp=$(mktemp -d)
    # a named remote is needed: the contrib submodule URL is relative to it
    if git -C "$tmp" init -q && git -C "$tmp" remote add origin https://github.com/akinomyoga/ble.sh.git \
       && git -C "$tmp" fetch -q --depth 1 origin "$BLE_REF" \
       && git -C "$tmp" checkout -q FETCH_HEAD && git -C "$tmp" submodule -q update --init --depth 1 \
       && make -s -C "$tmp" install PREFIX="$HOME/.local" >/dev/null; then echo "$BLE_REF" > "$BLE_STAMP"
    else echo "  skip  ble.sh (build failed)"; fi
    rm -rf "$tmp"
  fi
fi

say "linking config"
link "$KIT/config/starship.toml" "$HOME/.config/starship.toml"
link "$KIT/config/blerc"         "$HOME/.blerc"
link "$KIT/config/tmux.conf"     "$HOME/.tmux.conf"

# your personal settings file: created once from the template, never overwritten
CONF=$HOME/.config/terminal-kit/config.sh
if [ ! -e "$CONF" ]; then say "creating $CONF (your settings)"; run mkdir -p "${CONF%/*}"; run cp "$KIT/config/config.template.sh" "$CONF"; fi

# git: include our aliases/colors; add the delta look only if delta exists. Your name/email are never touched.
include() { git config --global --get-all include.path 2>/dev/null | grep -qxF "$1" || run git config --global --add include.path "$1"; }
include "$KIT/config/gitconfig"
{ command -v delta >/dev/null || [ -x "$BIN/delta" ]; } && include "$KIT/config/gitconfig-delta"

# ~/.bashrc: two small marked blocks (ble.sh must load first and attach last)
RC=$HOME/.bashrc; [ $DRY = 1 ] || touch "$RC"
BLE_LINE='[[ -r ~/.terminal-kit/ble-early.sh ]] && . ~/.terminal-kit/ble-early.sh'
if ! grep -qs 'terminal-kit:ble' "$RC"; then
  if [ $DRY = 1 ]; then echo "  would: back up $RC and add the ble.sh line at its top"; else
  cp "$RC" "$RC.bak.$(date +%s)"
  { printf '%s\n' '# terminal-kit:ble  (load ble.sh first; it is attached at the end of this file)' "$BLE_LINE" ''; cat "$RC"; } > "$RC.new"
  mv "$RC.new" "$RC"
  fi
elif [ "$(grep -A1 '^# terminal-kit:ble' "$RC" | sed -n 2p)" != "$BLE_LINE" ]; then   # older install: upgrade the line
  if [ $DRY = 1 ]; then echo "  would: update the ble.sh line in $RC"; else
  cp "$RC" "$RC.bak.$(date +%s)"
  L=$BLE_LINE awk '/^# terminal-kit:ble/ { print; getline; print ENVIRON["L"]; next } { print }' "$RC" > "$RC.new" && mv "$RC.new" "$RC"
  fi
fi
if ! grep -qs 'terminal-kit:loader' "$RC"; then
  if [ $DRY = 1 ]; then echo "  would: append the loader block to $RC"; else
  cat >> "$RC" <<'RCEOF'

# terminal-kit:loader  (keep this block last)
[[ $- == *i* && -r ~/.terminal-kit/loader.sh ]] && . ~/.terminal-kit/loader.sh
RCEOF
  fi
fi

# nvm: comment out the eager nvm lines so bashrc.d/70-nvm.sh can load it lazily (or restore them if
# you switched that module off). Lines are tagged, so --uninstall can put them back exactly.
NVM_RE='^[[:space:]]*[^#[:space:]].*(\.|source)[[:space:]].*(nvm\.sh|/bash_completion)'
# shellcheck source=/dev/null  # the user's config.sh, read in a subshell only to see TK_DISABLE
nvm_off=0; [ -r "$CONF" ] && (. "$CONF" >/dev/null 2>&1; [[ " ${TK_DISABLE[*]-} " == *" nvm "* ]]) && nvm_off=1
if [ -f "$RC" ] && [ $nvm_off = 0 ] && grep -Eq "$NVM_RE" "$RC" && grep -Eq "$NVM_RE" <(grep -i nvm "$RC"); then
  if [ $DRY = 1 ]; then echo "  would: comment out the nvm lines in $RC (nvm then loads on first use)"; else
  cp "$RC" "$RC.bak.$(date +%s)"
  RE=$NVM_RE awk 'tolower($0) ~ /nvm/ && $0 ~ ENVIRON["RE"] { print "# terminal-kit:nvm-off " $0; next } { print }' "$RC" > "$RC.new" && mv "$RC.new" "$RC"
  say "nvm now loads on first use (its lines in ~/.bashrc are commented out, tagged terminal-kit:nvm-off)"
  fi
elif [ $nvm_off = 1 ] && grep -q '^# terminal-kit:nvm-off ' "$RC" 2>/dev/null; then
  if [ $DRY = 1 ]; then echo "  would: restore the nvm lines in $RC"; else
  sed -i 's/^# terminal-kit:nvm-off //' "$RC"; say "restored your nvm lines in ~/.bashrc"
  fi
fi

next_steps() {
  local n=1 miss=() c
  printf '\n\033[1;32m✔ Installed.\033[0m What to do next:\n\n'
  printf '  %d. Reload your shell:      exec bash\n' $n; n=$((n+1))
  if [ -d /mnt/c/Windows/Fonts ]; then   # WSL: can we see a Nerd Font on the Windows side?
    if compgen -G "/mnt/c/Windows/Fonts/*Nerd*" >/dev/null || compgen -G "/mnt/c/Users/*/AppData/Local/Microsoft/Windows/Fonts/*Nerd*" >/dev/null; then
      printf '  %d. Nerd Font found. In Windows Terminal → Settings → your Ubuntu profile → Appearance,\n     set Font face to your "... Nerd Font Mono" (otherwise icons show as boxes).\n' $n
    else
      printf '  %d. Install a Nerd Font on Windows (nerdfonts.com → JetBrainsMono), then set it in\n     Windows Terminal → Settings → your Ubuntu profile → Appearance → Font face.\n' $n
    fi; n=$((n+1))
  else
    printf '  %d. Set a Nerd Font in your terminal emulator (nerdfonts.com), or icons show as boxes.\n' $n; n=$((n+1))
  fi
  if [ -z "$(git config --global user.name 2>/dev/null)" ] || [ -z "$(git config --global user.email 2>/dev/null)" ]; then
    printf '  %d. Tell git who you are (needed for commits):\n       git config --global user.name  "Your Name"\n       git config --global user.email "you@example.com"\n' $n; n=$((n+1))
  fi
  printf '  %d. Your settings (turn modules off, set your name): ~/.config/terminal-kit/config.sh\n' $n; n=$((n+1))
  printf '  %d. Try it:  menu   (every command in one list)   ·   proj   ·   git lg   ·   Ctrl-R\n' $n
  command -v claude >/dev/null && printf '     ? how do I undo my last git commit      (asks Claude Code)\n'
  for c in starship fzf zoxide eza tmux lazygit mc micro btop; do command -v "$c" >/dev/null || [ -x "$BIN/$c" ] || miss+=("$c"); done
  { command -v fdfind || command -v fd; } >/dev/null || miss+=(fd)
  { command -v batcat || command -v bat; } >/dev/null || miss+=(bat)
  [ ${#miss[@]} -eq 0 ] || printf '\n  Not installed (skipped or unavailable): %s\n  The kit still works; those shortcuts just stay inactive until you install them.\n' "${miss[*]}"
  printf '\n'
}
if [ $DRY = 1 ]; then say "dry run: nothing was changed"; else next_steps; fi
