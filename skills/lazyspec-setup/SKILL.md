---
name: lazyspec-setup
description: Set lazyspec up in this repository - put the instruction where agents read it every task, and work out where specifications will live. Run once, after installing the plugin or copying the skills.
---

# /lazyspec-setup

Two jobs, once. Put `lazyspec.instruction.md` where this repository's
agents read
it on every task, and settle where specifications will live. Nothing
else.

A plugin carries skills. It cannot write files into somebody's
repository, and it should not: putting text into a team's standing rules
without being asked is the precise act lazyspec exists to prevent. So
this waits to be invoked, does its two jobs, and shows its work.

## 1. Find the instruction

It ships beside these skills. Look, in order:

- `${CLAUDE_PLUGIN_ROOT}/lazyspec.instruction.md` — the plugin route.
- - `lazyspec.instruction.md` in or beside the skills folder, if it was
  copied in.

Read it whole, and paste only what you read.

**If it is not on disk, stop and ask for it.** Do not fetch it, and do
not write it from memory. A copy pulled from the network is whatever the
project's default branch says today, which is not necessarily what the
skills sitting next to you were written for - and you are about to paste
it, unread by anybody, into the standing rules of a team that has not
seen it. An instruction you reconstructed is not the instruction, and one
you downloaded is not the one they installed.

## 2. Find where the standing rules live

Read the repository before deciding. In order of preference:

1. **A document the team already keeps** — `CONSTITUTION.md`,
   `PRINCIPLES.md`, engineering standards, house rules. If one exists,
   that is the home. A rule filed beside rules people already respect is
   followed; a rule in a file of its own competes for attention.

   **Whether anything loads it today does not change the answer.** If
   nothing does, step 5 fixes that: `AGENTS.md` and `CLAUDE.md` point at
   it, and the team's own rules start arriving in context too, which they
   were not before. Do not leave their document sitting unread beside a
   new one of yours.
2. **`AGENTS.md`** — the default when there is no such document.
3. **Any other file this repository already keeps**: `.cursor/rules/`,
   `.github/copilot-instructions.md`, `GEMINI.md`, `.clinerules`,
   `CONVENTIONS.md`.

Say what you found and where you propose to put it, then **wait for a
yes**. This is somebody's standing rules; do not edit them unasked.

## 3. Paste it, between markers

```
<!-- lazyspec:begin -->
… the body of lazyspec.instruction.md, word for word …
<!-- lazyspec:end -->
```

- **Verbatim.** Do not summarise, reword or trim it to fit the house
  style. It is held under two thousand characters by a test for a reason,
  and every line earns its place.
- **Markers matter.** A later run replaces what is between them and
  touches nothing else.
- **Already there?** Replace between the markers and say what changed. If
  the text is identical, say so and stop.

## 4. Offer to write `lazyspec.md`

Skip this if the file already exists, or if they would rather wait - it
is optional, and without it every `*.lazyspec.md` counts, which is right
for a small repository.

Otherwise **work it out yourself first, and ask only what you genuinely
cannot see.** You have the repository in front of you. Read it.

- **Specifications that are already here.** Look before you propose a
  name. A repository that has been doing this by hand, or arrived from
  another tool, has files full of requirements called something else -
  `SPEC.md`, `requirements.md`, `docs/behaviour/*.md`. Name what it
  already has. A glob that matches nothing leaves every existing
  requirement outside, unchecked and invisible, and the check will report
  a clean repository because it can see no specifications at all.

  `*.lazyspec.md` is where a repository should end up - the name is what
  makes a specification recognisable to an agent that opens one knowing
  nothing else. Say so. But a rename is a change to their repository and
  not part of installing yours, so name what exists, and let them move
  when they choose.
- **The areas.** One bullet per area whose specification names have to be
  unique: two packages each holding `billing.lazyspec.md` would claim the
  same test file. Read package manifests, workspace globs, service
  folders, deployment units. One project is one bullet.
