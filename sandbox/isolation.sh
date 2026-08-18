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
# Probe for a file *under the demo* surfacing. The harness scripts contain
# the demo's strings - they wrote them - so matching on the words alone
# would be a hit that proves nothing, which is the very thing this tool is
# about.
leak=$(cd "$SRC" && git grep --untracked -l -F -e 'Every Posting Balances To Zero' -- . 2>/dev/null \
       | grep '^sandbox/demo/')
[ -z "$leak" ] && ok "no file under sandbox/demo is visible to the parent" \
  || bad "leaked into the parent: $leak"
seenby=$(cd "$SRC" && git grep --untracked -l -F -e 'Every Posting Balances To Zero' -- . 2>/dev/null | tr '\n' ' ')
printf '        (the words do appear in %s- the harness that wrote them)\n' "$seenby"

echo
echo "4. an agent opened inside the demo will not inherit lazyspec's instruction"
grep -q "$SRC/CLAUDE.md" "$DEMO/.claude/settings.json" \
  && ok "claudeMdExcludes names the parent CLAUDE.md" || bad "no exclusion configured"
grep -q 'lazyspec:begin' "$DEMO/AGENTS.md" \
  && ok "the demo carries its own pasted instruction" || bad "no instruction in the demo"

echo
echo "5. nothing executable ships"
if [ -e "$SRC/lazyspec-guard" ]; then bad "a guard is present in the source repo"
else ok "no guard in the source repo"; fi
if [ -e "$DEMO/lazyspec-guard" ]; then bad "a guard reached the demo"
else ok "no guard reached the demo"; fi

echo
printf 'isolation: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
