# Contributing

This repository is the tool, pointed at itself. A specification in here
is changed the way one in yours is: through `/lazyspec`, with its test in
the same edit.

Using lazyspec in your own project is [README.md](README.md). This file
is for working on lazyspec itself.

## What is where

```
lazyspec.instruction.md              the standing instruction. the product.
lazyspec.md                 where this repository's requirements live
lazyspec.example.md         the same file, in several layouts
skills/lazyspec-setup/      puts the instruction where agents read it
skills/lazyspec/            the only way to change a specification
skills/lazyspec-validate/   the check
specs/                      this repository's own requirements
sandbox/                    throwaway consumer repos, and their scenarios
.claude-plugin/             manifests. .cursor-plugin/ and .codex-plugin/ too
```

## Tests

```
node --test specs/*.lazyspec.test.js   # this repository's own requirements
sh sandbox/run.sh                      # 51 scenarios in a throwaway repo
sh sandbox/install.sh                  # 66 more: manifests, install, the paste
sh sandbox/isolation.sh                # proves the sandbox is sealed off
```

No gate, no build. `.github/workflows/tests.yml` runs all four on every
push, under dash on ubuntu and under busybox on alpine.

**Two userlands, because one was not enough.** A `tr` set that deleted
three characters on BSD and none on busybox passed on a laptop and failed
everywhere else. That workflow is this repository's own; lazyspec ships
no CI for anybody else's, because which agent runs the judged half and
what a verdict does to a pull request are not ours to choose.

**Neither sandbox runs a test runner.** They check names, files and text,
which is what lazyspec is made of. The claims behind them — that a dot is
illegal in a Java class name, that pytest cannot import
`test_billing.lazyspec.py`, that `unittest` skips it in silence — were
checked by running `go test`, `javac`, `pytest` and `unittest` by hand.

## Changing anything here

Run `/lazyspec`. Run `/lazyspec-validate` before you finish. Say in the
commit that you changed a specification, because nothing but you will.

**What is specified**, and why only these four:

- `specs/format.lazyspec.md` — the shape of a specification: its header,
  its heading level, and how its test is named. The header is the one
  part that reaches every agent with nothing installed.
- `specs/instruction.lazyspec.md` — the shipped writing's budget and
  shape. "Under two thousand characters" is a requirement, not a
  preference: `lazyspec.instruction.md` is read on every task forever,
  and a test is the only thing that holds prose to a budget.
- `specs/install.lazyspec.md` — what installing must leave behind. The
  manifests are load-bearing and invisible: get one name wrong and the
  skills arrive with no instruction to point at.
- `specs/areas.lazyspec.md` — that where requirements live is written in
  prose. It was a yaml schema once, and the requirement exists so that
  drifting back is a failing test rather than a preference.

The skills and the README are ordinary writing. Change them without
ceremony — but read [the note on prose](#the-part-no-test-reaches) first.

## The part no test reaches

No assertion tells you whether an agent reading a skill does the right
thing. The only test for that is handing this repository to agents that
have never seen it and watching what they do.

It has been done twice. Both installed it correctly from plain English
with no slash command, and between them they found four documentation
defects in one pass — including a rule in the README that contradicted a
skill forty lines away, and an install route that dropped Cursor.

If you change a skill, that is the review it wants. A green suite says
the artifacts are intact; it says nothing about whether the writing
works.

## On Windows

`.claude/skills/*` are symlinks into `skills/`. Git only recreates them
with `git config --global core.symlinks true` set before cloning, and
that needs Developer Mode or an elevated shell. Otherwise copy the folder
instead: `cp -R skills/. .claude/skills/`. Everything else here is plain
text and `sh`.

## Nothing here is a program

There is no build, no gate, and nothing to install to work on it — which
is the same claim the tool makes about itself, so it had better stay
true.
