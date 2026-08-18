---
name: lazyspec-setup
description: Set lazyspec up in this repository - put the instruction where agents read it every task, and work out where specifications will live. Run once, after installing the plugin or copying the skills.
---

# /lazyspec-setup

Two jobs, once. Put `INSTRUCTION.md` where this repository's agents read
it on every task, and settle where specifications will live. Nothing
else.

A plugin carries skills. It cannot write files into somebody's
repository, and it should not: putting text into a team's standing rules
without being asked is the precise act lazyspec exists to prevent. So
this waits to be invoked, does its two jobs, and shows its work.

## 1. Find the instruction

It ships beside these skills. Look, in order:

- `${CLAUDE_PLUGIN_ROOT}/INSTRUCTION.md` — the plugin route.
- `INSTRUCTION.md` next to the skills folder you copied from, if you
  cloned instead.
- `https://github.com/mkhanal/lazyspec/blob/main/INSTRUCTION.md` — last
  resort, and only if you can fetch it.

Read it whole. You are about to paste it verbatim, so if you cannot find
it, stop and say so rather than writing it from memory. An instruction
you reconstructed is not the instruction.

## 2. Find where the standing rules live

Read the repository before deciding. In order of preference:

1. **A document the team already keeps** — `CONSTITUTION.md`,
   `PRINCIPLES.md`, engineering standards, house rules. If one exists and
   agents already load it, that is the home. A rule filed beside rules
   people already respect is followed; a rule in a file of its own
   competes for attention.
2. **`AGENTS.md`** — the default when there is no such document.
3. **Any other file this repository already keeps**: `.cursor/rules/`,
   `.github/copilot-instructions.md`, `GEMINI.md`, `.clinerules`,
   `CONVENTIONS.md`.

Say what you found and where you propose to put it, then **wait for a
yes**. This is somebody's standing rules; do not edit them unasked.

## 3. Paste it, between markers

```
<!-- lazyspec:begin -->
… the body of INSTRUCTION.md, word for word …
<!-- lazyspec:end -->
```

- **Verbatim.** Do not summarise, reword or trim it to fit the house
  style. It is held under two thousand characters by a test for a reason,
  and every line earns its place.
- **Markers matter.** A later run replaces what is between them and
  touches nothing else.
- **Already there?** Replace between the markers and say what changed. If
  the text is identical, say so and stop.

## 4. Offer to write `.lazyspec.yaml`

Skip this if the file already exists, or if they would rather wait — it
is optional, and without it every `*.lazyspec.md` counts, which is right
for a small repository.

Otherwise **work it out yourself first, and ask only what you genuinely
cannot see.** You have the repository in front of you. Read it.

- **The boundaries.** Package manifests, workspace globs, service
  folders, deployment units. A monorepo gets one set per boundary,
  because a specification's name has to be unique inside its `root` or
  two packages both claim the same test file. One project gets one set
  with `root: .`.
- **Where specifications will sit.** Next to the code they describe, in
  the folder that package already uses for tests or docs.
- **What each set is likely to cover.** A service is what a caller
  observes at its boundary. A pipeline is what holds of the data after a
  run. A worker is what happens per job. A library is its public surface.
  Read the code and say which this is, then say what it excludes.

Then put the whole thing in front of them, filled in, and **mark what you
inferred**:

```yaml
sets:
  - root: services/ingest       # found: a server, routes, contract tests
    specs: specs/*.lazyspec.md
    covers: |
      What a caller observes at the boundary: what is accepted, what
      is refused, what comes back.               # inferred - check me

  - root: pipelines/nightly     # found: a scheduler, fixtures, dbt tests
    specs: specs/*.lazyspec.md
    covers: |
      What must hold of the data after a run, and what happens when a
      run fails halfway.                          # inferred - check me
```

Ask only the questions the repository does not answer, and ask them as
questions with your best answer already in them:

- **The level, when the code is ambiguous.** "This service has consumer
  contract files as well as unit tests. Should a requirement here be one
  of those contracts, or whatever a caller can observe?" That is a
  genuine choice and the repository cannot settle it.
- **A boundary you cannot place.** A package that could be its own set
  or part of a larger one.
- **Nothing else.** Do not ask what you can read. A question whose answer
  is in `package.json` wastes the one moment somebody is paying
  attention.

`covers` is the project's decision, so never invent it silently. A
sentence you guessed and nobody corrected is worse than no sentence,
because the next agent will treat it as settled.

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
- Whether you wrote `.lazyspec.yaml`, and which parts of it you inferred
  rather than were told.
- Which editors were pointed at it.
- Anything you could not verify — an editor whose standing-context file
  you could not identify, or a store outside the repository you have no
  way to write to. Say so plainly. Guessing a filename is worse than
  admitting it: an instruction in a file nothing reads looks installed
  and does nothing.

Then tell them what is left, because none of it is yours to do:

- Requirements are written by `/lazyspec`, once behaviour is known. Not
  now: there is no behaviour you have watched yet.
- `/lazyspec-validate` checks them before finishing, and on a pull
  request.

Writing down where specifications will live is not specifying. The shape
of a repository is knowable today; what its code does is not, which is
why one is safe to settle now and the other waits.

## Rules

- Change nothing but the instruction files and `.lazyspec.yaml`. No
  specifications, no code, no other configuration.
- Never write a specification here. There is no behaviour you have
  watched yet, and a requirement guessed from reading code is the exact
  failure this tool exists to prevent.
