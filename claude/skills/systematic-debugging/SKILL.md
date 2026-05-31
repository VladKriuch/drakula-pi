---
name: systematic-debugging
description: Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes
---

# Systematic Debugging

## Overview

Random fixes waste time and create new bugs. Quick patches mask underlying issues.

**Core principle:** ALWAYS find root cause before attempting fixes. Symptom fixes are failure.

**Violating the letter of this process is violating the spirit of debugging.**

## The Iron Law

```
NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST
```

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue:
- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

**Use this ESPECIALLY when:**
- Under time pressure (emergencies make guessing tempting)
- "Just one quick fix" seems obvious
- You've already tried multiple fixes
- Previous fix didn't work
- You don't fully understand the issue

**Don't skip when:**
- Issue seems simple (simple bugs have root causes too)
- You're in a hurry (rushing guarantees rework)
- Manager wants it fixed NOW (systematic is faster than thrashing)

## The Four Phases

You MUST complete each phase before proceeding to the next.

### Phase 1: Root Cause Investigation

**BEFORE attempting ANY fix:**

1. **Read Error Messages Carefully**
   - Don't skip past errors or warnings
   - They often contain the exact solution
   - Read stack traces completely
   - Note line numbers, file paths, error codes

2. **Reproduce Consistently**
   - Can you trigger it reliably?
   - What are the exact steps?
   - Does it happen every time?
   - If not reproducible → gather more data, don't guess

3. **Check Recent Changes**
   - What changed that could cause this?
   - Git diff, recent commits
   - New dependencies, config changes
   - Environmental differences

4. **Gather Evidence in Multi-Component Systems**

   **WHEN system has multiple components (CI → build → signing, API → service → database):**

   **BEFORE proposing fixes, add diagnostic instrumentation:**
   ```
   For EACH component boundary:
     - Log what data enters component
     - Log what data exits component
     - Verify environment/config propagation
     - Check state at each layer

   Run once to gather evidence showing WHERE it breaks
   THEN analyze evidence to identify failing component
   THEN investigate that specific component
   ```

   **Example (multi-layer system):**
   ```bash
   # Layer 1: Workflow
   echo "=== Secrets available in workflow: ==="
   echo "IDENTITY: ${IDENTITY:+SET}${IDENTITY:-UNSET}"

   # Layer 2: Build script
   echo "=== Env vars in build script: ==="
   env | grep IDENTITY || echo "IDENTITY not in environment"

   # Layer 3: Signing script
   echo "=== Keychain state: ==="
   security list-keychains
   security find-identity -v

   # Layer 4: Actual signing
   codesign --sign "$IDENTITY" --verbose=4 "$APP"
   ```

   **This reveals:** Which layer fails (secrets → workflow ✓, workflow → build ✗)

5. **Trace Data Flow** — when the error is deep in the call stack, trace backward to find the original trigger. See **Techniques → Root Cause Tracing** below. Fix at source, not at symptom.

6. **Sensitive data while instrumenting**

   When adding diagnostic logs, NEVER log raw secrets, tokens, passwords, or `.env` values. Log presence/absence (`SET` / `UNSET`), lengths, or hashes — never the value itself. If you need to read a sensitive value to debug, ask Vlad first (per CLAUDE.md).

### Phase 2: Pattern Analysis

**Find the pattern before fixing:**

1. **Find Working Examples**
   - Locate similar working code in same codebase
   - What works that's similar to what's broken?

2. **Compare Against References**
   - If implementing pattern, read reference implementation COMPLETELY
   - Don't skim - read every line
   - Understand the pattern fully before applying

3. **Identify Differences**
   - What's different between working and broken?
   - List every difference, however small
   - Don't assume "that can't matter"

4. **Understand Dependencies**
   - What other components does this need?
   - What settings, config, environment?
   - What assumptions does it make?

### Phase 3: Hypothesis and Testing

**Scientific method:**

1. **Form Single Hypothesis**
   - State clearly: "I think X is the root cause because Y"
   - Write it down
   - Be specific, not vague

2. **Test Minimally**
   - Make the SMALLEST possible change to test hypothesis
   - One variable at a time
   - Don't fix multiple things at once

