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

0. **If there is no `lazyspec.md`, offer to write one now.** Skip this
   whenever it exists - `/lazyspec-setup` usually wrote it at install
   time, and this is only the second chance. Read the repository,
   propose it, wait for a yes:

   ```markdown
   # Where our requirements live

   - **services/ingest** — `specs/*.lazyspec.md`. What a caller observes
     at the interface: what is accepted, what is refused, what comes
     back. Not internal helpers.

   - **workers/settlement** — `specs/*.lazyspec.md`. What happens for
     each job, including retries, duplicates and ordering. Not the queue
     library's own behaviour.
   ```

   - One bullet per area whose specification names have to be unique -
     two packages each holding `billing.lazyspec.md` would claim the same
     test file. One project is one bullet. A monorepo is one per package,
     service or job.
   - **The sentence after the path is the point, and it is the project's
     decision - yours to ask about, not to assume.** It is read by
     whoever writes the next requirement, and it is the difference
     between an area that stays coherent and one that silts up with every
     stray thought. A team using consumer-driven contracts might call a
     requirement here a consumer contract; a team without them might call
     it whatever a caller can observe. Both are right, and only the
     project knows which. Keep it to a sentence or two, and say what it
     excludes.
   - Choose the level where a specification earns its keep: per module,
     at the boundary others depend on, or end to end. One area per
     deployable is common; a single end-to-end one is a fair answer.
   - Name the glob only where it is not `*.lazyspec.md` already.
   - **No setting for the language, the test runner or where tests live,
     and you are not to add one.** You read all three off the repository,
     and a written-down answer only goes stale.
   - **Never use `## ` in this file.** That mark means a requirement
     everywhere else. Title, then bullets.
   - The file is optional - without it every `*.lazyspec.md` counts,
     which is right for a small repository. Do not write one just to have
     it.

1. **Write down the change as requirements**, one line each: what you are
   adding, rewording, removing, and why. If the user did not ask for a
   change in what the software does, stop and ask.

2. **Choose the file.** Read what `lazyspec.md` says the area it would
   belong to is for. If what you are about to write is not that - an
   internal helper where the area covers a boundary others depend on, a
   rendering detail where it covers what the data must satisfy - say so
   and stop. It may belong in another area, at another level, or nowhere.
   An area that quietly widens is one nobody trusts.

   **Then look for a conflict, before writing anything.** This is the
   cheapest moment there will be: nothing exists yet, so reconciling
   costs a sentence. Once both are written, the same conflict costs an
   argument about which was right.

   Do not read every specification. Go where an overlap is likely:

   - **The counterpart area.** Most behaviours are described twice, from
     two sides - producer and consumer, writer and reader, scheduler and
     runner. Find the other side. That is where disagreements live.
   - **The same nouns.** Search for the domain words in your heading, not
     the heading: `git grep -il "refund" -- '*.lazyspec.md'`
   - **The same named thing** - a table, a queue, a contract address, a
     file format, a route - if your requirement names one.
   - **Areas whose description in `lazyspec.md` mentions yours.**

   Two requirements covering one behaviour from opposite sides are fine
   and often necessary: each is proved by its own test and breaks on its
   own. Two that cannot both be true are not - say so and stop.

   A new requirement joins the specification it belongs to. Start a new
   `*.lazyspec.md` only when none fits, and its filename decides which
   test file proves it.

   **Where a test already covers the behaviour, still write the married
   file under the convention.** Do not adopt the existing one. Names in
   an ordinary suite were not written to be requirements - they describe
   what a case does, not what the software promises - and one that reads
   well today gets reworded tomorrow by somebody who has no idea it is
   load-bearing. A marriage to a name nobody knew was a name is the
   drift this exists to prevent, arranged on purpose.

   The old test stays exactly where it is and marries nothing, like most
   of the suite. Moving its assertions across is optional, and an easy
   job to hand an agent if you want it done. Give a new one a title and a
   sentence saying what it is about: `lazyspec.md` says what an area is
   for, the file's own opening says what this one is for.

   Every specification opens with this header. Never remove it, and never
   write a specification without it:

   ```markdown
   > **lazyspec.** Humans edit freely. Agents change this only through
   > `/lazyspec`, with its tests, in one edit.
   >
   > Each `##` heading is one requirement. Its test repeats that heading
   > as its own name — to find it, search the tests for that text.
   ```

3. **Make the change.**

4. **Marry the tests, in the same edit.** Every heading needs a test
   repeating its words exactly, in one file - so a specification being
   changed never has to guess which tests change with it.

   **Name that file for the specification and for `lazyspec`**, so nobody
   guesses which file proves what and a test outliving its specification
   can be spotted by name alone: `billing.lazyspec.test.ts`,
   `test_billing_lazyspec.py`, `billing_lazyspec_test.go`,
   `BillingLazyspecTest.java`. Join the words however the
   language joins them, and never require a dot: Java cannot put one in
   a class name, pytest fails to import it, `unittest` skips the file in
   silence.

   Fit that to how this repository already names and runs its tests. The
   words can sit wherever the language puts a test's name: a string, a
   docstring, an annotation, a comment. Do not invent a runner, a layout
   or a naming style the repository does not already use.

   **The file has to be one the runner actually collects, and that is
   worth checking rather than assuming.** A repository whose command is
   `node --test tests/*.test.js` will never see a married file written
   into `specs/`: the suite passes, the test never ran, and the marriage
   proves nothing. Put it where the runner already looks - the two files
   do not have to sit together, the name is what marries them - or say
   the glob has to widen and let them decide.

   **Splitting moves both halves.** Take the headings out of the old
   specification and the blocks proving them out of the old test file,
   into a new pair named for the new stem. Leave nothing behind: a
   heading proved from two files is `proved elsewhere`, and a block whose
   heading has gone is `left behind`. Both are findings the check will
   raise against you for having followed this rule carelessly.

   Reword a heading and you reword its test. Remove one and you remove
   its test in the same edit: a test whose requirement is gone still
   passes, and nothing downstream can tell it apart from a real one. If
   a test fails, fix the code - never the requirement.

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
Requirements sit at the level `lazyspec.md` declares - often acceptance,
contract or end to end. Everything below that keeps working as it did.

- **Unit tests, integration tests, database tests, fixtures, property
  tests, benchmarks.** No requirement, no heading, no marriage. Write,
  change and delete them freely.
- **Never write a requirement to justify a test that already exists.**
  It fills the area with implementation detail and makes the
  specification a second, worse copy of the suite.
- **A specification does not replace those tests.** A requirement says
  what the software promises; a unit test says a function works. Both
  worth having, only one a promise to anybody outside the code.
- **Other test files may share a specification's name.**
  `billing.lazyspec.md` is
  married to whichever file repeats its headings; `billing.unit.test.ts`
  beside it is ordinary and unrelated.
- **`lazyspec` in a test file's name is a claim, so only the married file
  makes it.** Its neighbours do not, however closely related. A file
  claiming it with no such specification is an orphan.

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
  glance. Nobody should read a whole file to find one thing.

Every word here is read again by every agent that opens the file. Write
less.

## Rules

- Never change a specification in the same breath as unrelated work.
- Never change one without saying you did.
