# lazyspec

Write each requirement the moment it is known — and you will know them
one at a time, as the build goes.

Not up front, where you would be guessing. Rare cases as all at the end, but mostly as you build.  A specification accretes: something settles, you
write it down, it stops moving.

Specs are outcomes of your discussion with the LLM. your existing workflows for analysis and research should guide this (or eg: superpowers:brainstorm).

Each spec works twice. 
- Written, it is the **input** — hand it to the agent as the thing to satisfy. 
- Kept, it is a **harness** — the thing already
settled cannot drift without somebody deciding it should.

Nothing else about how you work changes. There is no workflow here to
adopt: plan how you already plan, and lazyspec only ensures the
requirement is written when it is known, and changed safely after.

## In short

- A requirement is a `## ` heading in a `*.lazyspec.md` file. Its text is
  its identifier.
- Its test declares itself by that text, word for word, in the file
  sharing the specification's stem.
- `billing.lazyspec.md` is married by the one test file naming both
  `billing` and `lazyspec`, spelled however your language spells names —
  `billing.lazyspec.test.ts`, `test_billing_lazyspec.py`,
  `billing_lazyspec_test.go`, `BillingLazyspecTest.java`. The name
  marries them, so either file can live anywhere.
- Reword the requirement and its test is orphaned at once, loudly.
- Write each requirement once it is known, which is usually partway
  through the build rather than at either end. Then keep it still.
- A specification is locked unless you are in `/lazyspec`. That is a mode
  the agent is in or is not, and it is almost never in it.
- Nothing to run: no program, no gate, no build.
- Nothing to change about how you work. Keep your planning, your tickets,
  your branching, your tests.

## Why not one of the others

Most spec-driven tooling aims at the hour you start something: specify,
plan, tasks, code. That is the build phase, and it is the easy half.
Everyone is paying attention and the specification is fresh, because it
was written twenty minutes ago.

The hard half is the eighteen months afterwards, when an agent changes
the code and nothing tells anybody the specification stopped being true.

| | spec-first tools | lazyspec |
|---|---|---|
| when you write it | before the code | once the behaviour is known |
| what it optimises | generating the first version | noticing the hundredth has drifted |
| drift detection | none. the specification is an input, never checked again | a reworded requirement orphans its test immediately |
| being wrong early | a specification written before anyone understood the problem, then quietly abandoned | costs nothing, you had not written it yet |
| what it produces | plans, tasks, sometimes code | nothing. it only checks |
| how you work | its workflow: specify, plan, tasks, implement | unchanged. it has no workflow |

**It does not replace how you work.** Spec-kit and its like come with a
method: specify, then plan, then tasks, then implement, in that order,
through their commands. Adopt one and you have adopted a process.

lazyspec has no process to adopt. Plan however you already plan — a
ticket, a design doc, a conversation, a whiteboard, nothing at all. Use
your branching model, your test runner, your review habits. Two things
are added and nothing is taken away:

- a requirement gets written down **at the moment it becomes known**, and
- there is one **safe way to change it** afterwards.

Behaviour-driven development got the binding right and paid for it in
glue nobody wanted to maintain. Spec-first agent tools got the generation
right and stopped checking the specification the moment it produced code.

This takes the binding, drops the glue, and writes each requirement when
it is known. It does less than any of them, and it keeps working longer.

## Why

Sound familiar?

- The agent changed a test instead of fixing the code, and the suite went
  green.
- A requirement was quietly reworded to match what was built.
- Your specification describes the implementation, so it says nothing.
- Spec-driven development felt like writing fiction, because nobody knew
  the behaviour yet.

Two failures, opposite directions:

- **Specify everything first and you spend the LLM's best trait before
  you have anything.** Agents are good at trying things: build it, run
  it, throw it away. Behaviour written down before anyone understands it
  is wrong by Thursday.
- **Leave it to the agent and it rewrites requirements to match its
  code.** It edits requirements as readily as tests. The suite stays
  green. Nothing raises a hand. The specification now describes the
  implementation, which means it describes nothing.

The way out is neither end of that. **Write each requirement when it is
known, and most become known while you build.** Some are settled before a
line of code — you had the conversation, the shape was obvious. Most
firm up three commits in. A few never do, and never get written.

So:

- **Write it when it is known**, one requirement at a time.
- **Marry it to a test by name**, so a requirement and its proof cannot
  drift apart quietly.
- **Keep it**: say so in the file, say so in the standing rules your
  agents load, and check it afterwards. Three places, one rule, so no
  agent rewords a requirement to make its path work.

