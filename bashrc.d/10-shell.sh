# shell basics: history, options, prompt (starship), zoxide, fzf, ls/bat/fd aliases
# --- dev UX ---
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) PATH="$HOME/.local/bin:$PATH" ;; esac
export _SHELL_PID=$$   # used by starship to show php/node once per repo entry
# Ubuntu/Debian ship these as fdfind/batcat; other distros use fd/bat
_fd=$(command -v fdfind || command -v fd || true); _bat=$(command -v batcat || command -v bat || true)
HISTSIZE=50000; HISTFILESIZE=100000; HISTCONTROL=ignoreboth:erasedups
shopt -s histappend cmdhist autocd cdspell globstar
bind 'set completion-ignore-case on' 'set show-all-if-ambiguous on'
bind '"\e[A": history-search-backward' '"\e[B": history-search-forward'
command -v starship >/dev/null && eval "$(starship init bash)"
command -v zoxide   >/dev/null && eval "$(zoxide init bash)"
export FZF_DEFAULT_COMMAND="${_fd:-fd} --type f --hidden --exclude .git --exclude node_modules"
export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
export FZF_ALT_C_COMMAND="${_fd:-fd} --type d --hidden --exclude .git --exclude node_modules"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --color=bg+:#283457,fg:#c0caf5,hl:#7aa2f7,fg+:#c0caf5,hl+:#7dcfff,info:#e0af68,prompt:#bb9af7,pointer:#f7768e,marker:#9ece6a'
export FZF_CTRL_T_OPTS="--preview '${_bat:-cat} --color=always --style=numbers --line-range=:200 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {}'"
command -v fzf      >/dev/null && eval "$(fzf --bash 2>/dev/null)"
command -v eza      >/dev/null && alias ls='eza --icons --group-directories-first' ll='eza -lah --git --icons'
[ -n "$_bat" ] && alias bat="$_bat"
[ -n "$_fd" ] && alias fd="$_fd"
alias gs='git status -sb' gl='git log --oneline --graph -20' ..='cd ..'
# --- end dev UX ---
