> **lazyspec.** Humans edit freely. Agents change this only through
> `/lazyspec`, with its tests, in one edit.
>
> Each `##` heading is one requirement. Its test repeats that heading as
> its own name — to find it, search the tests for that text.

# Where requirements live

The one file a repository writes for itself: which files hold its
requirements, and what a requirement in each area is for.

## Where Requirements Live Is Written In Prose

- `lazyspec.md` names one area per bullet, and a glob only where it is
  not `*.lazyspec.md`.
- It carries no schema: no keys, no nesting, nothing to learn beyond
  markdown.
- It is optional, and the standing instruction reads it conditionally.
- `lazyspec.example.md` ships beside it, showing more than one layout a
  repository might use.
