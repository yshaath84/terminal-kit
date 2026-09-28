# small tools: mkcd, proj, dev, killport, gclean, TUI shortcuts, cls, work (tmux)
# --- dev functions ---
mkcd() { mkdir -p "$1" && cd "$1"; }
# proj: fzf-pick a git repo under ~ (depth 3) and cd into it
proj() { local d; d=$(${_fd:-fd} -H -t d '^\.git$' ~ -d 3 -E .nvm -E .cache | sed 's|/\.git/\?$||' | fzf --query="$1" -1) && cd "$d"; }
# dev: start the project's dev server (Laravel composer script, else npm)
dev() {
  if [ -f artisan ] && grep -q '"dev"' composer.json 2>/dev/null; then composer run dev
  elif [ -f artisan ]; then php artisan serve
  elif [ -f package.json ]; then npm run "${1:-dev}"
  else echo "no artisan or package.json here" >&2; return 1; fi
}
# killport 8000: free a port
killport() { local p; p=$(lsof -ti:"$1") && kill $p && echo "killed $p" || echo "nothing on :$1"; }
# gclean: delete local branches already merged into the current one
gclean() { git branch --merged | grep -vE '^\*|main|master|develop' | xargs -r git branch -d; }
# --- end dev functions ---

# --- GUI-like TUI shortcuts ---
command -v mc      >/dev/null && alias files='mc'
command -v lazygit >/dev/null && alias git-ui='lazygit'
command -v btop    >/dev/null && alias monitor='btop'
if command -v micro >/dev/null; then alias edit='micro'; export EDITOR=micro VISUAL=micro; fi
# --- end TUI shortcuts ---

alias cls='clear'

# work: tmux session for this folder — shell (left), dev server (top right), spare shell (bottom right)
work() {
  local s; s=$(basename "$PWD" | tr . _)
  tmux has-session -t "$s" 2>/dev/null || {
    tmux new-session -d -s "$s" -c "$PWD"
    tmux split-window -h -t "$s" -c "$PWD" -l 40%
    tmux split-window -v -t "$s" -c "$PWD"
    { [ -f artisan ] || [ -f package.json ]; } && tmux send-keys -t "$s.2" dev Enter
    tmux select-pane -t "$s.1"
  }
  tmux attach -t "$s"
}
