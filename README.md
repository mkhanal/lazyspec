# lazyspec

Let the agent experiment. Write the requirement once you know. Then lock
it, so nothing can quietly rewrite it.

## Does this sound familiar

- The agent changed a test instead of fixing the code, and the suite went
  green.
- A requirement was quietly reworded to match what was built.
- Your specification describes the implementation, so it says nothing.
- Spec-driven development felt like writing fiction, because nobody knew
  the behaviour yet.

## Why

Two failures, opposite directions:

- **Specify first and you spend the LLM's best trait before you have
  anything.** Agents are good at trying things: build it, run it, throw
  it away. Behaviour written down before anyone understands it is wrong
  by Thursday.
- **Specify last and the agent rewrites your requirements to match its
  code.** It edits requirements as readily as tests. The suite stays
  green. Nothing raises a hand. The specification now describes the
  implementation, which means it describes nothing.

lazyspec takes both:

- Specify **late**, once the behaviour is known.
- **Lock** the specification, so no agent edits one in passing.

## What you write

A specification is markdown. Each `## ` heading is one requirement.

```markdown
# Refunds

## Refunds Never Exceed What Was Captured

- A refund is refused when it would take the total refunded above the
  amount captured.
- Refunding the exact remaining balance is allowed.

## A Refund Is Recorded Against Its Capture <!-- no-test: the ledger is somebody else's system -->

- Every refund names the capture it draws from.
```

The test repeats the heading as its own name. That is the **marriage**:

```js
// refunds.lazyspec.test.js
describe('Refunds Never Exceed What Was Captured', () => {
  it('refuses a refund beyond the captured amount', () => { ... })
  it('allows the exact remaining balance', () => { ... })
})
```

`sh sandbox/run.sh` builds a whole repository like this - in four
languages - and checks every claim on this page against it.

## How it binds

Two bindings, both made of names.

- **The words** tie a requirement to its test. Reword the heading and the
  test is orphaned at once.
- **The filename** ties a specification to the one test file that proves
  it — exactly one, so a directory listing tells you what proves what.

Neither cares what language you write in:

| specification | its test file | how the test carries the name |
|---|---|---|
| `billing.lazyspec.md` | `billing.lazyspec.test.ts` | `describe('…')` |
| `billing.lazyspec.md` | `test_billing.py` | a docstring |
| `billing.lazyspec.md` | `billing_test.go` | `t.Run("…")` |
| `billing.lazyspec.md` | `BillingTest.java` | `@DisplayName("…")` |

- A requirement's text is its only identifier.
- Nothing here configures a language, a runner or a test folder. The
  agent reads all three off your repository.
- Where your runner leaves names free, use `<name>.lazyspec.test.*`.
- `<!-- no-test: why -->` marks a requirement nothing can prove.

## Where specifications live

Put a specification next to the code it describes.

- **Small repository?** One `specs/` folder is fine.
- **Anything bigger?** Co-locate: `services/api/specs/billing.lazyspec.md`.
  An agent working in `services/api` finds the requirement by proximity
  instead of scanning a global list, and reads fewer of them per task.
- **Monorepo?** One `sets:` entry per package. `root` is the folder a
  specification's name must be unique inside, so two packages can each
  have a `billing.lazyspec.md`.

Nesting is free and costs nothing to an agent. A single flat directory is
what gets expensive: every requirement in it is a candidate every time
somebody asks "which one covers this?"

## Install

**Claude Code and Cursor** take it as a plugin. This carries the skills
*and* the guard, and registers the hook for you:

```
/plugin marketplace add mkhanal/lazyspec
/plugin install lazyspec@lazyspec
```

**Anything else** is a clone and a copy:

```
git clone --depth 1 https://github.com/mkhanal/lazyspec /tmp/lazyspec
cp /tmp/lazyspec/lazyspec-guard .
mkdir -p .claude/skills .agents/skills
cp -R /tmp/lazyspec/skills/. .claude/skills/
cp -R /tmp/lazyspec/skills/. .agents/skills/
```