3. **Verify Before Continuing**
   - Did it work? Yes → Phase 4
   - Didn't work? Form NEW hypothesis
   - DON'T add more fixes on top

4. **When You Don't Know**
   - Say "I don't understand X"
   - Don't pretend to know
   - Ask for help
   - Research more

### Phase 4: Implementation

**Fix the root cause, not the symptom:**

1. **Create Failing Test Case**
   - Simplest possible reproduction
   - Automated test if possible
   - One-off test script if no framework
   - MUST have before fixing
   - Follow the TDD process from CLAUDE.md (Test Driven Development section): failing test → confirm fail → minimal fix → confirm pass

2. **Implement Single Fix**
   - Address the root cause identified
   - ONE change at a time
   - No "while I'm here" improvements
   - No bundled refactoring

3. **Verify Fix**
   - Test passes now?
   - No other tests broken?
   - Issue actually resolved?

4. **If Fix Doesn't Work**
   - STOP
   - Count: How many fixes have you tried?
   - If < 3: Return to Phase 1, re-analyze with new information
   - **If ≥ 3: STOP and question the architecture (step 5 below)**
   - DON'T attempt Fix #4 without architectural discussion

5. **If 3+ Fixes Failed: Question Architecture**

   **Pattern indicating architectural problem:**
   - Each fix reveals new shared state/coupling/problem in different place
   - Fixes require "massive refactoring" to implement
   - Each fix creates new symptoms elsewhere

   **STOP and question fundamentals:**
   - Is this pattern fundamentally sound?
   - Are we "sticking with it through sheer inertia"?
   - Should we refactor architecture vs. continue fixing symptoms?

   **Discuss with Vlad before attempting more fixes.**

   This is NOT a failed hypothesis — this is a wrong architecture.

## Red Flags - STOP and Follow Process

If you catch yourself thinking:
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "Add multiple changes, run tests"
- "Skip the test, I'll manually verify"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- "Pattern says X but I'll adapt it differently"
- "Here are the main problems: [lists fixes without investigation]"
- Proposing solutions before tracing data flow
- **"One more fix attempt" (when already tried 2+)**
- **Each fix reveals new problem in different place**

**ALL of these mean: STOP. Return to Phase 1.**

**If 3+ fixes failed:** Question the architecture (see Phase 4.5)

## Vlad's Signals You're Doing It Wrong

**Watch for these redirections from Vlad:**
- "Is that not happening?" — you assumed without verifying
- "Will it show us...?" — you should have added evidence gathering
- "Stop guessing" — you're proposing fixes without understanding
- "Ultrathink this" — question fundamentals, not just symptoms
- "We're stuck?" (frustrated) — your approach isn't working
- "Strange things are afoot at the Circle K" — Vlad disagrees with your direction (per CLAUDE.md)

**When you see these:** STOP. Return to Phase 1.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Issue is simple, don't need process" | Simple issues have root causes too. Process is fast for simple bugs. |
| "Emergency, no time for process" | Systematic debugging is FASTER than guess-and-check thrashing. |
| "Just try this first, then investigate" | First fix sets the pattern. Do it right from the start. |
| "I'll write test after confirming fix works" | Untested fixes don't stick. Test first proves it. |
| "Multiple fixes at once saves time" | Can't isolate what worked. Causes new bugs. |
| "Reference too long, I'll adapt the pattern" | Partial understanding guarantees bugs. Read it completely. |
| "I see the problem, let me fix it" | Seeing symptoms ≠ understanding root cause. |
| "One more fix attempt" (after 2+ failures) | 3+ failures = architectural problem. Question pattern, don't fix again. |

## Quick Reference

| Phase | Key Activities | Success Criteria |
|-------|---------------|------------------|
| **1. Root Cause** | Read errors, reproduce, check changes, gather evidence | Understand WHAT and WHY |
| **2. Pattern** | Find working examples, compare | Identify differences |
| **3. Hypothesis** | Form theory, test minimally | Confirmed or new hypothesis |
| **4. Implementation** | Create test, fix, verify | Bug resolved, tests pass |

## Techniques

