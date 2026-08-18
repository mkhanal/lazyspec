---
name: lazyspec-setup
description: Put the lazyspec instruction into the standing rules this repository's agents already load. Run once, after installing the plugin or copying the skills.
---

# /lazyspec-setup

One job: get `INSTRUCTION.md` into whatever this repository's agents read
on every task, and change nothing else.

A plugin carries skills. It cannot write files into somebody's
repository, and it should not: putting text into a team's standing rules
without being asked is exactly the thing lazyspec exists to stop an agent
doing. So this waits to be invoked, does the one step, and shows its
work.

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
3. **Whatever else this repository already has**: `.cursor/rules/`,
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

## 4. Point the other editors at it

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

## 5. Report

- Which file now carries the instruction, and whether you created it.
- Which editors were pointed at it.
- Anything you could not verify — an editor whose standing-context file
  you could not identify, or a store outside the repository you have no
  way to write to. Say so plainly. Guessing a filename is worse than
  admitting it: an instruction in a file nothing reads looks installed
  and does nothing.

Then tell them what is left, because none of it is yours to do:

- Requirements are written by `/lazyspec`, once behaviour is known.
- `/lazyspec-validate` checks them before finishing, and on a pull
  request.
- `.lazyspec.yaml` is optional; `/lazyspec` offers to write it when the
  first specification appears.

## Rules

- Change nothing but the instruction files. No specifications, no code,
  no configuration.
- Never write a specification here. There is no behaviour you have
  watched yet, and a requirement guessed from reading code is the thing
  this tool exists to prevent.
