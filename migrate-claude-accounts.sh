#!/usr/bin/env bash
# One-off: split the single ~/.claude into ~/.claude-work and ~/.claude-personal.
# Usage: ./migrate-claude-accounts.sh <account-of-current-~/.claude: work|personal> <stow-package: i3-laptop|sway-desktop>
set -euo pipefail

current_account=${1:?usage: $0 <work|personal> <stow-package>}
stow_package=${2:?usage: $0 <work|personal> <stow-package>}
dotfiles_dir=$(cd "$(dirname "$0")" && pwd)

case $current_account in
  work) other_account=personal ;;
  personal) other_account=work ;;
  *) echo "account must be 'work' or 'personal'" >&2; exit 1 ;;
esac

current_dir="$HOME/.claude-$current_account"
other_dir="$HOME/.claude-$other_account"

die() { echo "error: $*" >&2; exit 1; }

[[ -z ${CLAUDECODE:-} ]] || die "run this from a plain terminal, not from inside Claude Code"
if pgrep -x claude >/dev/null; then
  pgrep -a -x claude >&2
  die "close every Claude Code session first; they keep writing to ~/.claude"
fi
command -v stow >/dev/null || die "stow is not installed"
command -v jq >/dev/null || die "jq is not installed"
[[ -d $dotfiles_dir/$stow_package ]] || die "no stow package '$stow_package' in $dotfiles_dir"
[[ -d $HOME/.claude && ! -L $HOME/.claude ]] || die "~/.claude is missing or is a symlink"
[[ -f $HOME/.claude.json ]] || die "~/.claude.json is missing"
[[ ! -e $current_dir ]] || die "$current_dir already exists"
[[ ! -e $other_dir ]] || die "$other_dir already exists"

logged_in_as=$(jq -r '.oauthAccount.emailAddress // "unknown"' "$HOME/.claude.json")
echo "~/.claude is logged in as: $logged_in_as"
echo "It will become:            $current_dir"
echo "New empty account dir:     $other_dir"
read -rp "Continue? [y/N] " answer
[[ $answer == [yY] ]] || die "aborted"

echo "==> Moving ~/.claude to $current_dir"
mv "$HOME/.claude" "$current_dir"
mv "$HOME/.claude.json" "$current_dir/.claude.json"
# Old stow links point at the removed common/.claude package; stow recreates them below
find "$current_dir" -maxdepth 1 -xtype l -print -delete
for plugin_index in installed_plugins.json known_marketplaces.json; do
  [[ -f $current_dir/plugins/$plugin_index ]] &&
    sed -i "s#$HOME/.claude/#$current_dir/#g" "$current_dir/plugins/$plugin_index"
done
chmod 700 "$current_dir"

echo "==> Creating $other_dir"
# Must be a real dir before stow runs, or stow folds it into a symlink into the public repo
mkdir -m 700 "$other_dir"
[[ -f $current_dir/settings.json ]] && cp "$current_dir/settings.json" "$other_dir/settings.json"

echo "==> Stowing common and $stow_package"
(cd "$dotfiles_dir" && stow -R common "$stow_package")

echo "==> Copying user-scope MCP servers to $other_account"
jq -r '.mcpServers // {} | keys[]' "$current_dir/.claude.json" | while read -r server; do
  server_json=$(jq -c --arg s "$server" '.mcpServers[$s]' "$current_dir/.claude.json")
  CLAUDE_CONFIG_DIR="$other_dir" command claude mcp add-json --scope user "$server" "$server_json"
done

cat <<EOF

Done. Next:
  exec zsh
  claude-$other_account   -> /login with the $other_account account, accept the plugin install, /mcp to authenticate remote servers
  claude-$current_account -> /status should show $logged_in_as
Once both machines are migrated, delete this script from the repo.
EOF