Apply these inside the appropriate phase. Language-agnostic — translate the patterns to whatever stack the bug lives in.

### Root Cause Tracing

When the error surfaces deep in the call stack, trace backward to the original trigger.

1. **Observe the symptom.** Capture the exact error and where it surfaces.
2. **Find the immediate cause.** What code directly produces the error?
3. **Ask: what called this?** Walk one level up the call chain.
4. **Keep tracing up.** At each level, ask "what value was passed, where did it come from?"
5. **Find the original trigger.** The place where the bad value first entered the system.

Fix at the source. Never at the symptom.

**When you can't trace manually**, add instrumentation: log directly before the suspicious operation (not after it fails), capture the stack trace, log relevant context (input values, environment presence, timestamps). Run the failing case once, analyze, then remove the instrumentation.

**Tips:**
- In tests, write to stderr (most loggers may be suppressed by the test runner).
- Log *before* the dangerous operation, not after the failure.
- Include context: input values, current working directory, env var presence (never raw secret values), timestamps.
- Capture the full call chain when supported by the language (e.g. `Error.stack`, `traceback.format_stack()`).

### Bisecting Test Pollution

When something appears during tests (stray files, leftover state, leaked ports) but you don't know which test created it:

1. **Define the pollution check** — exactly what should NOT exist after a clean run (a file path, a bound port, an env var, a database row).
2. **Clean to a known-good state** before each run.
3. **Bisect** the test suite — run half, check for pollution. Present? Polluter is in that half. Absent? It's in the other half. Recurse until you isolate one test file or test case.
4. For small suites, linear scan is fine — run tests one at a time, stop at the first one that pollutes.
5. **Investigate the polluter** — what does it create, why doesn't it clean up, is the resource shared with other tests?

Tailor the bisection loop to your test runner — don't carry a generic script.

### Defense in Depth

When you fix a bug caused by invalid data, add validation at *every* layer the data passes through. Single-point fixes get bypassed by other code paths, refactors, or mocks. Multiple layers make the bug structurally impossible.

**Four layers:**

1. **Entry-point validation** — reject obviously invalid input at the API boundary (empty strings, missing required values, wrong types, non-existent paths, unwritable directories).
2. **Business logic validation** — ensure data makes sense for this specific operation (preconditions, consistency with other inputs, invariants).
3. **Environment guards** — prevent dangerous operations in specific contexts (e.g. refuse to write outside a temp directory during tests, refuse destructive ops in production without an explicit flag).
4. **Debug instrumentation** — capture context before the dangerous operation (input values, env presence, stack trace) so future failures leave forensics behind.

Different layers catch different cases. Don't stop at one validation point.

### Condition-Based Waiting

Flaky async tests often guess at timing with arbitrary `sleep()` calls. They pass on fast machines and fail under load. Wait for the actual condition, not a guess about duration.

**Pattern:**

```
waitFor(condition, timeoutMs):
  start = now()
  loop:
    if condition() is true: return
    if now() - start > timeoutMs: throw TimeoutError(description)
    sleep 10ms
```

**Common conditions:**
- Wait for an event: `events.find(matches predicate)`
- Wait for state: `machine.state == 'ready'`
- Wait for count: `items.length >= N`
- Wait for file/resource: `exists(path)` / `port.isBound()`
- Composite: `obj.ready and obj.value > 10`

**Don't:**
- Poll faster than ~10ms (CPU waste, no observability gain).
- Skip the timeout (loops forever on broken systems, hides the real failure).
- Cache state before the loop — read fresh inside the loop or you'll spin on stale values.

**Arbitrary `sleep()` is sometimes correct** — when testing actual timed behavior (debounce, throttle, scheduled ticks). In that case:
1. First wait for the triggering condition.
2. Then sleep the timed behavior duration (justified by known timing, not a guess).
3. Comment explaining WHY the duration is what it is.

### When investigation truly bottoms out

If systematic investigation reveals the issue is genuinely environmental, timing-dependent, or external: document what you ruled out, implement appropriate handling (retry, timeout, clear error message), and tell Vlad. But assume incomplete investigation first — that's the cause 95% of the time.
