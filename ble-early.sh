# Sourced from the TOP of ~/.bashrc: ble.sh must load before everything else (it is attached at the end).
# TK_DISABLE=(ble) in config.sh turns it off: shells start in ~0.1 s instead of ~1.5 s, but you lose the
# live completion menu, grey suggestions, the collapsing prompt and Windows toasts. Tab and fzf still work.
[[ $- == *i* && -r ~/.local/share/blesh/ble.sh ]] || return 0
# config.sh is only sourced later (by loader.sh), so read the switch without running it.
# ponytail: TK_DISABLE must be on one line to be seen here; source config.sh early if that ever bites.
grep -Eqs '^[[:space:]]*TK_DISABLE=.*[(" ]ble[) "]' ~/.config/terminal-kit/config.sh && return 0
# shellcheck source=/dev/null  # third-party, installed by install.sh
source ~/.local/share/blesh/ble.sh --noattach
