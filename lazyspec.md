# Where this repository's requirements live

lazyspec is pointed at itself: this repository is the tool, and the first
thing the tool checks.

- **the whole repository** — `specs/*.lazyspec.md`. A requirement here
  describes something a consumer's repository would notice if it changed:
  the shape of a specification, the size and content of the standing
  instruction, what installing has to leave behind for either to work,
  and how a repository writes down where its own requirements live. Not the skills — those are prose, rewritten freely, and a
  requirement about their wording would be a requirement about style.

`sandbox/demo` and `sandbox/install-demo` are throwaway consumer
repositories, rebuilt on every run and gitignored. The specifications in
them prove things about the tool, not about this repository.
