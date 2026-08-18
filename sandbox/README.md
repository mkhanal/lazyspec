# sandbox

A throwaway consumer repository, built from scratch on every run, used to
test lazyspec the way somebody adopting it would meet it.

```
sh sandbox/run.sh          # rebuild sandbox/demo and run every scenario
sh sandbox/install.sh      # the manifests, the install routes, the paste
sh sandbox/isolation.sh    # prove the demo is sealed off from this repo
```

`sandbox/demo/` and `sandbox/install-demo/` are gitignored and rebuilt
each time. The scripts are committed; the demos are not.

`run.sh` starts from a repository that is already installed, because what
it tests is the convention. `install.sh` starts from a stranger's
repository that has never heard of lazyspec, because what it tests is
everything that has to be true before a requirement can be written: that
the manifests would resolve, that each route the README prints lands the
skills where that agent looks, and that the paste `/lazyspec-setup`
performs is verbatim, idempotent and leaves the team's own rules alone.

Neither runs a test runner. They check names, files and text - the things
lazyspec is made of. The language claims behind them were verified by
running `go test`, `javac`, `pytest` and `unittest` by hand.

## What the demo is

A monorepo in four languages, so nothing here can quietly depend on
JavaScript:

```
services/api      JavaScript   describe('…')   + an unmarried requirement
services/ledger   Python       a docstring
services/router   Go           t.Run("…")
apps/web          Java         @DisplayName("…")
vendor/proto      somebody else's SPEC.md
```

It is installed the way `README.md` says to: the skills in
`.claude/skills/` and `.agents/skills/`, `INSTRUCTION.md` pasted into
`AGENTS.md` between markers, and `CLAUDE.md` holding `@AGENTS.md`.
Nothing executable is installed, and a scenario checks that.

## What it covers

- **install** — both skill folders, valid Agent Skills frontmatter, the
  pasted instruction, the `CLAUDE.md` shim
- **the notice** — that every specification carries it, that it names
  `/lazyspec`, binds agents, frees people, and survives being copied
  somewhere else
- **searching for proof** — all four languages, an unmarried requirement,
  `no-test` markers, a heading in two specifications, the same stem in
  two packages, and the pasted instruction turning up as a false hit
- **judging a change** — a specification that moved alone, one that moved
  with its test, and code that moved with neither
- **configuration** — one set per package, and that removing
  `.lazyspec.yaml` changes nothing essential

## Isolation

The repository directly above this one is lazyspec itself, so without
care it would answer for the demo. `isolation.sh` checks that it does
not: the demo is its own git repository, it is gitignored so its
specifications never appear in this repository's searches, and
`demo/.claude/settings.json` sets `claudeMdExcludes` for this
repository's own `CLAUDE.md` — because Claude Code walks up the directory
tree, and without it an agent opened inside the demo would inherit
lazyspec's standing instruction and the demo would prove nothing.

One honest caveat, worth reading twice: the harness scripts contain the
demo's requirement text, because they are what writes it. A plain search
from this repository therefore matches `sandbox/run.sh`. That is a hit
which proves nothing — exactly the case `/lazyspec-validate` exists to
catch — so the isolation check asks whether any file *under sandbox/demo*
is visible, rather than whether the words appear anywhere.
