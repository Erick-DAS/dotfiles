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

## Claude Code

- A single account on the default config dir `~/.claude` (no `CLAUDE_CONFIG_DIR`).
- Its tracked config is `common/.claude` (`CLAUDE.md` and `skills/`).
- `settings.json`, `~/.claude.json`, credentials and history are local to each machine and stay out of the repo.
- `skills/synced` holds skills synced from claude.ai; it is gitignored, don't commit it.
- `~/.claude` must be a real dir before stowing, or stow folds it into a symlink and Claude Code writes its state into the repo.
