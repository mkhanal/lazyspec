## Specifications

Requirements live in `*.lazyspec.md` files. `.lazyspec.yaml` narrows that
when a repository has one; read it first.

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
BillingTest.java           @DisplayName("Refunds Never Exceed What Was Captured")
```

One specification is married to one test file. Split a specification that
grows too large, and split its test file with it. If the code already has
tests, name the specification after the file that proves it. If a
requirement cannot be tested, mark it `## Name <!-- no-test: why -->`.

**Changing a specification means updating its tests in the same edit,
never alongside unrelated work.** Run `/lazyspec`. If you cannot, say
plainly that you are changing one, and write the change as a requirement
first.

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