And then the payoff, which is the point of the rest: **people read the
specification instead of the logic.** That is where the promise lives, so
that is where attention belongs — and it stays worth reading, because a
requirement cannot quietly become a description of whatever was built.
Ordinary code review still applies, for everything it is actually for.

## What you write

A specification is markdown. Each `## ` heading is one requirement.

```markdown
> **lazyspec.** Humans edit freely. Agents change this only through
> `/lazyspec`, with its tests, in one edit.
>
> Each `##` heading is one requirement. Its test repeats that heading as
> its own name — to find it, search the tests for that text.

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

Nothing about that is JavaScript. The words go wherever your language
puts a test's name, and the file goes wherever your runner already looks:

```py
# test_refunds_lazyspec.py
def test_beyond_captured():
    """Refunds Never Exceed What Was Captured"""
```

```go
// refunds_lazyspec_test.go
t.Run("Refunds Never Exceed What Was Captured", func(t *testing.T) { ... })
```

```java
// RefundsLazyspecTest.java
@DisplayName("Refunds Never Exceed What Was Captured")
```

`sh sandbox/run.sh` builds a whole repository like this — in those four
languages — and checks every claim on this page against it.

### The header does the work

Those five lines at the top are not decoration. They are the only part of
lazyspec that reaches **every** agent, because they travel in the file
rather than in anybody's configuration.

- **Nothing to install.** Copy a specification into a new repository and
  the rule arrives with it.
- **Read at the moment it matters.** An agent about to change a file has
  just read it, so the rule lands while it is deciding — not at session
  start, hundreds of messages earlier.
- **It teaches, not just forbids.** An agent that never loaded your
  instruction still learns from the file what a requirement is and how to
  find the test that proves it. "Do not edit" would leave it stuck.
- **It binds agents, not people.** Edit your own requirements by hand
  whenever you like.

`/lazyspec` writes it into every specification it creates, and
`/lazyspec-validate` reports any specification missing one.

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
| `billing.lazyspec.md` | `test_billing_lazyspec.py` | a docstring |
| `billing.lazyspec.md` | `billing_lazyspec_test.go` | `t.Run("…")` |
| `billing.lazyspec.md` | `BillingLazyspecTest.java` | `@DisplayName("…")` |

Both halves of that name are load-bearing. `billing` says which
specification it proves; `lazyspec` says it proves one at all. Neither is
a guess anybody has to make.

- A requirement's text is its only identifier.
- Nothing here configures a language, a runner or a test folder. The
  agent reads all three off your repository.
- **Spell `lazyspec` the way the language allows, never as a literal
  `.lazyspec.`.** A dot is fine in a path and illegal in a name: Java
  cannot put one in a class name, and `test_billing.lazyspec.py` makes
  pytest fail to import and `unittest` skip the file without a word. The
  token survives every ecosystem; the punctuation does not.
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

## What it does not replace

A married test is one kind of test among many. Most of your suite marries
nothing, and that is the design.

| | married to a requirement? |
|---|---|
| acceptance, end-to-end, contract tests | usually — this is the level requirements live at |
| unit tests | no |
| integration and database tests | no |
| fixtures, property tests, benchmarks | no |

Requirements sit at whatever level `covers` declares. Everything below
that keeps working exactly as it did: write it, change it, delete it,
without touching a specification.

- **The check runs from requirements to tests.** An ordinary test with no
  requirement is not a finding, and never will be.
- **Except for a test that named itself one.** A test file carrying
  `lazyspec` with no matching specification is an orphan: the
  specification was deleted or renamed and its test was left behind,
  still passing, proving a requirement nobody has. The name made a claim,
  so the name can be checked — and because the token fits every naming
  scheme, that check works in Java and Python as well as it does here.
- **Never write a requirement to justify a test you already have.** That
  is the tail wagging the dog: the set fills with implementation detail
  and the specification becomes a second, worse copy of the suite.
- **A requirement is a promise; a unit test is a check.** A requirement
  says what the software promises somebody outside the code. A unit test
  says a function works. Both worth having, only one worth locking.
- **Other test files may share a specification's name.**
  `billing.lazyspec.md` is married to whichever file repeats its
  headings; `billing.unit.test.ts` beside it is ordinary and unrelated.

If a requirement only makes sense to somebody reading the
implementation, it is a unit test wearing a heading.

## What a specification is about

Two questions, two homes. Both are the project's to answer, and lazyspec
answers neither for you.

