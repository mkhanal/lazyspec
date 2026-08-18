# lazyspec

Let the agent experiment. Write the requirement once you know. Then make
it the one file your agents do not rewrite in passing.

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
- **Lock** the specification: say so in the file, say so in the standing
  rules your agents load, and check it afterwards. Three places, one
  rule, so no agent rewords a requirement to match its code.

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

## What a specification is about

Two questions, two homes. Both are the project's to answer, and lazyspec
answers neither for you.

**What is this set for?** `covers` in `.lazyspec.yaml`, free text, read
by whoever writes the next requirement:

```yaml
sets:
  - root: services/api
    specs: specs/*.lazyspec.md
    covers: |
      The HTTP contract. One requirement per behaviour a caller can
      observe: status codes, error shapes, idempotency, ordering.
      Not internal helpers.

  - root: apps/web
    specs: specs/*.lazyspec.md
    covers: |
      What a person can see and do in the browser. One requirement per
      user-visible rule, proved end to end. Not component internals.
```

A browser and a wire contract are not the same kind of promise, so a
frontend set and a backend set will rarely say the same thing here. A
team using consumer-driven contracts might say a requirement is a pact; a
team without them might say it is an endpoint's observable behaviour.
Both are right, and only the project knows which.

**What is this file about?** The specification's own title and opening
sentence, the way any document says what it is:

```markdown
# Refunds

How money goes back to a customer. Not how it arrives.
```

`covers` keeps a set from quietly widening until nobody can say what
belongs in it. `/lazyspec` reads it before adding a requirement and stops
if the requirement is the wrong kind; `/lazyspec-validate` reports one
that slipped in below the declared level.

**`/lazyspec-setup` drafts the whole file for you.** It reads the
repository — package manifests, workspace globs, service folders — works
out the boundaries, proposes a `covers` for each, marks what it inferred,
and asks only what the repository cannot answer. The level a set works at
is usually the one real question, and it asks that one with its best
guess already in it.

Writing down where specifications will live is not specifying. The shape
of a repository is knowable on day one; what its code does is not, which
is why one is settled at install and the other waits.

## Install

**The instruction is the install.** Paste `INSTRUCTION.md` where your
agent reads it every task and you are done. That works on every agent.

**Claude Code and Cursor** take the skills as a plugin:

```
/plugin marketplace add mkhanal/lazyspec
/plugin install lazyspec@lazyspec
```

**Anything else** is a clone and a copy:

```
git clone --depth 1 https://github.com/mkhanal/lazyspec /tmp/lazyspec
mkdir -p .claude/skills .agents/skills
cp -R /tmp/lazyspec/skills/. .claude/skills/
cp -R /tmp/lazyspec/skills/. .agents/skills/
```

Two directories cover four agents: `.claude/skills/` for Claude Code and
opencode, `.agents/skills/` for Codex and opencode.

**Or hand it over:** *"Read
`https://github.com/mkhanal/lazyspec/blob/main/README.md` and install
it."*

### Then the one thing that matters

**Run `/lazyspec-setup`.** It reads your repository, proposes where the
instruction should go, waits for you to agree, and pastes it.

It asks first on purpose. Writing into a team's standing rules unasked is
precisely what lazyspec exists to stop an agent doing, and a tool that
did it in order to install itself would not deserve the benefit of the
doubt.

By hand it is the same two minutes: **put `INSTRUCTION.md` into the
standing rules your agents already load.** If you keep a
`CONSTITUTION.md`, engineering principles, or house rules, that is the
right home — paste it there and point `AGENTS.md` at it. If you keep
nothing of the kind, `AGENTS.md` is the default.

```
<!-- lazyspec:begin -->
… the body of INSTRUCTION.md …
<!-- lazyspec:end -->
```

This is the step that makes the tool work, and no installer can do it.
Everything else here is copying files around.

- **Paste it, do not link to it.** An instruction fetched on request is
  one that will not be followed. It has to arrive in context before the
  agent starts, every task, without being asked for.
- **Claude Code never looks for `AGENTS.md`.** A repository with only an
  `AGENTS.md` looks set up and is not. One line, `@AGENTS.md`, fixes it.
- **Every other editor gets a short file pointing at `AGENTS.md`**, never
  a second copy — see the table below.
- **A plugin cannot do this.** Plugins carry skills, not files in your
  repository.

Put it beside your existing rules rather than in a file of its own. An
agent that already respects your constitution will respect one more line
in it; a rule filed somewhere separate is a rule competing for attention.

### Check it worked

In a fresh session:

- `/lazyspec`, `/lazyspec-setup` and `/lazyspec-validate` appear in its
  skill list.
- Ask *"where do this repository's requirements live?"* It answers at
  once. If it starts searching, your instruction is not loaded and
  nothing else here matters.
- Ask for a behaviour change. It reaches for `/lazyspec`.

## The three skills

| skill | when it runs |
|---|---|
| `/lazyspec-setup` | once, after installing: the instruction, and where specs live |
| `/lazyspec` | the only way to add, reword or remove a requirement |
| `/lazyspec-validate` | before you finish, and on a pull request |

