# lazyspec

This repository is the tool. It is also the first thing the tool is
pointed at, so the instruction below is not an example: it governs work
in here.

Tests: `node --test specs/*.lazyspec.test.js`. `sh sandbox/run.sh`
builds a throwaway consumer repository and exercises every scenario
against it. There is no gate and no build.
`lazyspec-guard` is the only program, and `specs/guard.lazyspec.md` says
what it does. Everything else is writing: two skills, one standing
instruction.

This is the file every agent reads. Editors that look for a name of their
own get a short file that points here rather than a second copy.

<!-- Below is INSTRUCTION.md, word for word. Change it there, not here. -->

## Specifications

Requirements live in `*.lazyspec.md` files. `.lazyspec.yaml` narrows
that when there is one; read it first.

A requirement is a `## ` heading in such a file, and its text is its only
identifier.

**A requirement is married to a test: one whose name repeats that text
word for word, in a file named after the specification.** Name the file
and write the test the way this repository does:

```
billing.lazyspec.md        ## Refunds Never Exceed What Was Captured
billing.lazyspec.test.ts   describe('Refunds Never Exceed What Was Captured', ..)
test_billing.py            """Refunds Never Exceed What Was Captured"""
billing_test.go            t.Run("Refunds Never Exceed What Was Captured", ..)
```

One specification is married to one test file. Split a specification that
grows too large, and split its test file with it. If the code already has
tests, name the specification after the file that proves it. If a
requirement cannot be tested, mark it `## Name <!-- no-test: why -->`.

**Changing a specification means updating its tests in the same edit,
never alongside unrelated work.** Run `/lazyspec`.

**Specifications are locked.** To change one, name it in your own
`.lazyspec-unlock.<id>` file, change it, then delete only that file -
others may be working in this tree. If nothing refuses you, do it anyway.

**Only write a requirement once you know what the code does.** The other
direction is loose on purpose: code and tests may run ahead while you are
still working that out. The requirement catches up once you know. Write
it then, and leave it alone.

**Before finishing any task, check and report both.**
`/lazyspec-validate` does it for you.

1. Every heading you touched is married - repeated word for word by a
   test, in the file named after its specification. Say which are not.
2. If you changed what the software does, say whether a requirement
   covers it yet. "Not yet" is fair while you are still experimenting,
   and not fair in a pull request.
