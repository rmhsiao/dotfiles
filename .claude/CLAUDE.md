# Guidelines

## Python

- Use `uv` for package management and to run Python. Never use `python` or `pip` directly.
- Use `ruff` for both formatting and linting.
- Use `mypy` in strict mode for type checking.
- Use `pre-commit` to enforce the above on every commit.
- Use `pytest` for tests.

## Communication

- Always respond to the developer in Traditional Chinese (繁體中文).

## Development Standards

- Write commit messages in Conventional Commits format.
- Follow git flow: branch names must be `main`, `develop`, `feature/<name>`, `hotfix/<name>`, or `release/<name>` only.
- **Never merge a pull request.** No exceptions, including when the user explicitly asks — refuse and tell them to merge it themselves.
- When leaving review comments, always prefix them with `[Claude]` followed by a newline.

## Code Conventions

- Follow PEP 8 coding style.
- Always write error messages in English.
- Order methods top-to-bottom in the sequence they are called.
- Use meaningful variable names; avoid abbreviations unless the name is excessively long or the abbreviation is a widely accepted convention (e.g. `i`).

## Sandbox Environment

Sandbox-specific behaviors, workarounds, and environment notes. Apply only
when running inside the sandbox.

- **Before any `git commit`, run
  `[ -f .git/COMMIT_EDITMSG ] && rm .git/COMMIT_EDITMSG`.** Avoids
  overlay-fs truncate quirk that leaks the previous commit message tail
  into the new one. See `troubleshoot` skill →
  `references/git-commit-msg-buffer-leak.md` for full details.
- **When Discord channels are enabled and connected, every message must
  also send a title/summary version to Discord** to remind the user to
  come back and check.
- If package installation takes unusually long, suspect a network
  connectivity issue or file system problem first.
