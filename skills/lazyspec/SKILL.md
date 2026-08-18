---
name: lazyspec
description: The only way to change a specification. Keeps a requirement and its test married, in one edit. Use when a requirement needs to be added, reworded or removed.
---

# /lazyspec

**Running this is spec mode.** Outside it every specification is locked,
which is where an agent spends almost all of its time; inside it, and
only inside it, a requirement is written, reworded or removed. Every
specification says so on its first line.

These are the steps.

## Steps

0. **If there is no `.lazyspec.yaml`, offer to write one now.** Skip this
   whenever the file exists - `/lazyspec-setup` usually wrote it at
   install time, and this is only the second chance.

   Read the repository, then propose it and wait for a yes:

   ```yaml
   sets:
     - root: .
       specs: specs/*.lazyspec.md
       covers: |
         What one requirement here describes, and at what level.
   ```

   `root` is the folder a specification's name has to be unique inside,
   because two packages each holding `billing.lazyspec.md` would both
   claim the same test file. In one project that is `.`. In a monorepo it
   is each package, service or job, so there is one entry per boundary -
   and each works at whatever level suits it, because the promises are
   different kinds of thing:

   ```yaml
   sets:
     - root: services/ingest
       specs: specs/*.lazyspec.md
       covers: |
         What a caller observes at the interface: what is accepted,
         what is refused, what comes back. Not internal helpers.

     - root: pipelines/nightly
       specs: specs/*.lazyspec.md
       covers: |
         What must hold of the data after a run, and what happens to a
         run that fails halfway. Not the shape of any one query.

     - root: workers/settlement
       specs: specs/*.lazyspec.md
       covers: |
         What happens for each job, including retries, duplicates and
         ordering. Not the queue library's own behaviour.
   ```

   **`covers` is the project's decision and yours to ask about, not to
   assume.** It is free text, read by whoever writes the next
   requirement, and it is the difference between a set that stays
   coherent and one that silts up with every stray thought anybody had. A team using consumer-driven contracts might say a
   requirement here is a consumer contract; a team without them might say
   it is whatever a caller can observe. Both are right; only the project
   knows which.

   Choose the level where a specification earns its keep here: per
   module, at the boundary others depend on, or end to end. One set per
   deployable is common, and a single end-to-end set is a fair answer.

   There is no setting for the language, the test runner or where tests
   live, and you are not to add one. You read all three off the
   repository, and a written-down answer only goes stale.

   The file is optional. Without it every `*.lazyspec.md` counts, which
   is right for a small repository. Do not write one just to have it.

1. **Write down the change as requirements**, one line each: what you are
   adding, what you are rewording, what you are removing, and why. If the
   user did not ask for a change in what the software does, stop and ask.

