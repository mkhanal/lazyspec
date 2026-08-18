# lazyspec

This repository is the tool. It is also the first thing the tool is
pointed at, so the instruction below is not an example: it governs work
in here.

Tests: `node --test specs/*.lazyspec.test.js`. `sh sandbox/run.sh`
builds a throwaway consumer repository and exercises every scenario
against it. There is no gate and no build.
Nothing here is a program. It is two skills, one standing instruction,
and a notice every specification carries.

This is the file every agent reads. Editors that look for a name of their
own get a short file that points here rather than a second copy.

<!-- Below is INSTRUCTION.md, word for word. Change it there, not here. -->

## Specifications

Requirements live in `*.lazyspec.md` files. Read `.lazyspec.yaml` first
if there is one: which files count, and what each set is for.

A requirement is a `## ` heading in such a file, and its text is its only
identifier.

**A requirement is married to a test: one whose name repeats that text
word for word, in the one file naming the specification and `lazyspec`.**
Spell both the way this repository spells test names:

```
billing.lazyspec.md        ## Refunds Never Exceed What Was Captured
billing.lazyspec.test.ts   describe('Refunds Never Exceed What Was Captured', ..)
test_billing_lazyspec.py   """Refunds Never Exceed What Was Captured"""
billing_lazyspec_test.go   t.Run("Refunds Never Exceed What Was Captured", ..)
```

Most tests marry nothing, and should not: unit and integration tests sit
below the requirements. One specification is married to one test file. Split one that grows too
large, and split its test file with it. If the code already has tests,
name the specification after the file that proves it. If a requirement
cannot be tested, mark it `## Name <!-- no-test: why -->`.

**Specifications are locked unless you are in `/lazyspec`.** Every one
says so on its first line. Change one only there, with its tests in the
same edit, never beside unrelated work, and say that you did.

**Write each requirement once it is known**, which is usually partway
through rather than at either end. Code and tests may run ahead; the
requirement catches up. Write it then, and leave it alone.

**Before finishing any task, check and report both.**
`/lazyspec-validate` does it for you.

1. Every heading you touched is married - repeated word for word by a
   test, in the file named after its specification. Say which are not.
2. If you changed what the software does, say whether a requirement
   covers it yet. "Not yet" is fair while you are still experimenting,
   and not fair in a pull request.