`/lazyspec-setup` is not an installer — it runs *after* you have the
skills and does the one thing a plugin cannot, which is write a file into
your repository. Getting the skills is the two commands above.

`INSTRUCTION.md` ships beside the skills, so once the plugin is installed
the text is already on your machine and `/lazyspec-setup` knows where to
find it.

## Agent support

The notice reaches every agent, because it is in the file. The
instruction reaches every agent, because you paste it. Skills reach four.

| agent | instruction file | skills |
|---|---|---|
| Claude Code | `CLAUDE.md`, holding `@AGENTS.md` | `.claude/skills/` |
| Cursor | `.cursor/rules/lazyspec.mdc`, `alwaysApply: true` | `.cursor/skills/` |
| opencode | `AGENTS.md` | `.claude/skills/`, `.agents/skills/` |
| Codex | `AGENTS.md` | `.agents/skills/` |
| Gemini CLI | `GEMINI.md` | no |
| Copilot | `.github/copilot-instructions.md` | no |
| Windsurf | `.windsurfrules` | no |
| Cline, Roo | `.clinerules` | no |
| Aider | `CONVENTIONS.md`, `--read CONVENTIONS.md` | no |

Where the skills do not reach, `/lazyspec` and `/lazyspec-validate` are
still two documents you can point an agent at by path.

## Why there is no hook

There was one: a pre-tool hook that refused writes to a specification. It
is gone, and the reason is worth stating.

**No mechanism guarantees what an agent does.** A hook is a tool call
away from being disabled, worked around with a script, or simply
prompted past. That is true of every guardrail anyone ships for an LLM,
and it was true of this one: the agent it restrained could write its own
unlock file whenever it liked.

Given that the ceiling is the same either way, the hook was paying for
nothing:

- It ran on **three agents out of nine**. On the rest a repository could
  carry the whole apparatus and be defended by nothing.
- It was **tested on one**. Cursor's payload shape came from
  documentation, never from a running Cursor; opencode needed a shim
  nobody had written.
- It **refused honest work**. Matching patterns rather than parsing, it
  blocked a README that quoted a requirement, a commit message that named
  one, a script whose argument happened to be a specification. Building
  lazyspec, it refused legitimate work six times in one session.

So it cost friction on every agent, worked on one, and moved the ceiling
nowhere. Worse, it *looked* like protection — and a false indicator is
worse than none, because people build habits on it.

What actually changes an agent's behaviour is the rule being unavoidable
and repeated: in the file it is about to edit, in the standing rules it
loads every task, and in the check that reads the diff afterwards. That
is the honest maximum, and it is what is left.

## Using it day to day

Nothing changes until a requirement needs to move.

- **Building something new?** Work normally. Experiment, rewrite, throw
  it away. Requirements are written late on purpose.
- **Behaviour is settled?** Run `/lazyspec`. It writes the requirement,
  unlocks, updates the tests in the same window, runs your suite, locks
  again.
- **Finishing a task?** Run `/lazyspec-validate`.
- **Editing a specification any other way?** The notice on its first line
  says not to, and `/lazyspec-validate` will find it if you do.

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
- By hand: delete the skills.
- Either way: delete `.lazyspec.yaml` and the pasted instruction.

Your specifications stay and their tests keep passing. The marriage was
never enforced by anything but the tests.

---

# Contributing

This repository is the tool, pointed at itself. A specification in here
is changed the way one in yours is.

```
INSTRUCTION.md              the standing instruction. the product.
skills/lazyspec-setup/      puts that instruction where agents read it
skills/lazyspec/            the only way to change a specification
skills/lazyspec-validate/   the check
specs/                      this repository's own requirements
sandbox/                    a throwaway consumer repo, and its scenarios
```

**Tests**

```
node --test specs/*.lazyspec.test.js   # this repository's own requirements
sh sandbox/run.sh                      # 48 scenarios in a throwaway repo
sh sandbox/isolation.sh                # proves the sandbox is sealed off
```

No gate, no build.

**Changing anything here.** Run `/lazyspec`. Run `/lazyspec-validate`
before you finish.

**On Windows**, `.claude/skills/*` are symlinks into `skills/`. Git only
recreates them with `git config --global core.symlinks true` set before
cloning, and that needs Developer Mode or an elevated shell. Otherwise
copy the folder instead: `cp -R skills/. .claude/skills/`. Everything
else here is plain text and `sh`.

**What is specified**, and why only these two:

- `specs/format.lazyspec.md` — that every specification carries its
  notice. It is the one thing that reaches every agent, so it is the one
  thing worth a test.
- `specs/instruction.lazyspec.md` — the shipped writing's budget and
  shape. "Under two thousand characters" is a requirement, not a
  preference: `INSTRUCTION.md` is read on every task forever, and a test
  is the only thing that holds prose to a budget.

The skills and this README are ordinary writing. Change them without
ceremony.

**Nothing here is a program.** There is no build, no gate, and nothing to
install to work on it — which is the same claim the tool makes about
itself, so it had better stay true.

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
