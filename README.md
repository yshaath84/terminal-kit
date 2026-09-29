# terminal-kit

A friendly, GUI-like dev terminal for **WSL / Ubuntu**.
Two-line prompt, live completion menu, pretty git, one-word commands for everyday work.
Tokyo Night colors. Made for people who don't live in the terminal yet.

> بالعربي: تخصيص جاهز للتيرمنال (برومبت مرتب، إكمال تلقائي أثناء الكتابة، Git أنيق، وأوامر بسيطة). ثبّته بأمر واحد، وحدّثه بـ `kit-update`.

## Install

```bash
git clone https://github.com/yshaath84/terminal-kit ~/.terminal-kit
~/.terminal-kit/install.sh
exec bash
```

- It must live in `~/.terminal-kit`; the installer refuses to run from anywhere else, so it can't break by being moved.
- See every change first: `~/.terminal-kit/install.sh --dry-run` (prints, writes nothing).
- Asks for your `sudo` password once (to `apt install` the tools). `--no-apt` skips apt, `--no-download` skips starship/delta/ble.sh.
- Safe to run again. Files it replaces are backed up as `*.bak.<time>`, never deleted.
- Your git **name/email are never touched**.

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
| `? question` · `explain` · `ai` | Ask [Claude Code](https://claude.com/claude-code) (only if installed; uses your credits) |
| `Ctrl-R` · `Ctrl-T` · `Alt-C` | fzf: search history · pick a file · jump to a folder |
| `git lg` `st` `br` `fresh` `undo` … | Nicer git aliases (`git aliases` lists them) |
| `kit-update` | Get the latest terminal-kit |

Also:
- `git diff` through [delta](https://github.com/dandavison/delta).
- The prompt shows PHP/Node versions once, when you enter a repo, and the host name only over SSH.
- A Windows toast when a command takes over 30 s.
- **Faster shells:** nvm loads the first time you type `nvm` (saves ~2 s per new shell), and Windows folders are kept off `PATH` so Tab completion doesn't hang (106 s → 0.1 s measured). VS Code (`code .`), `explorer.exe`, `clip.exe`, `cmd.exe` and `powershell.exe` keep working.

## Your settings

`~/.config/terminal-kit/config.sh` is yours. It is created once from a commented template, loaded before
the kit in every shell, and never changed by the installer or `kit-update`. In it you can:

```bash
TK_DISABLE=(laravel copilot)   # switch modules off: laravel copilot smartcd notify winpath nvm ble ... (one line)
TK_NAME="Sam"                  # name in the greeting
NOTIFY_AFTER=60                # seconds before a Windows toast
WSL_WIN_TOOLS=("mytool=/mnt/c/tools/mytool.exe")   # more Windows programs to keep runnable
alias ll='ls -la'              # anything else you want in every shell
```

Module names are the files in `bashrc.d/` without the number (`41-laravel.sh` → `laravel`), plus `ble`.

**Faster start, less magic:** `TK_DISABLE=(ble)` switches off ble.sh. New shells are then ready in about 0.2 s instead of 1.5 s. Tab completion, fzf and every command still work, but these stop:
- the live menu while you type
- the grey suggestions
- the collapsing old prompts
- Windows toasts

To change the kit itself, don't edit files in `~/.terminal-kit`: `kit-update` stops if you do. Put it in `config.sh`, or send a pull request.

## Update

```bash
kit-update
```

Pulls the latest version, applies it (new modules, tool versions, config links) and reloads your shell.

## Uninstall

```bash
~/.terminal-kit/install.sh --uninstall
```

- Removes the config links and puts your backed-up files back.
- Removes the terminal-kit lines from `~/.bashrc` and restores your nvm lines.
- Removes the git include entries.
- Keeps `config.sh`, the downloaded tools and `~/.terminal-kit` itself. Delete that folder when you like.
- Add `--dry-run` to see what it would do first.

## Tests

```bash
bash ~/.terminal-kit/tests/test-install.sh
```

The script builds throwaway homes with an existing `.bashrc`, tmux/starship config, nvm and git identity, then runs install, update and uninstall. It checks that nothing of theirs is lost and that everything is backed up and comes back unchanged. CI runs it on every push.

## Contributing and security

See [CONTRIBUTING.md](CONTRIBUTING.md). Report security problems privately, see [SECURITY.md](SECURITY.md).

## License

MIT, see [LICENSE](LICENSE). The CLI tools are the work of their authors; terminal-kit only wires them together.
