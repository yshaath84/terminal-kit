# copilot: greeting, ? / explain / ai (Claude), goodbye. Loads last so tips only name commands that exist.
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
  _tips=(); for _t in "files|type files to open the file manager" "proj|type proj to jump to any project" \
    "git-ui|type git-ui for the Git interface" "ask|type ? then your question and I'll answer" \
    "explain|type explain to explain your last command" "fzf|press Ctrl-R to search old commands" \
    "monitor|type monitor to watch the system" "menu|type menu to see every command in one list"; do
    type -t "${_t%%|*}" >/dev/null && _tips+=("${_t#*|}"); done; unset _t
  _S=$HISTCMD
  printf '\n👋 Hi %s — %s\n' "${TK_NAME:-$USER}" "$(basename "$PWD")"
  git rev-parse --is-inside-work-tree &>/dev/null && printf '   🌿 %s\n' "$(git status -sb | head -1)"
  (( ${#_tips[@]} )) && printf '   💡 %s\n' "${_tips[RANDOM % ${#_tips[@]}]}"; echo
  trap 'rm -f /tmp/.repo-seen-$$; printf "\n👋 Bye — you ran %d commands this session\n" $((n=HISTCMD-_S-1, n<0?0:n))' EXIT
fi
# --- end copilot ---
