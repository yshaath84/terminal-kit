# terminal-kit

A friendly, GUI-like dev terminal for **WSL / Ubuntu** (works on plain Ubuntu/Debian too).
Two-line prompt, live completion menu, pretty git, one-word commands for everyday work.
Tokyo Night colors. Made for people who don't live in the terminal yet.

> بالعربي: تخصيص جاهز للتيرمنال (برومبت مرتب، إكمال تلقائي أثناء الكتابة، Git أنيق، وأوامر بسيطة). ثبّته بأمر واحد.

## Install

```bash
git clone <this-repo-url> ~/terminal-kit
cd ~/terminal-kit && ./install.sh
exec bash
```

- See exactly what would change first: `./install.sh --dry-run` (prints every change, writes nothing).
- Asks for your `sudo` password once (to `apt install` the tools). Use `--no-apt` to skip apt, `--no-download` to skip starship/delta/ble.sh.
- Safe to run again. Your existing files are backed up as `*.bak.<time>`, never deleted.
- Your git **name/email are never touched**. Set them yourself: `git config --global user.name "..."` and `user.email`.

## Set the font (needed for icons)

Install a Nerd Font on **Windows** (e.g. *JetBrainsMono Nerd Font* from nerdfonts.com), then in
Windows Terminal → Settings → your Ubuntu profile → Appearance → Font face: `JetBrainsMono Nerd Font Mono`.
Without it you'll see empty boxes instead of icons.

## What you get

| Type | What it does |
|---|---|
| `menu` | Pick any command below from a list (asks for arguments when needed) |
| `proj` | Jump to any git repo under `~` (fuzzy search) |
| `cd name` | If the folder isn't here, jumps to the best match you visited before |
| `dev` | Start this project's dev server (Laravel or Node) |
| `work` | tmux session: shell + dev server + spare shell, mouse enabled |
| `files` · `git-ui` · `edit f` · `monitor` | File manager (mc) · Git UI (lazygit) · editor (micro) · system monitor (btop) |
| `newlaravel app` · `newnode app` | New project in `~/code`, with git |
| `art` · `migrate` · `tinker` · `logs` | Laravel shortcuts |
| `killport 8000` · `gclean` · `mkcd d` · `cls` | Free a port · delete merged branches · mkdir+cd · clear |
| `? question` · `explain` · `ai` | Ask [Claude Code](https://claude.com/claude-code) (only if installed) |
| `Ctrl-R` · `Ctrl-T` · `Alt-C` | fzf: search history · pick a file · jump to a folder |
| `git lg` `st` `br` `fresh` `undo` … | Nicer git aliases (`git aliases` lists them) |

Also: a Windows toast when a command takes over 30 s (WSL only), `git diff` via [delta](https://github.com/dandavison/delta),
and the prompt shows PHP/Node versions once, when you enter a repo.

## Customize

Everything is plain files, symlinked from this folder, so `git pull` updates you:

- `bashrc.d/*.sh` – shell functions and aliases, loaded in name order
- `config/starship.toml` – the prompt (shorten your host name there)
- `config/blerc` – completion menu look · `config/tmux.conf` – tmux
- `config/gitconfig`, `config/gitconfig-delta` – git look and aliases

Put your own `*.sh` files in `~/.bashrc.d/` and they load too.

## Tests

```bash
bash tests/test-install.sh
```

Builds a throwaway home with an existing `.bashrc`, tmux/starship config and git identity, installs twice, and checks that nothing of theirs was lost, everything was backed up, and `--dry-run` wrote nothing. Runs in CI on every push.

## Uninstall

Delete the two blocks marked `terminal-kit:` in `~/.bashrc` (or restore a `~/.bashrc.bak.*`), remove the symlinks in `~/.bashrc.d`, and delete the `include.path` lines from `~/.gitconfig`.
