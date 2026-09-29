# Agent notes for this repo

Personal dotfiles, deployed with GNU Stow from `~/dotfiles` into `$HOME`.
See `README.md` for the human-facing usage.

## Structure

- Each top-level folder is a stow package mirroring `$HOME`: `common` (every machine), `i3-laptop` (laptop, i3/X11) and `sway-desktop` (desktop, sway/Wayland).
- A machine stows `common` plus its own package, e.g. `stow common i3-laptop`.
- Anything shared between the two setups goes in `common`; anything machine-specific goes in that machine's package.
  Never put the same file in two packages, stow would conflict.
- Files at the repo root (this file, `README.md`, `LICENSE`) are not stowed.

## Rules

- Never create symlinks into `$HOME` by hand; change files in a package and run `stow -R <packages>` (preview with `stow -n -v`).
- The repo is **public**: no secrets, tokens, internal company details or machine state.

## Claude Code setups

- Two accounts, each with its own `CLAUDE_CONFIG_DIR`: `~/.claude-work` and `~/.claude-personal`.
- Their tracked configs are `common/.claude-work` and `common/.claude-personal` (`CLAUDE.md` and `skills/`).
  They started as copies and are meant to diverge, so change only the account the user asks about.
- `claude-work` / `claude-personal` aliases and a guard that blocks a bare `claude` live in `common/.config/zsh/claude-accounts.zsh`, sourced by both `.zshrc` files.
- `settings.json`, `.claude.json`, credentials and history are local to each machine and stay out of the repo (`settings.json` holds work-internal details).
- Some skills are local-only and gitignored (see `.gitignore`); don't commit them.
- `~/.claude-*` must be real dirs before stowing, or stow folds them into a symlink and Claude Code writes its state into the repo.
