---
name: lazyspec
description: The only way to change a specification. Keeps a requirement and its test married, in one edit. Use when a requirement needs to be added, reworded or removed.
---

# /lazyspec

**Running this is spec mode.** Outside it every specification is locked,
which is where an agent spends almost all of its time; inside it, and
only inside it, a requirement is written, reworded or removed. Every
specification says so on its first line.

## Steps

0. **If there is no `.lazyspec.yaml`, offer to write one now.** Skip this
   whenever the file exists - `/lazyspec-setup` usually wrote it at
   install time, and this is only the second chance. Read the
   repository, propose it, wait for a yes:

   ```yaml
   sets:
     - root: services/ingest
       specs: specs/*.lazyspec.md
       covers: |
         What a caller observes at the interface: what is accepted,
         what is refused, what comes back. Not internal helpers.

     - root: workers/settlement
       specs: specs/*.lazyspec.md
       covers: |
         What happens for each job, including retries, duplicates and
         ordering. Not the queue library's own behaviour.
   ```

   - `root` is the folder a specification's name must be unique inside,
     because two packages each holding `billing.lazyspec.md` would claim
     the same test file. One project makes that `.`; a monorepo makes it
     one entry per package, service or job.
   - Each set works at whatever level suits it. The promises are
     different kinds of thing, as those two `covers` show.
   - **`covers` is the project's decision, yours to ask about and not to
     assume.** Free text, read by whoever writes the next requirement. It
     is the difference between a set that stays coherent and one that
     silts up with every stray thought anybody had. A team using
     consumer-driven contracts might call a requirement here a consumer
     contract; a team without them might call it whatever a caller can
     observe. Both are right, and only the project knows which.
   - Choose the level where a specification earns its keep: per module,
     at the boundary others depend on, or end to end. One set per
     deployable is common; a single end-to-end set is a fair answer.
   - **No setting for the language, the test runner or where tests live,
     and you are not to add one.** You read all three off the repository,
     and a written-down answer only goes stale.
   - The file is optional - without it every `*.lazyspec.md` counts,
     which is right for a small repository. Do not write one just to have
     it.

1. **Write down the change as requirements**, one line each: what you are
   adding, rewording, removing, and why. If the user did not ask for a
   change in what the software does, stop and ask.

