## What and why

## How I tested it
- [ ] `bash tests/test-install.sh` ends with 0 failed
- [ ] shellcheck passes (CI runs it)
- [ ] Tried it in a real WSL terminal (for anything visual or interactive)

## Checklist
- [ ] Still reversible: `install.sh --uninstall` undoes it, and `--dry-run` previews it
- [ ] No new work on every shell start without measuring it
- [ ] Docs updated (README / config template) if users see the change
