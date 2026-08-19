# Where our requirements live

<!-- An example of the file /lazyspec-setup writes. Copy the shape, not
     the words: the areas are yours, and so is every description. -->

Repositories put specifications in different places, and any of these is
fine. Name the glob yours actually uses.

- **the whole repository** — `specs/*.lazyspec.md`.
  One project, one area, and the common case. A requirement is what a
  caller observes at the boundary.

- **apps/api** — `spec/*.lazyspec.md`.
  Specifications beside the code they describe. What is accepted, what is
  refused, what comes back. Not internal helpers.

- **each module under apps/api** — `src/modules/*/spec/*.lazyspec.md`.
  One area per module, when modules are what people own and review.

- **the workspace packages** — `packages/*/spec/*.lazyspec.md`.
  Each package at its public surface. Not its internals.

- **pipelines/nightly** — `docs/spec/*.lazyspec.md`.
  What must hold of the data after a run, and what happens to a run that
  fails halfway. Not the shape of any one query.

- **workers/settlement** — `spec/*.lazyspec.md`.
  What happens for each job, including retries, duplicates and ordering.
  Not the queue library's own behaviour.

- **legacy/billing** — `**/SPEC.md`.
  Requirements already here under another name. Point at what exists;
  `*.lazyspec.md` is where to end up, when somebody chooses to move.

A description can be perfectly generic. "What a caller observes at the
boundary" is a real answer and the usual one. What it must not be is a
guess nobody checked, because the next agent will treat it as settled.

An area is worth its own bullet when specification names have to be
unique inside it - two packages each holding `billing.lazyspec.md` would
claim the same test file. If that cannot happen, one bullet is enough.

Never use `## ` in this file. That mark means a requirement everywhere
else, and a check that finds one here will look for a test to prove it.
