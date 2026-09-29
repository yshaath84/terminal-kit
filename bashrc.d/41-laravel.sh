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
