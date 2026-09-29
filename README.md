# dotfiles

My personal dotfiles for all my setups, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level folder is a stow package that mirrors `$HOME`:

| Package        | Used on                    | Contents                                          |
| -------------- | -------------------------- | ------------------------------------------------- |
| `i3-laptop`    | laptop (i3, X11)           | i3, kitty, fastfetch, monitor scripts, `.zshrc`   |
| `sway-desktop` | desktop (sway, Wayland)    | sway, waybar, rofi, kitty, oh-my-zsh, `.zshrc`    |
| `common`       | both machines              | nvim, lazygit, zsh snippets, Claude Code configs  |
A file at `common/.config/nvim/init.lua` ends up linked at `~/.config/nvim/init.lua`.

## Install

Clone into `~/dotfiles` (stow links into the parent folder) and stow `common` plus the machine's package:

```sh
sudo dnf install stow
git clone git@github.com:Erick-DAS/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow common i3-laptop      # on the laptop
stow common sway-desktop   # on the desktop
```

After adding, moving or deleting files in a package, restow it so the links follow:

```sh
stow -R common i3-laptop
```

Use `stow -n -v ...` to preview what would change, and `stow -D <package>` to remove a package's links.

## Claude Code accounts

There are two Claude Code accounts, each with its own config dir:

- `~/.claude-work`, from `common/.claude-work`
- `~/.claude-personal`, from `common/.claude-personal`

Launch them with the `claude-work` and `claude-personal` aliases (from `common/.config/zsh/claude-accounts.zsh`).
A bare `claude` refuses to run, so nothing falls back to the default `~/.claude`.

Stow only links `CLAUDE.md` and `skills/` into those dirs.
Credentials, history, `settings.json` and `.claude.json` stay local to each machine and never enter this public repo.

Create both dirs as real folders before stowing on a new machine:

```sh
mkdir -m 700 ~/.claude-work ~/.claude-personal
```

Otherwise stow links the whole dir into the repo, and Claude Code writes its state here.
