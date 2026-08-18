## Specifications

Requirements live in `*.lazyspec.md`. Read `.lazyspec.yaml` first if there
is one: which files count, and what each set is for. A requirement is a
`## ` heading, and its text is its name.

**It is married to a test repeating that text word for word, in the one
file naming the specification and `lazyspec`.** Join them the way this
repository joins words in test names; some languages cannot take a dot:

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

**Specifications are locked unless you are in `/lazyspec`.** Run
`/lazyspec` to change one, with its tests in the same edit, never beside
unrelated work, and say that you did.

**Write a requirement when the behaviour has settled enough to state.**
Code and tests may run ahead; the requirement catches up. Then leave it
alone.

**Before finishing any task, check and report both.** `/lazyspec-validate`
does it for you.

1. Every heading you touched is married. Say which are not.
2. If you changed what the software does, say whether a requirement
   covers it yet. "Not yet" is fair while experimenting, not in a pull
   request.
