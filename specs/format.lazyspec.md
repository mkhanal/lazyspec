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
