---
name: create-gcm
description: Use this skill when the user asks to generate, write, or create a git commit message. Trigger contexts include phrases like "commit", "git commit", "generate commit message", "write commit", "commit message", etc.
version: 1.0.0
---

## Commit standards

Follow Conventional Commits format for commit messages. Allowed types are
listed below. Add a scope if needed.

FORMAT (Conventional Commits 1.0.0):
```
<type>[optional scope]: <description>
[optional body]
```

Examples:
- feat: 定義 base agent class
- fix(chitchat): 修正 chitchat 串流時的 async bug
- docs(data): 更新資料前處理元件的 docstring 與 comment

## Allowed types:

- feat       — a new feature (MINOR)
- fix        — a bug fix (PATCH)
- docs       — documentation only changes
- style      — formatting, linting, etc.; no code change or typing refactors
- refactor   — code change that neither fixes a bug nor adds a feature
- perf       — code change that improves performance
- test       — adding tests or correcting existing
- build      — changes that affect the build system/external dependencies
- ci         — continuous integration/configuration changes
- chore      — other changes that don't modify source or test files
- revert     — reverts a previous commit
- release    — prepare a new release

## Guidelines for writing commit messages:

[Pre-checks]
1. Before writing the commit message, verify the staged changes are atomic
   (one logical change per commit). If not, ask the developer to confirm
   before proceeding.

[Content]
2. Derive the commit message from the staged diffs.
3. If a scope is needed, ask the developer or determine it from previous
   commits in the same branch.
4. Describe the "why" of the changes and why the proposed solution is the
   right one. Limit prose.
5. Write commit messages in traditional Chinese.

[Formatting]
6. The title of the commit message should not exceed 50 characters.
7. Wrap each line of the commit body at 72 characters.
8. It's ok to provide no commit body if the change is self-explanatory.
9. If the commit body contains a list of changes, sort them by importance
   (most important first).
