---
name: reminder
description: Manage repository-level TODOs and reminders using git notes
disable-model-invocation: true
allowed-tools: Bash, Read, Write
---

# Reminder Skill

Manage repository-level TODOs and reminders using git notes. These are for meta-tasks about the repository itself, **not** generator business logic.

## What Goes Here

**DO use reminders for:**
- Repository maintenance (remove vendor/, clean up temp files)
- Documentation updates (update upstream docs, write blog posts)
- Infrastructure tasks (CI setup, testing frameworks)
- Code cleanup (refactoring, removing deprecated code)
- Future features (design docs, proof-of-concepts)
- Release tasks (tag versions, update changelogs)

**DON'T use reminders for:**
- Generator bugs or features (use GitHub issues instead)
- Code TODOs (use `// TODO:` comments in code)
- Active development tasks (use TodoWrite tool during sessions)

## Commands

### List all reminders
```bash
git notes --ref=reminders list | while read note commit; do
  echo "=== Commit: $(git log -1 --oneline $commit) ==="
  git notes --ref=reminders show $commit
  echo
done
```

### Add a reminder
```bash
# Add to HEAD
git notes --ref=reminders add -m "TODO: Your reminder here"

# Add to specific commit
git notes --ref=reminders add -m "TODO: Your reminder here" <commit-sha>
```

### View reminder for current HEAD
```bash
git notes --ref=reminders show HEAD
```

### Remove a reminder
```bash
git notes --ref=reminders remove HEAD
# or
git notes --ref=reminders remove <commit-sha>
```

### Push/pull reminders
```bash
# Push reminders to remote
git push origin refs/notes/reminders

# Fetch reminders from remote
git fetch origin refs/notes/reminders:refs/notes/reminders
```

## Current Reminders

Some initial ideas for this repository:

1. **Remove vendor/serde/** - Once serde is properly packaged, remove the typecheck stub
2. **Re-add Motoko samples to git** - When generator is stable, commit sample files
3. **Create integration tests** - Add tests that generate + typecheck Motoko samples
4. **Document Motoko generator in upstream** - PR to OpenAPITools/openapi-generator docs
5. **Set up CI for Motoko** - Automated generation and typechecking on PRs
6. **Add more OpenAPI specs** - Test with real-world APIs beyond petstore

## Git Notes Storage

Reminders are stored in `refs/notes/reminders` (separate from default `refs/notes/commits`).

This keeps them:
- ✅ Version controlled with git
- ✅ Attached to specific commits for context
- ✅ Separate from code and standard git notes
- ✅ Pushable/pullable to share with collaborators

When invoked, help the user with:
- Adding new reminders for repository tasks
- Listing and reviewing existing reminders
- Cleaning up completed reminders
- Organizing meta-work separate from generator logic
