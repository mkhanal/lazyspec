> **lazyspec.** Humans edit freely. Agents change this only through
> `/lazyspec`, with its tests, in one edit.
>
> Each `##` heading is one requirement. Its test repeats that heading as
> its own name — to find it, search the tests for that text.

# The standing instruction

`lazyspec.instruction.md` is pasted into whatever the agent loads on
every task. It is read again on every task forever, so its size is a
requirement
rather than a preference.

## The Standing Instruction Fits In Every Prompt

- `lazyspec.instruction.md` stays under two thousand characters, roughly five
  hundred tokens.

## This Repository Loads Its Own Instruction

- `AGENTS.md` carries the body of `lazyspec.instruction.md` word for word.
- Every other editor's file points at `AGENTS.md` instead of repeating
  it.

## The Standing Instruction Names /lazyspec And /lazyspec-validate

- `lazyspec.instruction.md` names `/lazyspec` as the way into a specification.
- `lazyspec.instruction.md` names `/lazyspec-validate` as the way to check.

## The Procedures Live In The Skills Alone

- No line of any `skills/*/SKILL.md` is copied into `lazyspec.instruction.md`,
  which an agent pays for whether or not it edits, validates or
  installs.
