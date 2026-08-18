<!-- lazyspec: agents change this only via /lazyspec, with its tests. Humans edit freely. -->

# lazyspec-guard

The one executable lazyspec ships. A coding agent calls it before a
tool runs, with the call as JSON on stdin, and exit 2 refuses the call.

## A Write To A Specification Is Refused Outside The Window

- A writing tool aimed at a locked path exits 2.
- The refusal names `/lazyspec` as the way in.

## A Specification Is Locked Wherever It Lives

- A file ending `.lazyspec.md` is locked whatever directory it sits in.
- A file that merely ends `SPEC.md` is not locked: somebody else's
  specification, vendored or written by hand, is not ours to defend.
- A married test is not locked, because a test is ordinary code.

## A Repository Can Name Its Own Locked Files

- The first line of `.lazyspec-locked` is added to the pattern of locked
  paths.
- A file ending `.lazyspec.md` stays locked whether or not
  `.lazyspec-locked` exists.

## The Unlock File Opens The Window

- While an empty `.lazyspec-unlock` exists in the working directory, a
  write to a locked path is allowed.

## The Window Can Name What It Opens

- A `.lazyspec-unlock` naming paths allows only the calls naming one of
  them.
- A call naming none of them is refused as though the window were shut.

## A Forgotten Window Closes Itself

- A window last written more than four hours ago is ignored.

## Each Flow Opens Its Own Window

- Any file whose name begins `.lazyspec-unlock` is a window.
- A path named by any open window is allowed.
- A shell command that writes a window file is never refused.

## A Structured Tool Is Judged By The Path It Writes To

- A write is refused only when the path it names is locked, whatever its
  content says.
- A notebook edit names its path as `notebook_path`.
- A call naming no path at all is judged by its whole payload.

## A Shell Call Is Recognised By Its Command

- A call carrying a shell command is judged as a shell call whatever its
  tool is named.

## A Shell Command That Writes To A Specification Is Refused

- A shell call that redirects into a locked path is refused.
- A shell call that edits a locked path in place is refused.
- A shell call that deletes a locked path is refused.

## Reading A Specification Is Never Refused

- A shell call that only reads a locked path is allowed.

## A Call That Names No Locked Path Is Left Alone

- The hook exits 0 and says nothing.
