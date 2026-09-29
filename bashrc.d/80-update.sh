# kit-update: get the latest terminal-kit and apply it (new modules, pinned tools, config links)
kit-update() {
  local k=~/.terminal-kit
  if [ -n "$(git -C "$k" status --porcelain)" ]; then
    echo "kit-update stopped: files inside $k were changed:" >&2
    git -C "$k" status --short >&2
    echo "Put your changes in ~/.config/terminal-kit/config.sh (yours, never overwritten), then undo them here:" >&2
    echo "  git -C $k checkout -- . && git -C $k clean -fd && kit-update" >&2
    return 1
  fi
  git -C "$k" pull --ff-only -q && bash "$k/install.sh" --no-apt && exec bash
}
