# projects: newlaravel, newnode, Laravel shortcuts, menu
# newlaravel myapp: create a Laravel project in ~/code, git init, cd into it
newlaravel() {
  [ -n "$1" ] || { echo "usage: newlaravel <name>" >&2; return 1; }
  [ -e ~/code/"$1" ] && { echo "~/code/$1 already exists" >&2; return 1; }
  composer create-project laravel/laravel ~/code/"$1" && cd ~/code/"$1" && git init -q && git add -A && git commit -qm "Initial Laravel skeleton" && echo "✔ ready: run 'dev'"
}

# newnode myapp: create a Node project in ~/code with a watch-mode 'dev' script, git init, cd into it
newnode() {
  [ -n "$1" ] || { echo "usage: newnode <name>" >&2; return 1; }
  [ -e ~/code/"$1" ] && { echo "~/code/$1 already exists" >&2; return 1; }
  mkdir -p ~/code/"$1" && cd ~/code/"$1" || return 1
  npm init -y >/dev/null && npm pkg set scripts.dev="node --watch index.js" main=index.js >/dev/null
  echo 'console.log("hello from '"$1"'");' > index.js
  printf 'node_modules\n.env\n' > .gitignore
  git init -q && git add -A && git commit -qm "Initial Node project" && echo "✔ ready: run 'dev'"
}

# --- Laravel shortcuts (run inside a Laravel project) ---
art()     { php artisan "$@"; }
migrate() { php artisan migrate "$@"; }
tinker()  { php artisan tinker; }
logs()    { tail -F storage/logs/laravel.log; }

# menu: pick a custom command from a list (asks for an argument when one is needed)
menu() {
  local pick arg
  pick=$(printf '%s\n' \
    'files|Open the file manager' \
    'proj|Jump to a git project' \
    'git-ui|Open the Git interface' \
    'edit|Edit a file (asks for the file name)' \
    'monitor|Watch CPU, memory, processes' \
    'dev|Start the dev server of this project' \
    'newlaravel|Create a Laravel project (asks for a name)' \
    'newnode|Create a Node project (asks for a name)' \
    'art|Run php artisan (asks for the command)' \
    'migrate|Run Laravel migrations' \
    'tinker|Open Laravel tinker' \
    'logs|Follow the Laravel log' \
    'killport|Free a port (asks for the number)' \
    'gclean|Delete merged git branches' \
    'ask|Ask the AI assistant (asks for the question)' \
    'explain|Explain your last command' \
    | column -t -s'|' | fzf --prompt='menu > ' --height 60% | awk '{print $1}') || return
  case $pick in
    edit|newlaravel|newnode|art|killport|ask) read -rp "$pick > " arg ;;
  esac
  eval "$pick ${arg:+$(printf '%q' "$arg")}"
}
# --- end Laravel/menu ---
