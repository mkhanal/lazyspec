> **lazyspec.** Humans edit freely. Agents change this only through
> `/lazyspec`, with its tests, in one edit.
>
> Each `##` heading is one requirement. Its test repeats that heading as
> its own name — to find it, search the tests for that text.

# The shape of a specification

A hook reaches three agents and costs friction. A header in the file
reaches every agent that opens one, on every tool, with nothing
installed — and it is read at the moment it matters, by whatever is about
to make the change.

## Every Specification Says It Is Locked

- Every `*.lazyspec.md` opens with a header naming `/lazyspec`.
- The header binds agents and leaves people alone.
- The header says what a requirement is and how to find its test.

## A Requirement Is A Level Two Heading

- `##` marks a requirement in every project, and `.lazyspec.yaml` has no
  setting to move it.
- Both shipped copies of the convention name `##`: the standing
  instruction, and the header every specification carries.
- A specification uses `##` for nothing else, so every one of its
  headings is repeated by a test.

## Every Married Test Names Its Specification And lazyspec

- The married test file's name carries the specification's stem and the
  word `lazyspec`.
- The word is matched with capitals and separators removed, so a language
  that forbids a dot in a name can still spell it.
- A test file carrying the word with no such specification is an orphan.