**What is this set for?** `covers` in `.lazyspec.yaml`, free text, read
by whoever writes the next requirement:

```yaml
sets:
  - root: services/ingest
    specs: specs/*.lazyspec.md
    covers: |
      What a caller observes at the boundary: what is accepted, what
      is refused, what comes back. Not internal helpers.

  - root: pipelines/nightly
    specs: specs/*.lazyspec.md
    covers: |
      What must hold of the data after a run, and what happens when a
      run fails halfway. Not the shape of any one query.

  - root: workers/settlement
    specs: specs/*.lazyspec.md
    covers: |
      What happens for each job, including retries, duplicates and
      ordering. Not the queue library's own behaviour.
```

These are different kinds of promise, so two sets rarely say the same
thing here. A team using consumer contracts might say a requirement is
one of those; a team without them might say it is whatever a caller can
observe. Both are right, and only the project knows which. A scanner, an
on-chain contract, a scheduled job and a library each want their own
answer, and none of them is the answer in this example.

**What is this file about?** The specification's own title and opening
sentence, the way any document says what it is:

```markdown
# Refunds

How money goes back to a customer. Not how it arrives.
```

### Two sets may cover the same ground

Most behaviours are described twice, from two sides. Whoever produces and
whoever consumes. Whoever schedules and whoever runs. One set says a
value is refused at the boundary; another says the caller never sends it
in the first place. That is one rule from two angles, and both are worth
writing: each is proved by a different test, and each breaks on its own.

What must not happen is the two drifting apart — two different limits,
two different messages, one side optional and the other required.

**That is caught when the requirement is written, not later.** `/lazyspec`
looks for a conflict before adding anything, which is the cheapest moment
there will ever be: nothing exists yet, so reconciling costs a sentence.
Afterwards the same conflict costs an argument about which one was right.

It does not read every specification — a real repository has hundreds of
requirements and nobody sustains that. It goes where an overlap is
likely: the counterpart set, the same domain nouns, the same named thing
— a table, a queue, a contract address, a file format.
`/lazyspec-validate` is only the backstop, and checks narrowly.

Watch the seam where one side was specified long before the other. A
behaviour written into whichever specification existed at the time,
because there was nowhere else to put it, gets restated once the set that
owns it exists — and the copy left behind is the one that goes stale.

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
  it away. A requirement is written when it settles, not before.
- **Behaviour is settled?** Run `/lazyspec`. It writes the requirement,
  updates its test in the same edit, and runs your suite.
- **Finishing a task?** Run `/lazyspec-validate`.
- **Editing a specification any other way?** It is locked: you are not in
  spec mode, so it is not yours to touch. `/lazyspec-validate` finds it
  if you do.

### Work in bigger pieces

Story-sized slices exist because a person can hold only so much at once.
An agent has the opposite problem: attention to spare, context to lack.

Give it a whole capability and it sees the shape — the edge cases, the
interactions, the requirement nobody thought to ask for. It is also when
the conversation about the specification is worth having, because there
is finally something to disagree about.

Cut the same work into fragments and each gets designed alone. The
specification comes out fragmented too, because that is how it was
written.

## Locking

A specification is locked. Not by file permissions, not by a hook — by
the agent knowing it is **not in spec mode**.

- **Outside `/lazyspec`**, every specification is read-only. That is the
  default, and where an agent spends essentially all of its time.
- **`/lazyspec` is spec mode.** The one place a requirement is written,
  reworded or removed, always with its test in the same edit.
- **Three things say so**: the notice on the file's first line, the
  standing rules your agents load every task, and `/lazyspec-validate`
  afterwards.

That is the whole of it, and it is enough because the failure it prevents
is casual rather than adversarial. An agent does not set out to rewrite
your requirements; it reaches for the nearest thing that makes a test
pass. Locked means it knows the specification is not that thing.

People are not locked out of anything. Edit your own requirements in your
own editor whenever you like.

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

Want a blocking gate? Four checks need no judgement and are a few lines
of shell:

- a requirement whose words appear nowhere,
- one heading in two specifications,
- a specification that changed while nothing proving it did,
- a test file carrying `lazyspec` whose specification is gone.

The last is the one a green build hides, so a reviewing agent should
raise it every time: the deletion and the leftover sit in different
files, often different commits, and the suite passes either way.

Keep a gate to those four. One that decides which file is a test is
guessing at conventions it cannot see. Run it pre-push, not pre-commit:
a requirement is written when it settles, so the commits made while
finding that out should not have to satisfy one.

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
