# General agent instructions

These are common instructions for agents across all scenarios

## General Guidelines

- Never use the em dash "—". Prefer using a parenthesis, the plain dash "-" or explaining it somehow else.
- When writing commit messages, NEVER auto-add your agent name as co-author
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated
- When writing or substantially editing long Markdown files, put each full sentence on its own line.
  Preserve normal Markdown structure, but avoid wrapping multiple sentences onto one physical line.
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- Don't ever do any testing or smoke testing without asking the user before.
- Always reply the user with the language he is using, unless otherwise stated.

## Safety Guidelines

- Even on auto mode, only read folders and files outside the current directory if the user directory
  prompts you to do so. If you think you need to, ask the user for his permission.
- If you need to check any database, avoid using bash or python scripts. Always prefer using the `psql` CLI.
