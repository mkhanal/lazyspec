# lazyspec

This repository is the tool. It is also the first thing the tool is
pointed at, so the instruction below is not an example: it governs work
in here.

Tests: `node --test specs/*.lazyspec.test.js`. `sh sandbox/run.sh`
builds a throwaway consumer repository and exercises every scenario
against it; `sh sandbox/install.sh` does the same for the manifests, the
install routes and the paste. CI runs all four under dash and busybox.
There is no gate and no build.
Nothing here is a program. It is three skills, one standing instruction,
and a notice every specification carries.

This is the file every agent reads. Editors that look for a name of their
own get a short file that points here rather than a second copy.

<!-- Below is lazyspec.instruction.md, word for word. Change it there, not here. -->

## Specifications

Requirements live in `*.lazyspec.md`. Read `lazyspec.md` first if there is
one: which files count, and what a requirement in each area is for. A
requirement is a `## ` heading, and its text is its name.

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
grows too large and split its tests with it. Where tests already exist,
write the married file anyway: names in an ordinary suite were not
written to be requirements. The old tests stay, marrying nothing.
Untestable? Mark it `## Name <!-- no-test: why -->`.

**Specifications are locked unless you are in `/lazyspec`.** Run
`/lazyspec` to change one, with its tests in the same edit, never beside
unrelated work, and say that you did.

**Write each requirement as soon as you know it** - before the code,
during it, or after. Then leave it alone.

**Before finishing any task, check and report both.** `/lazyspec-validate`
does it for you.

- Every heading you touched is married. Say which are not.
- If you changed what the software does, say whether a requirement
  covers it yet. "Not yet" is fair while experimenting, not in a pull
  request.
