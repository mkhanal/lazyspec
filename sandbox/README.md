# sandbox

A throwaway consumer repository, built from scratch on every run, used to
test lazyspec the way somebody adopting it would meet it.

```
sh sandbox/run.sh          # rebuild sandbox/demo and run every scenario
sh sandbox/isolation.sh    # prove the demo is sealed off from this repo
```

`sandbox/demo/` is gitignored and rebuilt each time. The scripts are
committed; the demo is not.

## What the demo is

A monorepo in four languages, so nothing here can quietly depend on
JavaScript:

```
services/api      JavaScript   describe('…')          + an unmarried requirement
services/ledger   Python       a docstring
services/router   Go           t.Run("…")
apps/web          Java         @DisplayName("…")
vendor/proto      somebody else's SPEC.md, which is not ours to lock
```

It is installed the way `README.md` says to: the guard copied in, the
skills in `.claude/skills/` and `.agents/skills/`, `INSTRUCTION.md`
pasted into `AGENTS.md` between markers, `CLAUDE.md` holding `@AGENTS.md`,
and `.lazyspec-unlock` ignored.

## What it covers

- **install** - guard, both skill folders, valid Agent Skills
  frontmatter, the pasted instruction, the `CLAUDE.md` shim
- **the guard, structured tools** - every editing tool, deep paths,
  absolute paths, notebooks, a vendored `SPEC.md`, a married test, and a
  file whose *content* names a specification
- **the guard, shell calls** - redirect, append, `sed -i`, `rm`, `tee`,
  `python`, versus plain `cat` and `grep`
- **the window** - open, closed, and that the parent's window cannot open
  the demo's
- **searching for proof** - all four languages, an unmarried requirement,
  `no-test` markers, a heading in two specifications, and the same stem
  living in two packages
- **judging a change** - a specification that moved alone, one that moved
  with its test, and code that moved with neither
- **configuration** - one set per package, and that removing
  `.lazyspec.yaml` changes nothing essential

## Isolation

The repository directly above this one is lazyspec itself, so without
care it would answer for the demo. `isolation.sh` checks that it does
not:

- the demo is **its own git repository**, so `git grep` and `git diff`
  see only the demo
- the demo is **gitignored**, so its specifications never appear in this
  repository's own searches
- every guard call runs with **cwd set to the demo**, against the demo's
  **own copy** of `lazyspec-guard`
- an **open window here cannot unlock the demo**
- `demo/.claude/settings.json` sets **`claudeMdExcludes`** for this
  repository's `CLAUDE.md` and `AGENTS.md`, because Claude Code walks up
  the directory tree - without it, an agent opened inside the demo would
  inherit lazyspec's own standing instruction and the demo would prove
  nothing

One honest caveat, and it is worth reading twice: the harness scripts
contain the demo's requirement text, because they are what writes it. A
plain search from this repository therefore matches `sandbox/run.sh`.
That is a hit which proves nothing - exactly the case `/lazyspec-validate`
exists to catch - so the isolation check asks whether any file *under
sandbox/demo* is visible, rather than whether the words appear anywhere.
