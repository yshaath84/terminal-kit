# laravel: Laravel shortcuts and project creation. Turn off with TK_DISABLE=(laravel)
# newlaravel myapp: create a Laravel project in ~/code, git init, cd into it
newlaravel() {
  [ -n "$1" ] || { echo "usage: newlaravel <name>" >&2; return 1; }
  [ -e ~/code/"$1" ] && { echo "$HOME/code/$1 already exists" >&2; return 1; }
  composer create-project laravel/laravel ~/code/"$1" && cd ~/code/"$1" && git init -q && git add -A && git commit -qm "Initial Laravel skeleton" && echo "✔ ready: run 'dev'"
}

# --- Laravel shortcuts (run inside a Laravel project) ---
art()     { php artisan "$@"; }
migrate() { php artisan migrate "$@"; }
tinker()  { php artisan tinker; }
logs()    { tail -F storage/logs/laravel.log; }

# Tab completion for `php artisan …` and `art …`, asked from Laravel itself (`artisan _complete`, the
# protocol of Laravel's own `artisan completion bash`), so it knows your project's commands and options.
# Laravel's script only completes a command named `artisan`; this one hooks `php` and `art`.
# Anything else after `php` (php script.php) falls back to file names.
_tk_artisan() {
  declare -F _get_comp_words_by_ref >/dev/null && [ -f artisan ] || return 1
  local cur words cword start=0 w out IFS=$'\n'
  _get_comp_words_by_ref -n : cur words cword          # keep make:model as one word
  if [[ ${words[0]} == php ]]; then
    [[ ${words[1]-} == artisan ]] && ((cword > 1)) || return 1
    start=1
  fi
  local args=()
  for w in artisan "${words[@]:start+1}"; do [ -n "$w" ] && args+=("-i$w"); done
  out=$(SHELL_VERBOSITY=0 php artisan _complete --no-interaction -sbash -c$((cword - start)) -a1 "${args[@]}" 2>/dev/null) || return 1
  mapfile -t COMPREPLY < <(compgen -W "$out" -- "$cur")
  __ltrim_colon_completions "$cur"
}
complete -o default -F _tk_artisan php art
