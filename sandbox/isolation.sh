#!/bin/sh
# Prove the demo is sealed off from lazyspec itself, which is the
# repository directly above it.
SRC=$(cd "$(dirname "$0")/.." && pwd)
DEMO=$SRC/sandbox/demo
pass=0; fail=0
ok()  { pass=$((pass + 1)); printf '  ok    %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL  %s\n' "$1"; }

echo "1. separate git repositories"
p=$(cd "$SRC" && git rev-parse --show-toplevel)
d=$(cd "$DEMO" && git rev-parse --show-toplevel)
[ "$p" != "$d" ] && ok "demo has its own git root ($d)" || bad "demo shares the parent's git root"

echo
echo "2. the parent ignores the demo entirely"
(cd "$SRC" && git check-ignore -q sandbox/demo/AGENTS.md) \
  && ok "sandbox/demo is gitignored" || bad "sandbox/demo is tracked"

echo
echo "3. the demo's specifications do not leak into the parent's searches"
seen=$(cd "$SRC" && git ls-files --cached --others --exclude-standard '*.lazyspec.md' | tr '\n' ' ')
case $seen in
  *sandbox*) bad "parent lists a demo specification: $seen" ;;
  *) ok "parent lists only its own: $seen" ;;
esac
# Probe for any file *under the demo* surfacing in the parent's search.
# The harness scripts themselves contain the demo's strings - they wrote
# them - so matching on the string alone would be a hit that proves
# nothing, which is the very thing this tool is about.
leak=$(cd "$SRC" && git grep --untracked -l -F -e 'Every Posting Balances To Zero' -- . 2>/dev/null \
       | grep '^sandbox/demo/')
[ -z "$leak" ] && ok "no file under sandbox/demo is visible to the parent" \
  || bad "leaked into the parent: $leak"
seenby=$(cd "$SRC" && git grep --untracked -l -F -e 'Every Posting Balances To Zero' -- . 2>/dev/null | tr '\n' ' ')
printf '        (the string does appear in %s- the harness that wrote it)\n' "$seenby"

echo
echo "4. the demo answers with its own guard"
if [ -L "$DEMO/lazyspec-guard" ]; then
  bad "the demo's guard is a symlink to the parent"
else
  ok "the demo's guard is its own copy, not a link"
fi

echo
echo "5. the parent's open window cannot unlock the demo"
touch "$SRC/.lazyspec-unlock"
r=$(printf '%s' '{"tool_name":"Edit","tool_input":{"file_path":"x.lazyspec.md"}}' \
    | (cd "$DEMO" && sh ./lazyspec-guard >/dev/null 2>&1); echo $?)
rm -f "$SRC/.lazyspec-unlock"
[ "$r" = "2" ] && ok "demo stayed locked while the parent was unlocked" \
  || bad "the parent's window leaked in (exit $r)"

echo
echo "6. an agent opened inside the demo will not inherit lazyspec's instruction"
grep -q "$SRC/CLAUDE.md" "$DEMO/.claude/settings.json" \
  && ok "claudeMdExcludes names the parent CLAUDE.md" || bad "no exclusion configured"
grep -q '"hooks"' "$DEMO/.claude/settings.json" \
  && ok "the demo registers its own guard hook" || bad "no hook in the demo"

echo
printf 'isolation: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
