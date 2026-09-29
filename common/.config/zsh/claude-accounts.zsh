# One CLAUDE_CONFIG_DIR per account, so work and personal never share auth, history or settings
alias claude-work='CLAUDE_CONFIG_DIR="$HOME/.claude-work" command claude'
alias claude-personal='CLAUDE_CONFIG_DIR="$HOME/.claude-personal" command claude'

claude() {
  if [[ -z $CLAUDE_CONFIG_DIR ]]; then
    print -u2 "claude: choose an account with claude-work or claude-personal"
    return 1
  fi
  command claude "$@"
}
