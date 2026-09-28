# copilot: greeting, ? / explain / ai (Claude), goodbye
# --- copilot ---
_AI_SYS='You are a terminal assistant for a beginner on WSL/Ubuntu. Answer in English, briefly: give one command in a code block, then a two-line explanation. Warn before any destructive command. Never execute anything.'
if command -v claude >/dev/null; then
ask() { claude -p --append-system-prompt "$_AI_SYS" "$*" </dev/null; }
alias '?'=ask
explain() { ask "Explain this command and what could make it fail: $(fc -ln -1 | sed 's/^[[:space:]]*//')"; }
ai() { claude --append-system-prompt "$_AI_SYS"; }
else
  ask() { echo "'?' needs Claude Code: https://claude.com/claude-code" >&2; return 1; }
  explain() { ask; }; ai() { ask; }
fi
if [[ $- == *i* && -z $TMUX ]]; then
  _tips=("type files to open the file manager" "type proj to jump to any project" "type git-ui for the Git interface" "type ? then your question and I'll answer" "type explain to explain your last command" "press Ctrl-R to search old commands" "type monitor to watch the system")
  _S=$HISTCMD
  printf '\n👋 Hi %s — %s\n' "$USER" "$(basename "$PWD")"
  git rev-parse --is-inside-work-tree &>/dev/null && printf '   🌿 %s\n' "$(git status -sb | head -1)"
  printf '   💡 %s\n\n' "${_tips[RANDOM % ${#_tips[@]}]}"
  trap 'rm -f /tmp/.repo-seen-$$; printf "\n👋 Bye — you ran %d commands this session\n" $((n=HISTCMD-_S-1, n<0?0:n))' EXIT
fi
# --- end copilot ---