2. **Choose the file.** First read the `covers` of the set it would
   belong to. If what you are about to write is not what that set is for
   — an internal helper where the set covers a boundary others depend on,
   a rendering detail where it covers what the data must satisfy — say so and stop. The
   requirement may belong in another set, at another level, or nowhere.
   A set that quietly widens is a set nobody trusts.

   **Then look for a conflict, before you write anything.** This is the
   cheapest moment there will ever be: nothing exists yet, so reconciling
   costs a sentence. After the requirement and its test are written, the
   same conflict costs an argument about which one was right.

   Do not read every specification — in a real repository that is
   hundreds of requirements and you will stop doing it by Thursday. Go
   where an overlap is likely:

   - **The counterpart set.** Most behaviours are described twice, from
     two sides - whoever produces and whoever consumes, whoever writes
     and whoever reads, whoever schedules and whoever runs. Find the
     other side and read it. That is where disagreements live.
   - **The same nouns.** Search the specifications for the domain words
     in your heading, not the heading itself:
     `git grep -il "refund" -- '*.lazyspec.md'`
   - **The same named thing** - a table, a queue, a contract address, a
     file format, a route - if your requirement names one.
   - **Sets whose `covers` mentions your area**, which is what `covers`
     is there for.

   Two requirements covering one behaviour from opposite sides are fine
   and often necessary — each is proved by its own test and breaks on its
   own. Two that cannot both be true are not. Found one? Say so and stop.
   Do not write the second and leave somebody else to discover they
   disagree.

   Then: a new requirement joins the specification it belongs to. Only
   start a new `*.lazyspec.md` when none of them fits. Its filename
   decides which test file proves it, so if a test for this behaviour
   already exists, name the specification after that file.

   Give a new specification a title and a sentence saying what it is
   about, the way the others do. `covers` says what a set is for; the
   file's own opening says what this one is for.

   Every specification opens with a header. Copy the one the others use;
   if you are writing the first, it reads:

   ```markdown
   > **lazyspec.** Humans edit freely. Agents change this only through
   > `/lazyspec`, with its tests, in one edit.
   >
   > Each `##` heading is one requirement. Its test repeats that heading
   > as its own name — to find it, search the tests for that text.
   ```

   It teaches as well as forbids, which is the point: an agent that never
   loaded your instruction still learns from the file what a requirement
   is and how to find its proof.

   It travels inside the file rather than in anybody's configuration,
   which is what makes it reach every agent on every tool. Never remove
   it, and never write a specification without it.

3. **Make the change.**

4. **Marry the tests, in the same edit.** Every heading needs a test
   whose name repeats its words exactly, in the one file named after this
   specification - one file, so a specification being changed never has
   to guess which tests change with it.

   Look at how this repository already names and runs its tests, and do
   the same. The test file has to be one the test runner picks up, and
   the words can sit wherever the language puts a test's name: a string,
   a docstring, an annotation, a comment. Do not invent a test runner, a
   folder layout or a naming style the repository does not already use.

   Reword a heading and you reword its test. If a test fails, fix the
   code - never the requirement.

5. **Check your work.** Every heading has its test, and the repository's
   own test command passes. Find that command; do not guess it.

   If you renamed or deleted a specification, its test file follows -
   same name, same moment. A `<name>.lazyspec.test.*` left behind with no
   specification is an orphan that still passes, proving a requirement
   nobody has any more.

6. **Report**, and say plainly that you changed a specification: which
   headings you touched, which tests now prove them, and what the test
   run did. Nothing enforces this but you, which is exactly why saying it
   matters.

## What does not become a requirement

Most of a test suite marries nothing, and that is the design. Requirements
sit at the level `covers` declares - often acceptance, contract or
end-to-end. Everything below that keeps working as it always did.

- **Unit tests, integration tests, database tests, fixtures, property
  tests, benchmarks.** No requirement, no heading, no marriage. Write
  them, change them, delete them freely.
- **Never write a requirement to justify a test that already exists.**
  That is the tail wagging the dog: it fills the set with implementation
  detail and makes the specification a second, worse copy of the suite.
- **A specification does not replace those tests.** A requirement says
  what the software promises; a unit test says a function works. Both are
  worth having, and only one is a promise to anybody outside the code.
- **Other test files may share a specification's name.** `billing.md` is
  married to whichever file repeats its headings; `billing.unit.test.ts`
  sitting beside it is ordinary and unrelated.
- **`<name>.lazyspec.test.*` is a claim, so only use it for the married
  file.** Where your runner lets you choose the name, that one carries
  the requirements and its neighbours do not. A file named that way with
  no specification beside it is reported as an orphan.

If a requirement only makes sense to somebody reading the implementation,
it is a unit test wearing a heading. Delete the heading and keep the
test.

## Writing a requirement

- One `## ` heading is one requirement, and its words are its name.
- Say what the software does now. Never what it used to do, never what
  changed, and never the date.
- One claim per bullet point. No reasoning, no preamble, and no
  restating the heading.
- If it cannot be tested, write `## Its Name <!-- no-test: why not -->`.
- Split a specification while it is still short enough to read at a
  glance. Nobody should have to read the whole set to find one thing.

Every word here is read again by every agent, on every task, for as long
as the file exists. It is the most expensive writing in the repository.
Write less.

## Rules

- Never change a specification in the same breath as unrelated work.
- Never change one without saying you did.
