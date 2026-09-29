# Contributing

Thanks for helping. Issues and pull requests are welcome.

## Set up

Keep a development clone apart from the installed one: `kit-update` refuses to run if files inside
`~/.terminal-kit` were edited.

```bash
git clone https://github.com/yshaath84/terminal-kit ~/code/terminal-kit
cd ~/code/terminal-kit
bash tests/test-install.sh        # must end with "0 failed"
shellcheck -s bash -S warning install.sh loader.sh ble-early.sh bashrc.d/*.sh tests/*.sh
```

The tests build throwaway homes, need no network or sudo, and take under a minute. CI runs both steps on every push.

## Ground rules

These keep the kit safe to install on someone else's machine:

1. **Never touch the user's git identity** (`user.name`, `user.email`).
2. **Everything is reversible.**
   - Back up any file before replacing it (`*.bak.<time>`).
   - Tag every line added to `~/.bashrc` with `terminal-kit:`.
   - Make sure `install.sh --uninstall` undoes it.
3. **Support `--dry-run`.** Wrap every write in `run ...` so it can be previewed.
4. **Idempotent.** Running `install.sh` twice must change nothing the second time.
5. **Start-up time matters.**
   - Don't add work that runs on every new shell without measuring it.
   - Don't add checks that touch `/mnt/c` while the shell starts; each one is slow.
6. **A new install behaviour needs a test** in `tests/test-install.sh`.

## Adding a module

Add `bashrc.d/NN-name.sh`. The number sets the load order and `name` is its switch: users turn it
off with `TK_DISABLE=(name)`, so document it in `config/config.template.sh` and the README.
Commands a module defines show up in `menu` if you add them to `_menu_items` in `40-projects.sh`.

## Pull requests

- Branch from `main`; `main` only accepts changes through pull requests with a passing CI.
- One logical change per commit, with a message that says why.
- Say how you tested it, especially on a real WSL terminal for anything visual.