Two directories cover four agents: `.claude/skills/` for Claude Code and
opencode, `.agents/skills/` for Codex and opencode.

**Or hand it over:** *"Read
`https://github.com/mkhanal/lazyspec/blob/main/README.md` and install
it."*

### Then two things

No installer can do either one.

**1. Paste `INSTRUCTION.md` where your agent reads it every task.**

```
<!-- lazyspec:begin -->
… the body of INSTRUCTION.md …
<!-- lazyspec:end -->
```

`AGENTS.md` is the default. Every other editor gets a short file pointing
at it, never a second copy — see the table below.

- **Claude Code never looks for `AGENTS.md`.** A repository with only an
  `AGENTS.md` looks set up and is not. One line, `@AGENTS.md`, fixes it.
- Paste it, do not link to it. An instruction fetched on request is one
  that will not be followed.
- A plugin cannot do this. Plugins carry skills and hooks, not files in
  your repository.
- **Already keep a `CONSTITUTION.md`, engineering principles, or house
  rules your agents load?** That is the right home. Paste it there and
  point `AGENTS.md` at it. Lock that document too, by naming it in
  `.lazyspec-locked`.

This is also the only thing restraining an agent with no pre-tool hook.
It carries the lock protocol — name what you are about to change in a
`.lazyspec-unlock.<unique>` file, change it, delete only that one — so
that agents which cannot be stopped are at least told, in the same words
every time.

**2. Ignore the unlock file.**

```
echo '.lazyspec-unlock' >> .gitignore
```

Commit it once and the guard is off forever, silently.

There is no third step. `.lazyspec.yaml` is optional, and `/lazyspec`
offers to write it when you make your first specification.

### Check it worked

```
echo '{"tool_name":"Edit","tool_input":{"file_path":"a.lazyspec.md"}}' \
  | sh lazyspec-guard ; echo "exit $?"     # 2, with a message

echo '{"tool_name":"Edit","tool_input":{"file_path":"a.ts"}}' \
  | sh lazyspec-guard ; echo "exit $?"     # 0, silent
```

On the plugin route the guard lives inside the plugin, so ask your agent
to edit a `*.lazyspec.md` and watch it be refused instead.

Then, in a fresh session:

- `/lazyspec` and `/lazyspec-validate` appear in its skill list.
- Ask *"where do this repository's requirements live?"* It answers at
  once. If it starts searching, your instruction is not loaded and
  nothing else here matters.
- Ask for a behaviour change. It reaches for `/lazyspec`.

## Locking other files

`*.lazyspec.md` is locked by default. To lock anything else you treat as
a specification — a `CONSTITUTION.md`, an architecture decision record,
a set of documents inherited from spec-kit — put one extended regular
expression on the first line of `.lazyspec-locked`:

```
specs/[^/]*/spec\.md
```

- It **adds to** the built-in pattern, so `*.lazyspec.md` cannot be
  unlocked by a typo.
- It lives in your repository, so updating lazyspec cannot clobber it.
  That matters on the plugin route, where `lazyspec-guard` is not yours
  to edit.
- Unlike `.lazyspec-unlock`, **commit it**.

**Migrating from another spec tool** needs nothing else from us. Point
your agent at `/lazyspec` and the documents you already have; cutting
prose into `## ` headings and marrying each to a test is what that skill
describes. `specs:` in `.lazyspec.yaml` is a glob, so it finds your files
whatever they are called.

The one thing no tool can do for you is decide a requirement is true. A
requirement converted without checking that a test proves it is exactly
the thing this exists to prevent, so convert one specification at a time,
as you touch them.

## Agent support

Three capabilities. Every agent has the first, which is the one that does
the work.

