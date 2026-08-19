> **lazyspec.** Humans edit freely. Agents change this only through
> `/lazyspec`, with its tests, in one edit.
>
> Each `##` heading is one requirement. Its test repeats that heading as
> its own name — to find it, search the tests for that text.

# Installing

How the standing instruction reaches a repository. Everything here is
load-bearing: get one of these wrong and the skills arrive with nothing
to say.

## The Plugin Resolves To This Repository

- The marketplace and the plugin it carries are both named `lazyspec`,
  so `lazyspec@lazyspec` names it.
- Every plugin manifest that ships declares the same version.
- The plugin's source resolves its root to the root of this repository.

## Installing Leaves The Instruction On Disk

- `INSTRUCTION.md` sits at the plugin root, where `/lazyspec-setup`
  looks for it first.
- The three skills sit beside it.
- Nothing shipped fetches `INSTRUCTION.md` over the network.

## The Paste Is Bounded By Named Markers

- The instruction is pasted between `<!-- lazyspec:begin -->` and
  `<!-- lazyspec:end -->`.
- Every shipped file naming that boundary spells both markers the same
  way.
