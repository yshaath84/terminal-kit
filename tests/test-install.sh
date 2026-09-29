#!/usr/bin/env bash
# shellcheck disable=SC2034  # variables like $out/$err are read inside the strings that ok() evals
# Proves install.sh never damages what a user already has. Uses a throwaway HOME; no network, no sudo.
set -uo pipefail
SRC=$(cd "$(dirname "$0")/.." && pwd); pass=0; fail=0
ok() { if eval "$2"; then echo "  PASS  $1"; pass=$((pass+1)); else echo "  FAIL  $1"; fail=$((fail+1)); fi; }
# newhome: a throwaway HOME with the kit cloned where it must live (~/.terminal-kit)
newhome() { H=$(mktemp -d); cp -r "$SRC" "$H/.terminal-kit"; KIT=$H/.terminal-kit; }
inst() { HOME=$H bash "$KIT/install.sh" --no-apt --no-download "$@" >/dev/null 2>&1; }

echo "syntax"
for f in "$SRC"/install.sh "$SRC"/loader.sh "$SRC"/ble-early.sh "$SRC"/bashrc.d/*.sh; do ok "bash -n ${f#$SRC/}" 'bash -n "$f"'; done

echo "location"
H=$(mktemp -d)
ok "refuses to install outside ~/.terminal-kit" '! HOME=$H bash "$SRC/install.sh" --no-apt --no-download >/dev/null 2>&1'
ok "writes nothing when it refuses"   '[ -z "$(ls -A "$H")" ]'
rm -rf "$H"

echo "dry run writes nothing"
newhome; inst --dry-run
ok "HOME untouched after --dry-run"   '[ "$(ls -A "$H")" = .terminal-kit ]'; rm -rf "$H"

echo "a user with an existing setup"
newhome; mkdir -p "$H/.config"
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
ok "loader sources the kit"          'grep -q "\. ~/.terminal-kit/loader.sh" "$H/.bashrc"'
out=$(cd "$H" && HOME=$H bash -ic 'type -t menu; type -t proj' 2>/dev/null)
ok "interactive shell gets the kit"   '[ "$(grep -cx function <<<"$out")" = 2 ]'
ok "git include added once"           '[ "$(HOME=$H git config --global --get-all include.path | grep -c config/gitconfig$)" = 1 ]'
ok "our git aliases work"             '[ -n "$(HOME=$H git config --get alias.lg)" ]'
ok "no personal strings in the kit"   '! grep -rIiE "oracle|@gmail|@outlook|youssef" "$SRC" --exclude-dir=.git --exclude-dir=tests'
rm -rf "$H"

echo "your settings"
newhome; inst
ok "config.sh created from template"  'cmp -s "$KIT/config/config.template.sh" "$H/.config/terminal-kit/config.sh"'
echo 'TK_DISABLE=(laravel smartcd); TK_NAME=Sam; alias mine=1' >> "$H/.config/terminal-kit/config.sh"
inst
ok "config.sh never overwritten"      'grep -q "TK_NAME=Sam" "$H/.config/terminal-kit/config.sh"'
out=$(cd "$H" && HOME=$H bash -ic 'echo "@art=$(type -t art) cd=$(type -t cd) newnode=$(type -t newnode) mine=$(type -t mine)"; _menu_items | cut -d"|" -f1 | tr "\n" " "' 2>/dev/null)
ok "disabled modules don't load"      '[[ $out == *"@art= cd=builtin newnode=function mine=alias"* ]]'
ok "menu hides disabled commands"     '[[ $out == *"newnode"* && $out != *" art "* && $out != *"newlaravel"* ]]'
ok "greeting uses TK_NAME"            '[[ $out == *"Hi Sam"* ]]'
rm -rf "$H"

echo "nvm loads on first use"
newhome; mkdir -p "$H/.nvm/alias" "$H/.nvm/versions/node/v20.1.0/bin" "$H/.nvm/versions/node/v22.0.0/bin"
echo 'nvm() { echo real-nvm "$@"; }' > "$H/.nvm/nvm.sh"; echo v20.1.0 > "$H/.nvm/alias/default"
cat > "$H/.bashrc" <<'RC'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# my notes about nvm.sh stay as they are
RC
err=$(HOME=$H bash "$KIT/install.sh" --no-apt --no-download 2>&1 >/dev/null); inst
ok "install prints no warnings"       '[ -z "$err" ]'
ok "both nvm lines commented, once"   '[ "$(grep -c "^# terminal-kit:nvm-off \[ -s" "$H/.bashrc")" = 2 ]'
ok "other lines untouched"            'grep -qx "export NVM_DIR=\"\$HOME/.nvm\"" "$H/.bashrc" && grep -qx "# my notes about nvm.sh stay as they are" "$H/.bashrc"'
out=$(cd "$H" && HOME=$H bash -ic 'echo "@path=${PATH%%:*}"; nvm ls' 2>/dev/null)
ok "default node is first on PATH"    '[[ $out == *"@path=$H/.nvm/versions/node/v20.1.0/bin"* ]]'
ok "nvm itself loads when first used" '[[ $out == *"real-nvm ls"* ]]'
echo 'TK_DISABLE=(nvm)' >> "$H/.config/terminal-kit/config.sh"; inst
ok "disabling nvm restores the lines" '! grep -q terminal-kit:nvm-off "$H/.bashrc" && grep -qx "\[ -s \"\$NVM_DIR/nvm.sh\" \] && \\\\. \"\$NVM_DIR/nvm.sh\"  # This loads nvm" "$H/.bashrc"'
rm -rf "$H"

echo "kit-update"
G=(-c user.name=t -c user.email=t@t)
newhome; git -C "$KIT" add -A; git "${G[@]}" -C "$KIT" commit -qm wip --allow-empty; git -C "$KIT" checkout -q -B main
git clone -q --bare "$KIT" "$H/up.git"; git -C "$KIT" remote remove origin 2>/dev/null
git -C "$KIT" remote add origin "$H/up.git"; git -C "$KIT" fetch -q origin; git -C "$KIT" branch -q -u origin/main
git clone -q "$H/up.git" "$H/w"; echo 'hello() { echo hi-from-new-module; }' > "$H/w/bashrc.d/85-hello.sh"
git -C "$H/w" add -A; git "${G[@]}" -C "$H/w" commit -qm hello; git -C "$H/w" push -q
inst
echo '# my edit' >> "$KIT/bashrc.d/10-shell.sh"
out=$(HOME=$H bash -c '. ~/.terminal-kit/bashrc.d/80-update.sh; kit-update; echo "rc=$?"' </dev/null 2>&1)
ok "refuses when kit files were edited" '[[ $out == *"kit-update stopped"*"10-shell.sh"*"rc=1" ]]'
ok "and pulls nothing"                '[ ! -e "$KIT/bashrc.d/85-hello.sh" ]'
git -C "$KIT" checkout -q -- .
HOME=$H bash -c '. ~/.terminal-kit/bashrc.d/80-update.sh; kit-update' </dev/null >/dev/null 2>&1
ok "pulls the new module"             '[ -e "$KIT/bashrc.d/85-hello.sh" ]'
out=$(cd "$H" && HOME=$H bash -ic hello 2>/dev/null)
ok "new module is live, no re-link"   '[[ $out == *hi-from-new-module* ]]'
rm -rf "$H"

echo "uninstall puts everything back"
newhome; mkdir -p "$H/.config" "$H/.nvm"; echo : > "$H/.nvm/nvm.sh"
printf '# mine\nalias mine=1\nexport NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && \\. "$NVM_DIR/nvm.sh"\n' > "$H/.bashrc"
echo 'set -g prefix C-a' > "$H/.tmux.conf"; echo 'add_newline = true' > "$H/.config/starship.toml"
cp "$H/.bashrc" "$H/orig.bashrc"; HOME=$H git config --global user.name Friend
inst; inst
before=$(ls -A "$H"; ls -A "$H/.config")
inst --uninstall --dry-run
ok "--uninstall --dry-run changes nothing" '[ "$(ls -A "$H"; ls -A "$H/.config")" = "$before" ] && grep -q terminal-kit:loader "$H/.bashrc"'
inst --uninstall
ok ".bashrc back to the original"     'diff <(grep -v "^$" "$H/orig.bashrc") <(grep -v "^$" "$H/.bashrc") >/dev/null'
ok "their tmux.conf restored"         '[ ! -L "$H/.tmux.conf" ] && grep -qx "set -g prefix C-a" "$H/.tmux.conf"'
ok "their starship.toml restored"     '[ ! -L "$H/.config/starship.toml" ] && grep -qx "add_newline = true" "$H/.config/starship.toml"'
ok "our blerc link removed"           '[ ! -e "$H/.blerc" ]'
ok "git includes removed"             '! HOME=$H git config --global --get-all include.path'
ok "git identity kept"                '[ "$(HOME=$H git config --global user.name)" = Friend ]'
ok "their config.sh kept"             '[ -f "$H/.config/terminal-kit/config.sh" ]'
out=$(cd "$H" && HOME=$H bash -ic 'type -t menu; alias mine' 2>/dev/null)
ok "shell works without the kit"      '[[ $out != *function* && $out == *"alias mine="* ]]'
inst
ok "reinstall after uninstall works"  '[ "$(grep -c terminal-kit:loader "$H/.bashrc")" = 1 ]'
rm -rf "$H"

echo "ble.sh can be switched off"
newhome; mkdir -p "$H/.local/share/blesh"; echo 'BLE_FAKE=loaded' > "$H/.local/share/blesh/ble.sh"
inst
blecheck() { (cd "$H" && HOME=$H bash -ic 'echo "@ble=${BLE_FAKE-} art=$(type -t art)"' 2>/dev/null | grep -a '^@'); }
ok "ble.sh loads by default"          '[[ $(blecheck) == "@ble=loaded art=function" ]]'
echo '# TK_DISABLE=(ble)' >> "$H/.config/terminal-kit/config.sh"
ok "a commented switch does nothing"  '[[ $(blecheck) == "@ble=loaded"* ]]'
echo 'TK_DISABLE=(laravel ble)' >> "$H/.config/terminal-kit/config.sh"
ok "TK_DISABLE=(... ble) skips it"    '[[ $(blecheck) == "@ble= art=" ]]'
rm -rf "$H"
newhome; printf '%s\n' '# terminal-kit:ble  (load ble.sh first; it is attached at the end of this file)' \
  '[[ $- == *i* && -r ~/.local/share/blesh/ble.sh ]] && source ~/.local/share/blesh/ble.sh --noattach' '' '# mine' > "$H/.bashrc"
inst; inst
ok "older ble line upgraded, once"    '[ "$(grep -c terminal-kit:ble "$H/.bashrc")" = 1 ] && grep -q "ble-early.sh" "$H/.bashrc" && ! grep -q "blesh/ble.sh --noattach" "$H/.bashrc" && grep -qx "# mine" "$H/.bashrc"'
rm -rf "$H"

echo "WSL: Windows folders leave PATH, Windows tools stay usable"
H=$(mktemp -d); mkdir -p "$H/Users/bob"; printf '#!/bin/sh\necho hello-from-win "$@"\n' > "$H/Users/bob/tool.exe"; chmod +x "$H/Users/bob/tool.exe"
wp() { WSL_DISTRO_NAME=x PATH="/usr/bin:/mnt/c/Windows:/bin:/mnt/c/Program Files/x y" bash -c "WSL_WIN_TOOLS=(\"mytool=$H/Users/*/tool.exe\" \"gone=$H/nope.exe\"); . $SRC/bashrc.d/05-winpath.sh; $1" 2>&1; }
ok "no /mnt entries left on PATH"     '[[ $(wp "echo \$PATH") == /usr/bin:/bin ]]'
ok "own tool runs, found by glob"     '[[ $(wp "mytool 1 \"a b\"") == "hello-from-win 1 a b" ]]'
ok "VS Code gets a code command"      '[[ $(wp "type -t code") == function ]]'
ok "missing tool says so, exit 127"   '[[ $(wp "gone; echo rc=\$?") == *"not found on Windows"*"rc=127" ]]'
out=$(unset WSL_DISTRO_NAME; PATH="/usr/bin:/mnt/c/Windows" bash -c '. "$0"; echo "$PATH"' "$SRC/bashrc.d/05-winpath.sh")
ok "outside WSL, PATH is untouched"   '[[ $out == /usr/bin:/mnt/c/Windows ]]'
rm -rf "$H"

echo "the closing message"
newhome   # a fresh user with no git identity
out=$(HOME=$H bash "$KIT/install.sh" --no-apt --no-download 2>&1)
ok "prints the next steps"            '[[ $out == *"What to do next"* && $out == *"exec bash"* ]]'
ok "asks for a git identity when missing" '[[ $out == *"Tell git who you are"* ]]'
HOME=$H git config --global user.name X; HOME=$H git config --global user.email x@x
out=$(HOME=$H bash "$KIT/install.sh" --no-apt --no-download 2>&1)
ok "no identity nag once it is set"   '[[ $out != *"Tell git who you are"* ]]'
rm -rf "$H"

echo; echo "$pass passed, $fail failed"; [ "$fail" = 0 ]