| agent | instruction file | skills | can refuse a write |
|---|---|---|---|
| Claude Code | `CLAUDE.md`, holding `@AGENTS.md` | `.claude/skills/` | **yes**, the plugin wires it |
| Cursor | `.cursor/rules/lazyspec.mdc`, `alwaysApply: true` | `.cursor/skills/` | **yes**, the plugin wires it |
| opencode | `AGENTS.md` | `.claude/skills/`, `.agents/skills/` | **yes**, via a `tool.execute.before` plugin you write |
| Codex | `AGENTS.md` | `.agents/skills/` | no |
| Gemini CLI | `GEMINI.md` | no | no |
| Copilot | `.github/copilot-instructions.md` | no | no |
| Windsurf | `.windsurfrules` | no | no |
| Cline, Roo | `.clinerules` | no | no |
| Aider | `CONVENTIONS.md`, `--read CONVENTIONS.md` | no | no |

Without a hook your agent is told rather than stopped, and
`/lazyspec-validate` catches the edit afterwards.

## Using it day to day

Nothing changes until a requirement needs to move.

- **Building something new?** Work normally. Experiment, rewrite, throw
  it away. Requirements are written late on purpose.
- **Behaviour is settled?** Run `/lazyspec`. It writes the requirement,
  unlocks, updates the tests in the same window, runs your suite, locks
  again.
- **Finishing a task?** Run `/lazyspec-validate`.
- **Editing a specification any other way?** The guard refuses you.

## Locking

**A lock is not something you do. It is the resting state.** A file is
locked by *being* a specification — there is no command to lock one, and
no state stored anywhere.

**Unlocking is one file, it names what it opens, and it belongs to one
agent.** `/lazyspec` writes the specification it is about to edit into a
window of its own, makes the change, and deletes it:

```
printf '%s\n' specs/billing.lazyspec.md > .lazyspec-unlock.<your id>
… the edit, and its tests …
rm -f .lazyspec-unlock.<your id>    # always, even on abort
```

- **It names what it opens.** Only calls naming a listed path get
  through, so a window opened for one specification cannot reach its
  neighbour, and one a crashed session left behind leaks that path rather
  than the repository. An empty file opens everything — that is what a
  bare `touch` means.
- **One window per agent.** Any file starting `.lazyspec-unlock` is a
  window. Run agents and subagents in parallel and each gets its own, so
  one finishing never shuts another's, and one opening never widens
  another's.
- **A forgotten window closes itself.** Four hours without being written
  to and it stops counting. Sessions drop, logins expire, laptops sleep —
  none of that should leave a specification writable for good, and no
  human should have to remember to tidy up. Reopen it if you are somehow
  still going.

Nothing here needs maintaining. The window survives context compaction,
because the guard reads the file rather than the agent's memory of it; it
expires on its own if the session dies; and a leftover one is inert
rather than dangerous.

Which is why `.gitignore` matters. Commit `.lazyspec-unlock` once and
every checkout is unlocked forever, with nothing to notice.
`/lazyspec-validate` reports a lock left open, and whether it is
committed.

**Be clear about what this is.** It is a procedural control, not a
permission boundary:

- **Not file permissions, and not encryption.** Nothing on disk changes.
- **Not a defence against people.** You can still open the file in your
  editor.
- **Not proof against a determined agent.** The window is opened by the
  same agent it restrains, and a script that writes a specification
  without naming it is not something a pattern can see.

What it does is turn a silent edit into a deliberate one that leaves
evidence — and that is the whole of the problem, because the failure this
exists to stop is casual, not adversarial.

`lazyspec-guard` is the hook that does the refusing:

- **Refused:** editing tools, and shell commands that redirect, edit in
  place or delete. An agent denied one reaches for the other.
- **Allowed:** reading with `cat`, `grep`, `sed`.
- **Allowed:** writing a file whose *content* merely mentions a
  specification. A tool is judged by the path it writes to, nothing else.
- **Refused:** any shell command running `python`, `node`, `perl` or
  `ruby` near a specification. A script can write anything, and patterns
  cannot tell.

