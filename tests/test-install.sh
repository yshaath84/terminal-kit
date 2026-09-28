#!/usr/bin/env bash
# Proves install.sh never damages what a user already has. Uses a throwaway HOME; no network, no sudo.
set -uo pipefail
KIT=$(cd "$(dirname "$0")/.." && pwd); pass=0; fail=0
ok() { if eval "$2"; then echo "  PASS  $1"; pass=$((pass+1)); else echo "  FAIL  $1"; fail=$((fail+1)); fi; }
inst() { HOME=$H bash "$KIT/install.sh" --no-apt --no-download "$@" >/dev/null 2>&1; }

echo "syntax"
for f in "$KIT"/install.sh "$KIT"/bashrc.d/*.sh; do ok "bash -n ${f#$KIT/}" 'bash -n "$f"'; done

echo "dry run writes nothing"
H=$(mktemp -d); inst --dry-run
ok "empty HOME after --dry-run" '[ -z "$(ls -A "$H")" ]'; rm -rf "$H"

echo "a user with an existing setup"
H=$(mktemp -d); mkdir -p "$H/.config"
printf '# mine\nalias mine=1\n' > "$H/.bashrc"
echo 'set -g prefix C-a' > "$H/.tmux.conf"
echo 'add_newline = true' > "$H/.config/starship.toml"
HOME=$H git config --global user.name  "Friend"
HOME=$H git config --global user.email "friend@example.com"
inst; inst   # twice: must be idempotent
ok "their alias survives"             'grep -q "^alias mine=1" "$H/.bashrc"'
ok "ble.sh line added once"           '[ "$(grep -c terminal-kit:ble "$H/.bashrc")" = 1 ]'
ok "loader added once"                '[ "$(grep -c terminal-kit:loader "$H/.bashrc")" = 1 ]'
ok ".bashrc backed up"                'ls "$H"/.bashrc.bak.* >/dev/null 2>&1'
ok "their tmux.conf backed up intact" 'grep -qx "set -g prefix C-a" "$H"/.tmux.conf.bak.*'
ok "their starship.toml backed up"    'grep -qx "add_newline = true" "$H"/.config/starship.toml.bak.*'
ok "our tmux.conf is linked"          '[ "$(readlink "$H/.tmux.conf")" = "$KIT/config/tmux.conf" ]'
ok "git name kept"                    '[ "$(HOME=$H git config --global user.name)" = Friend ]'
ok "git email kept"                   '[ "$(HOME=$H git config --global user.email)" = friend@example.com ]'
ok "git include added once"           '[ "$(HOME=$H git config --global --get-all include.path | grep -c config/gitconfig$)" = 1 ]'
ok "our git aliases work"             '[ -n "$(HOME=$H git config --get alias.lg)" ]'
ok "no personal strings in the kit"   '! grep -rIiE "oracle|@gmail|@outlook|youssef" "$KIT" --exclude-dir=.git --exclude-dir=tests'
rm -rf "$H"

echo "WSL: Windows folders leave PATH, chosen tools stay usable"
H=$(mktemp -d); printf '#!/bin/sh\necho hello-from-win "$@"\n' > "$H/fake.exe"; chmod +x "$H/fake.exe"
out=$(WSL_DISTRO_NAME=x PATH="/usr/bin:/mnt/c/Windows:/bin:/mnt/c/Program Files/x y" bash -c 'WSL_WIN_TOOLS=("mytool=$1"); . "$0"; echo "$PATH"; mytool 1' "$KIT/bashrc.d/05-wsl-path.sh" "$H/fake.exe" 2>&1)
ok "no /mnt entries left on PATH"     '[[ $(head -1 <<<"$out") == /usr/bin:/bin ]]'
ok "chosen tool still runs"           '[[ $(tail -1 <<<"$out") == "hello-from-win 1" ]]'
out=$(unset WSL_DISTRO_NAME; PATH="/usr/bin:/mnt/c/Windows" bash -c '. "$0"; echo "$PATH"' "$KIT/bashrc.d/05-wsl-path.sh")
ok "outside WSL, PATH is untouched"   '[[ $out == /usr/bin:/mnt/c/Windows ]]'
rm -rf "$H"

echo "the closing message"
H=$(mktemp -d)   # a fresh user with no git identity
out=$(HOME=$H bash "$KIT/install.sh" --no-apt --no-download 2>&1)
ok "prints the next steps"            '[[ $out == *"What to do next"* && $out == *"exec bash"* ]]'
ok "asks for a git identity when missing" '[[ $out == *"Tell git who you are"* ]]'
HOME=$H git config --global user.name X; HOME=$H git config --global user.email x@x
out=$(HOME=$H bash "$KIT/install.sh" --no-apt --no-download 2>&1)
ok "no identity nag once it is set"   '[[ $out != *"Tell git who you are"* ]]'
rm -rf "$H"

echo; echo "$pass passed, $fail failed"; [ "$fail" = 0 ]
