---
name: lazyspec
description: The only way to change a specification. Keeps a requirement and its test married, in one edit. Use when a requirement needs to be added, reworded or removed.
---

# /lazyspec

Every specification says, on its first line, that it is changed only
through these steps. This is them.

## Steps

0. **If there is no `.lazyspec.yaml`, offer to write one now** - and only
   now, because until a repository has its first specification, nobody
   knows where they belong. Skip this whenever the file already exists.

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
   is each package or service, so there is one entry per boundary - and
   each may work at a different level, because a browser and a wire
   contract are not the same kind of promise:

   ```yaml
   sets:
     - root: services/api
       specs: specs/*.lazyspec.md
       covers: |
         The HTTP contract. One requirement per behaviour a caller can
         observe: status codes, error shapes, idempotency, ordering.
         Not internal helpers - those are somebody else's business.

     - root: apps/web
       specs: specs/*.lazyspec.md
       covers: |
         What a person can see and do in the browser. One requirement
         per user-visible rule, proved end to end. Not component
         internals, and never a CSS class.
   ```

   **`covers` is the project's decision and yours to ask about, not to
   assume.** It is free text, read by whoever writes the next
   requirement, and it is the difference between a set that stays
   coherent and one that fills up with whatever anybody felt like
   writing down. A team using consumer-driven contracts might say a
   requirement here is a pact; a team without them might say it is an
   endpoint's observable behaviour. Both are right; only the project
   knows which.

   Choose the level where a specification earns its keep here: per
   module, at the API surface, or end to end. Separate frontend and API
   sets are common, and one end-to-end set is a fair answer.

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
   — an internal helper where the set covers a wire contract, a CSS
   detail where it covers what a person can see — say so and stop. The
   requirement may belong in another set, at another level, or nowhere.
   A set that quietly widens is a set nobody trusts.

   Then: a new requirement joins the specification it belongs to. Only
   start a new `*.lazyspec.md` when none of them fits. Its filename
   decides which test file proves it, so if a test for this behaviour
   already exists, name the specification after that file.

   Give a new specification a title and a sentence saying what it is
   about, the way the others do. `covers` says what a set is for; the
   file's own opening says what this one is for.

   Every specification opens with a notice. Copy the one the others use;
   if you are writing the first, it reads:

   ```
   <!-- lazyspec: agents change this only via /lazyspec, with its tests. Humans edit freely. -->
   ```

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

6. **Report**, and say plainly that you changed a specification: which
   headings you touched, which tests now prove them, and what the test
   run did. Nothing enforces this but you, which is exactly why saying it
   matters.

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