`/lazyspec` is the only thing that opens the window, and it always closes
it. That is the only thing worth defending mechanically.

## Checking

`/lazyspec-validate` asks three things:

- Is every requirement proved?
- Does the test prove it, or only borrow its name?
- Did this change write down what it changed?

It splits on one rule:

> **Finding nothing tells you something. Finding something tells you
> almost nothing.**

- **Settled by searching.** A requirement whose words appear in no file
  is unproved, in every language. One `git grep -F` says so.
- **Settled by reading.** A file *containing* those words may be a test,
  a comment, a README or a mock. Only an agent reading it can tell which,
  or whether the assertions match the bullets.

Want a blocking gate? Three checks need no judgement and are a few lines
of shell:

- a requirement whose words appear nowhere,
- one heading in two specifications,
- a specification that changed while nothing proving it did.

Keep a gate to those three. One that decides which file is a test is
guessing at conventions it cannot see. Run it pre-push, not pre-commit:
requirements are written late, so the commits made while finding the
behaviour should not have to satisfy one.

## What it does not do

- It does not judge whether a test is any good.
- It ships no gate and no CI workflow. Which agent, which credentials and
  what a verdict does to a pull request are yours.
- It is not a permission system. A human with a text editor and
  `--no-verify` is not in scope.

## Uninstall

- Plugin: `/plugin uninstall lazyspec`.
- By hand: delete `lazyspec-guard`, the skills, the hook block.
- Either way: delete `.lazyspec.yaml`, the pasted instruction and the
  `.gitignore` line.

Your specifications stay and their tests keep passing. The marriage was
never enforced by anything but the tests.

---

# Contributing

This repository is the tool, pointed at itself. A specification in here
is changed the way one in yours is, and refused the same way.

```
INSTRUCTION.md              the standing instruction. the product.
skills/lazyspec/            the only way to change a specification
skills/lazyspec-validate/   the check
lazyspec-guard              the one program
specs/                      this repository's own requirements
sandbox/                    a throwaway consumer repo, and 48 scenarios
```

**Tests**

```
node --test specs/*.lazyspec.test.js   # this repository's own requirements
sh sandbox/run.sh                      # 48 scenarios in a throwaway repo
sh sandbox/isolation.sh                # proves the sandbox is sealed off
```

No gate, no build.

**Changing anything here.** Run `/lazyspec`; the guard refuses you
otherwise. Run `/lazyspec-validate` before you finish.

**On Windows**, `.claude/skills/*` are symlinks into `skills/`. Git only
recreates them with `git config --global core.symlinks true` set before
cloning, and that needs Developer Mode or an elevated shell. Otherwise
copy the folder instead: `cp -R skills/. .claude/skills/`. Everything
else here is plain text and `sh`.

**What is specified**, and why only these two:

- `specs/guard.lazyspec.md` — what the hook refuses and lets through.
- `specs/instruction.lazyspec.md` — the shipped writing's budget and
  shape. "Under two thousand characters" is a requirement, not a
  preference: `INSTRUCTION.md` is read on every task forever, and a test
  is the only thing that holds prose to a budget.

The skills and this README are ordinary writing. Change them without
ceremony.

**It is a fair test of the guard.** This README, the instruction and the
tests are full of the words `billing.lazyspec.md`, and all of them stay
writable. If that regresses, this repository stops being editable before
yours does.

## Why a name and not a link

Anything can point at a requirement — a comment, an id, a coverage
report — and all of them survive the requirement changing, which is the
only moment that matters. A name does not. Reword the requirement and
every test carrying the old words is orphaned at once, loudly.

## Prior work

Behaviour-driven development with the specification locked, the binding
made from the requirement's own words, and the timing inverted. Owes Dan
North for BDD, Gojko Adzic for Specification by Example, and Cucumber for
binding specifications to executable steps at all.

## Licence

MIT.
