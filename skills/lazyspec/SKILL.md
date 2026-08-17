---
name: lazyspec
description: The only way to change a specification. Opens the lock, keeps a requirement and its test married, closes it again. Use when a requirement needs to be added, reworded or removed.
---

# /lazyspec

Specifications are locked so that nothing edits one in passing. This is
the way in.

## Steps

0. **If there is no `.lazyspec.yaml`, offer to write one now** - and only
   now, because until a repository has its first specification, nobody
   knows where they belong. Skip this whenever the file already exists.

   Read the repository, then propose it and wait for a yes:

   ```yaml
   sets:
     - root: .
       specs: specs/*.lazyspec.md
   ```

   `root` is the folder a specification's name has to be unique inside,
   because two packages each holding `billing.lazyspec.md` would both
   claim the same test file. In one project that is `.`. In a monorepo it
   is each package or service, so there is one entry per boundary:

   ```yaml
   sets:
     - root: services/api
       specs: specs/*.lazyspec.md

     - root: apps/web
       specs: specs/*.lazyspec.md

     - root: packages
       specs: "*/specs/*.lazyspec.md"
   ```

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

2. **Choose the file.** A new requirement joins the specification it
   belongs to. Only start a new `*.lazyspec.md` when none of them fits.
   Its filename decides which test file proves it, so if a test for this
   behaviour already exists, name the specification after that file.

3. **Open a window of your own, naming only what you are about to edit.**

   ```
   printf '%s\n' path/to/the.lazyspec.md > ".lazyspec-unlock.$$"
   ```

   The suffix must be unique to **this run of these steps**, not to you
   and not to your session. One session opens and closes the lock many
   times, and a subagent may be holding one while you work. `$$` is the
   shell's own process id and needs no thought; a timestamp does as well.
   Reuse an id and you will close a window somebody else is still using.

   Name every file you will touch, one per line. The window opens for
   those and nothing else, so a slip cannot reach a neighbouring
   specification, and a window you fail to close leaks one path instead
   of the whole repository. An empty file opens everything; use that only
   when you genuinely do not yet know the filename.

   `.lazyspec-unlock*` must be in `.gitignore`. Committed once, the lock
   is off for good and nobody will notice.

4. **Make the change.**

5. **Marry the tests before you close the lock.** Every heading needs a
   test whose name repeats its words exactly, in the one file named after
   this specification - one file, so a specification being changed never
   has to guess which tests change with it.

   Look at how this repository already names and runs its tests, and do
   the same. The test file has to be one the test runner picks up, and
   the words can sit wherever the language puts a test's name: a string,
   a docstring, an annotation, a comment. Do not invent a test runner, a
   folder layout or a naming style the repository does not already use.

   Reword a heading and you reword its test. If a test fails, fix the
   code - never the requirement.

6. **Check your work.** Every heading has its test, and the repository's
   own test command passes. Find that command; do not guess it.

7. **Lock again**: delete the one window you made, and only that one.
   Always, including when you give up part way. Leaving it costs less
   than it used to - a window stops counting four hours after it was
   written - but four hours is not nothing.

8. **Report**: which headings you touched, which tests now prove them,
   and what the test run did.

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

- The lock stays open for this one job and no longer.
- Never change a specification in the same breath as unrelated work.
