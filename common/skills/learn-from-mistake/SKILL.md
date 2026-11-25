---
name: learn-from-mistake
description: Use when Vlad says that some code is coded wrong. Always ask Vlad before you run this skill; if in doubt, do not run it. Finds what is wrong and fixes the code. Adds a guard (a lint rule, a test, or a smell file in memory) only for a general pattern, a mistake that can occur again in other code; for a one-time thing or a matter of taste, only fixes the code.
---

# Learn from mistake

Vlad says that some code is wrong. Find the mistake, add a guard against it, then fix the code.

## Before you start

- Always ask Vlad before you run this skill.
- If you are in doubt, do not run it. Only fix the code. Vlad runs the skill directly when it is necessary.

## Pattern or one-time thing

Add a guard only for a general pattern: a mistake that can occur again in other code. Do not add a guard for a one-time thing or a matter of taste. Only fix the code.

- General pattern: renaming `this_value_equals_to_clients_amount_of_authors = 10` to `amount_of_authors`. The mistake is general: a long name that explains the code instead of naming the value. A name must be short and clear.
- One-time thing: renaming `amount_of_authors` to `author_count`. Both names are good. This is taste, not a pattern.

## Steps

1. Find what is wrong. Write it to Vlad in one sentence, and say why it is wrong. If it is not clear, ask Vlad.
2. Tell Vlad if it is a general pattern or a one-time thing. If it is a one-time thing, only fix the code and stop.
3. Choose ONE guard and ask Vlad before you add it. Use the first one in this list that can catch the mistake:
   1. **Lint rule** — the mistake is a pattern that a linter can find in the code.
   2. **Test** — the mistake is wrong behavior that a test can find.
   3. **Smell file** — lint and tests cannot catch it. Write a smell file only when Vlad asks for it. If Vlad did not ask, propose it.
4. Add the guard. A lint rule or a test must fail on the wrong code. Run it and make sure that it fails.
5. Fix the code. Run the lint rule or test again and make sure that it passes.
6. Tell Vlad what was wrong, which guard you added, and where.

## 1. Lint rule

- Use the linter that the project already has (for example ruff, eslint). Add the rule to its existing config.
- If the linter has a built-in rule for the pattern, turn it on. Write a custom rule only when no built-in rule exists.
- If the project has no linter, ask Vlad before you add one.

## 2. Test

- Use the test framework that the project already has.
- The test checks the correct behavior, not the mistake. Its name tells what the code must do.

## 3. Smell file

A smell file tells agents about a mistake that tools cannot catch. Agents read the titles while they code. When a title matches the work, they read the file.

**Where:**

- Only this repo: `<repo>/.agents/memory/smells/`
- All projects: `~/.agents/memory/smells/`

If it is not clear which one, ask Vlad.

**File name:** the title in kebab-case, for example `isinstance-checks-on-data-that-has-a-contract.md`.

**Title:** it must tell what was wrong without the file body. An agent must be able to match the title to the code it writes. Bad title: `Validation issue`. Good title: `isinstance checks on data that has a contract`.

**Content:**

```markdown
# <Title: what was wrong>

**What was wrong:** <the mistake, in one or two sentences>

**Why it is wrong:** <the reason>

**Example:**
<short wrong code, then short correct code>
```

The example is optional. Add it only when it makes the smell clearer.
