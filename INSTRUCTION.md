## Specifications

Requirements live in `*.lazyspec.md`. Read `.lazyspec.yaml` first if there
is one: which files count, and what each set is for. A requirement is a
`## ` heading, and its text is its name.

**It is married to a test repeating that text word for word, in the one
file naming the specification and `lazyspec`.** Spell both the way this
repository spells test names:

```
billing.lazyspec.md        ## Refunds Never Exceed What Was Captured
billing.lazyspec.test.ts   describe('Refunds Never Exceed What Was Captured', ..)
test_billing_lazyspec.py   """Refunds Never Exceed What Was Captured"""
billing_lazyspec_test.go   t.Run("Refunds Never Exceed What Was Captured", ..)
```

Most tests marry nothing, and should not: unit and integration tests sit
below the requirements. One specification, one test file - split one that
grows too large and split its tests with it. If the code already has
tests, name the specification after the file that proves it. Untestable?
Mark it `## Name <!-- no-test: why -->`.

**Specifications are locked unless you are in `/lazyspec`.** Every one
says so on its first line. Change one only there, with its tests in the
same edit, never beside unrelated work, and say that you did.

**Write each requirement once it is known**, usually partway through
rather than at either end. Code and tests may run ahead; the requirement
catches up. Write it then and leave it alone.

**Before finishing any task, check and report both.** `/lazyspec-validate`
does it for you.

1. Every heading you touched is married - repeated word for word by a
   test, in the file named after its specification. Say which are not.
2. If you changed what the software does, say whether a requirement
   covers it yet. "Not yet" is fair while experimenting, not in a pull
   request.