- **Where specifications sit in each.** Beside the code they describe, in
  the folder that package already uses for tests or docs - `spec/`,
  `specs/`, `docs/spec/`. Layouts differ and all of them are fine.
- **What a requirement in each is for.** A service is what a caller
  observes at its boundary. A pipeline is what holds of the data after a
  run. A worker is what happens per job. A library is its public surface.
  Read the code, say which this is, then say what it excludes. A generic
  answer is a real answer; a guessed one that nobody checks is not.

Then put the whole thing in front of them, filled in, and **mark what you
inferred**:

```markdown
# Where our requirements live

- **apps/api** — `spec/*.lazyspec.md`     <!-- found: routes, contract tests -->
  What a caller observes at the boundary: what is accepted, what is
  refused, what comes back. Not internal helpers.   <!-- inferred - check me -->

- **pipelines/nightly** — `docs/spec/*.lazyspec.md`  <!-- found: a scheduler, dbt tests -->
  What must hold of the data after a run, and what happens when a run
  fails halfway.                                    <!-- inferred - check me -->
```

`lazyspec.example.md` in this project shows more layouts - specifications
per module, per package, in a central folder, and a repository still on
its old name.

**Never use `## ` in that file.** The mark means a requirement everywhere
else, and a check that meets one there will look for a test to prove it.
Title, then bullets.

Ask only the questions the repository does not answer, and ask them as
questions with your best answer already in them:

- **The level, when the code is ambiguous.** "This service has consumer
  contract files as well as unit tests. Should a requirement here be one
  of those contracts, or whatever a caller can observe?" That is a
  genuine choice and the repository cannot settle it.
- **An area you cannot place.** A package that could stand alone or be
  part of a larger one.
- **Nothing else.** Do not ask what you can read. A question whose answer
  is in `package.json` wastes the one moment somebody is paying
  attention.

What each area is for is the project's decision, so never invent it
silently. A sentence you guessed and nobody corrected is worse than no
sentence, because the next agent will treat it as settled.

## 5. Point the other editors at it

Give every other editor this repository uses a short file that *points
at* the one you just wrote, never a second copy. Two copies drift, and a
stale instruction is worse than none.

- **Claude Code reads `CLAUDE.md` and never looks for `AGENTS.md`.** A
  repository with only an `AGENTS.md` looks set up and is not. A
  `CLAUDE.md` holding the single line `@AGENTS.md` fixes it.
- Where an editor cannot include another file, paste the same text there
  and say that you now have two copies to keep in step.
- Only create files for editors this repository shows signs of using. A
  file nothing reads looks installed and does nothing.

## 6. Report

- Which file now carries the instruction, and whether you created it.
- Whether you wrote `lazyspec.md`, and which parts of it you inferred
  rather than were told.
- Which editors were pointed at it.
- Anything you could not verify — an editor whose standing-context file
  you could not identify, or a store outside the repository you have no
  way to write to. Say so plainly; guessing a filename is worse than
  admitting it.

**Say that what you just pasted is not loaded yet.** An agent reads the
standing rules when its session starts, so the session you are in was
given them before you wrote anything. Yours is the one session in this
repository where the instruction is not in effect. Tell them to start a
new one and ask "where do this repository's requirements live?" - an
immediate answer means it is loaded, and searching means it is not.

Then tell them what is left, because none of it is yours to do:

- Requirements are written by `/lazyspec`, as soon as somebody knows
  one. Not now: installing is not knowing.
- `/lazyspec-validate` checks them before finishing, and on a pull
  request.

Writing down where specifications will live is not specifying. You can
read a repository's shape off its files today. What it promises is a
decision somebody makes, and nobody has made it in front of you.

## Rules

- Change nothing but the instruction files and `lazyspec.md`. No
  specifications, no code, no other configuration.
- Never write a specification here. A requirement reverse-engineered
  from code is a description of the implementation wearing a promise's
  clothes, which is the exact failure this tool exists to prevent.
