# Security

terminal-kit changes your shell start-up files and downloads tools (starship, delta, ble.sh),
so a security bug here can affect every shell you open. Please report problems privately.

## Reporting a vulnerability

Use **[Report a vulnerability](https://github.com/yshaath84/terminal-kit/security/advisories/new)**
(the Security tab → *Report a vulnerability*). Only the maintainer sees it.
Please don't open a public issue for security problems.

Include what you ran, what happened, and the output of `~/.terminal-kit/install.sh --dry-run` if relevant.

## What the installer trusts

- **apt** packages from your Ubuntu mirrors.
- **starship**: its official install script, `curl -fsSL https://starship.rs/install.sh | sh`.
- **delta**: the latest release binary from github.com/dandavison/delta.
- **ble.sh**: a pinned commit (`BLE_REF` in `install.sh`) built from github.com/akinomyoga/ble.sh.

Only the `main` branch is supported; `kit-update` always installs its latest commit.