2. **Choose the file.** Read the `covers` of the set it would belong to.
   If what you are about to write is not what that set is for - an
   internal helper where the set covers a boundary others depend on, a
   rendering detail where it covers what the data must satisfy - say so
   and stop. It may belong in another set, at another level, or nowhere.
   A set that quietly widens is a set nobody trusts.

   **Then look for a conflict, before writing anything.** This is the
   cheapest moment there will be: nothing exists yet, so reconciling
   costs a sentence. Once the requirement and its test are written, the
   same conflict costs an argument about which one was right.

   Do not read every specification - in a real repository that is
   hundreds of requirements and you will stop doing it by Thursday. Go
   where an overlap is likely:

   - **The counterpart set.** Most behaviours are described twice, from
     two sides - producer and consumer, writer and reader, scheduler and
     runner. Find the other side. That is where disagreements live.
   - **The same nouns.** Search for the domain words in your heading, not
     the heading: `git grep -il "refund" -- '*.lazyspec.md'`
   - **The same named thing** - a table, a queue, a contract address, a
     file format, a route - if your requirement names one.
   - **Sets whose `covers` mentions your area.**

   Two requirements covering one behaviour from opposite sides are fine
   and often necessary: each is proved by its own test and breaks on its
   own. Two that cannot both be true are not - say so and stop. Never
   write the second and leave somebody else to find they disagree.

   A new requirement joins the specification it belongs to. Start a new
   `*.lazyspec.md` only when none fits. Its filename decides which test
   file proves it, so if a test for this behaviour already exists, name
   the specification after that file. Give a new one a title and a
   sentence saying what it is about: `covers` says what a set is for, the
   file's own opening says what this one is for.

   Every specification opens with this header. Never remove it, and never
   write a specification without it:

   ```markdown
   > **lazyspec.** Humans edit freely. Agents change this only through
   > `/lazyspec`, with its tests, in one edit.
   >
   > Each `##` heading is one requirement. Its test repeats that heading
   > as its own name — to find it, search the tests for that text.
   ```

   It teaches as well as forbids, and it travels inside the file rather
   than in anybody's configuration - which is what makes it reach every
   agent on every tool, including one that never loaded your instruction.

3. **Make the change.**

4. **Marry the tests, in the same edit.** Every heading needs a test
   repeating its words exactly, in one file - so a specification being
   changed never has to guess which tests change with it.

   **Name that file for the specification and for `lazyspec`**, so nobody
   guesses which file proves what and a test outliving its specification
   can be spotted by name alone: `billing.lazyspec.test.ts`,
   `test_billing_lazyspec.py`, `billing_lazyspec_test.go`,
   `BillingLazyspecTest.java`. Spell `lazyspec` however the language
   spells a name, never as a literal `.lazyspec.` - Java cannot put a dot
   in a class name, pytest fails to import it, `unittest` skips the file
   in silence.

   Fit that to how this repository already names and runs its tests. The
   file has to be one the runner picks up, and the words can sit wherever
   the language puts a test's name: a string, a docstring, an annotation,
   a comment. Do not invent a runner, a layout or a naming style the
   repository does not already use.

   Reword a heading and you reword its test. If a test fails, fix the
   code - never the requirement.

5. **Check your work.** Every heading has its test, and the repository's
   own test command passes. Find that command; do not guess it. If you
   renamed or deleted a specification, its test file follows - same name,
   same moment. A test file naming `lazyspec` left behind with no
   specification is an orphan that still passes, proving a requirement
   nobody has any more.

6. **Report**, and say plainly that you changed a specification: which
   headings you touched, which tests now prove them, what the test run
   did. Nothing enforces this but you, which is why saying it matters.

## What does not become a requirement

Most of a test suite marries nothing, and that is the design.
Requirements sit at the level `covers` declares - often acceptance,
contract or end to end. Everything below that keeps working as it did.

- **Unit tests, integration tests, database tests, fixtures, property
  tests, benchmarks.** No requirement, no heading, no marriage. Write,
  change and delete them freely.
- **Never write a requirement to justify a test that already exists.**
  That is the tail wagging the dog: it fills the set with implementation
  detail and makes the specification a second, worse copy of the suite.
- **A specification does not replace those tests.** A requirement says
  what the software promises; a unit test says a function works. Both
  worth having, only one a promise to anybody outside the code.
- **Other test files may share a specification's name.** `billing.md` is
  married to whichever file repeats its headings; `billing.unit.test.ts`
  beside it is ordinary and unrelated.
- **`lazyspec` in a test file's name is a claim, so only the married file
  makes it.** Its neighbours do not, however closely related. A file
  claiming it with no specification beside it is an orphan.

If a requirement only makes sense to somebody reading the
implementation, it is a unit test wearing a heading. Delete the heading
and keep the test.

## Writing a requirement

- One `## ` heading is one requirement, and its words are its name.
- **`##` is reserved.** Never use it to group or number sections -
  `## 3. API Endpoints`, `## Failure Modes`. Every one becomes a
  requirement nothing can prove, and a real specification accumulates
  dozens. Use `#` for the title, `###` or deeper inside a requirement.
- A heading naming a topic rather than making a claim is a section in a
  requirement's clothes. `## Retention` is a topic; `## Records Are Kept
  For Seven Years` is a requirement.
- Say what the software does now. Never what it used to do, never what
  changed, never the date.
- One claim per bullet. No reasoning, no preamble, no restating the
  heading.
- If it cannot be tested, write `## Its Name <!-- no-test: why not -->`.
- Split a specification while it is still short enough to read at a
  glance. Nobody should read the whole set to find one thing.

Every word here is read again by every agent, on every task, for as long
as the file exists. It is the most expensive writing in the repository.
Write less.

## Rules

- Never change a specification in the same breath as unrelated work.
- Never change one without saying you did.
