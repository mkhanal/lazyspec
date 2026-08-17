#!/bin/sh
# Rebuild a throwaway consumer repo in sandbox/demo and run every scenario
# against it.
#
#   sh sandbox/run.sh
#
# Isolation matters here, because the repository above this one is
# lazyspec itself and would otherwise answer for the demo:
#
#   * demo/ is its own git repository, so `git grep` and `git diff` see
#     only the demo.
#   * every guard call runs with cwd=demo, against the demo's own copy of
#     lazyspec-guard, so the parent's hook and the parent's
#     .lazyspec-unlock cannot answer.
#   * demo/.claude/settings.json sets claudeMdExcludes for the parent
#     CLAUDE.md, so an agent opened inside demo/ does not inherit
#     lazyspec's own standing instruction by walking up the tree.

SRC=$(cd "$(dirname "$0")/.." && pwd)
DEMO=$SRC/sandbox/demo
pass=0; fail=0

ok()  { pass=$((pass + 1)); printf '    ok    %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '    FAIL  %s\n' "$1"; }
is()  { [ "$2" = "$3" ] && ok "$1" || bad "$1 -- got '$2', wanted '$3'"; }
sect(){ printf '\n%s\n' "$1"; }

# Run the guard the way an agent does: the call as JSON on stdin, from
# inside the demo, using the demo's own copy.
guard() { printf '%s' "$1" | (cd "$DEMO" && sh ./lazyspec-guard >/dev/null 2>&1); echo $?; }
edit()  { printf '{"tool_name":"%s","tool_input":{"file_path":"%s"}}' "${2:-Edit}" "$1"; }
shell() { printf '{"tool_name":"Bash","tool_input":{"command":"%s"}}' "$1"; }

# ---------------------------------------------------------------- build

rm -rf "$DEMO"
mkdir -p "$DEMO"
cd "$DEMO" || exit 1
git init -q .
git config user.email demo@example.com
git config user.name demo

# install, the way README.md says to
cp "$SRC/lazyspec-guard" .
mkdir -p .claude/skills .agents/skills
cp -R "$SRC"/skills/. .claude/skills/
cp -R "$SRC"/skills/. .agents/skills/

printf '<!-- lazyspec:begin -->\n' > AGENTS.md
cat "$SRC/INSTRUCTION.md" >> AGENTS.md
printf '<!-- lazyspec:end -->\n' >> AGENTS.md
printf '@AGENTS.md\n' > CLAUDE.md
printf '.lazyspec-unlock\n' > .gitignore

cat > .claude/settings.json <<SETTINGS
{
  "claudeMdExcludes": ["$SRC/CLAUDE.md", "$SRC/AGENTS.md"],
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|MultiEdit|NotebookEdit|Bash",
        "hooks": [
          { "type": "command",
            "command": "sh \\"\$CLAUDE_PROJECT_DIR/lazyspec-guard\\"" }
        ]
      }
    ]
  }
}
SETTINGS

cat > .lazyspec.yaml <<'YAML'
sets:
  - root: services/api
    specs: specs/*.lazyspec.md
  - root: services/ledger
    specs: specs/*.lazyspec.md
  - root: services/router
    specs: specs/*.lazyspec.md
  - root: apps/web
    specs: specs/*.lazyspec.md
YAML

# --- a JavaScript service
mkdir -p services/api/specs services/api/src
cat > services/api/specs/billing.lazyspec.md <<'EOF'
# Billing

## Refunds Never Exceed What Was Captured

- A refund is refused when it would take the total refunded above the
  amount captured.

## A Refund Is Recorded Against Its Capture <!-- no-test: the ledger is somebody else's system -->

- Every refund names the capture it draws from.

## Chargebacks Are Held For Review

- A chargeback is never settled automatically.
EOF
cat > services/api/specs/billing.lazyspec.test.js <<'EOF'
describe('Refunds Never Exceed What Was Captured', () => {
  it('refuses a refund beyond the captured amount', () => {});
});
EOF
echo 'module.exports = {};' > services/api/src/billing.js

# --- a Python service
mkdir -p services/ledger/specs services/ledger/tests services/ledger/src
cat > services/ledger/specs/postings.lazyspec.md <<'EOF'
# Postings

## Every Posting Balances To Zero

- A posting whose legs do not sum to zero is refused.
EOF
cat > services/ledger/tests/test_postings.py <<'EOF'
def test_balances():
    """Every Posting Balances To Zero"""
    assert True
EOF
echo 'def post(): pass' > services/ledger/src/postings.py

# --- a Go service
mkdir -p services/router/specs
cat > services/router/specs/routing.lazyspec.md <<'EOF'
# Routing

## Unknown Routes Return Not Found

- A request for an unregistered path is answered with 404.
EOF
cat > services/router/routing_test.go <<'EOF'
func TestRouting(t *testing.T) {
    t.Run("Unknown Routes Return Not Found", func(t *testing.T) {})
}
EOF

# --- a Java app
mkdir -p apps/web/specs
cat > apps/web/specs/checkout.lazyspec.md <<'EOF'
# Checkout

## A Cart Holds At Most Fifty Lines

- Adding a fifty-first line is refused.
EOF
cat > apps/web/CheckoutTest.java <<'EOF'
@DisplayName("A Cart Holds At Most Fifty Lines")
class CheckoutTest {}
EOF

# --- somebody else's specification, vendored
mkdir -p vendor/proto
printf '# Wire protocol\nNot ours to lock.\n' > vendor/proto/SPEC.md

git add -A >/dev/null 2>&1
git commit -qm "demo baseline"

printf 'built %s\n' "$DEMO"

# ------------------------------------------------------------- A. install

sect "A. install"
[ -x "$DEMO/lazyspec-guard" ] || [ -f "$DEMO/lazyspec-guard" ] && ok "guard copied" || bad "guard copied"
for d in .claude/skills .agents/skills; do
  [ -f "$DEMO/$d/lazyspec/SKILL.md" ] && ok "skills in $d" || bad "skills in $d"
done
for s in lazyspec lazyspec-validate; do
  n=$(sed -n 's/^name: *//p' "$DEMO/.claude/skills/$s/SKILL.md" | head -1)
  is "skill frontmatter name matches folder: $s" "$n" "$s"
done
grep -q 'lazyspec:begin' AGENTS.md && ok "instruction pasted between markers" || bad "markers"
is "CLAUDE.md is a one-line shim" "$(cat CLAUDE.md)" "@AGENTS.md"
grep -q 'lazyspec-unlock' .gitignore && ok "unlock file is ignored" || bad "gitignore"
grep -q 'claudeMdExcludes' .claude/settings.json && ok "parent CLAUDE.md excluded" || bad "isolation"

# ------------------------------------------- B. guard, structured tools

sect "B. guard - structured tools"
is "Edit a specification"            "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 2
is "Write a specification"           "$(guard "$(edit services/api/specs/billing.lazyspec.md Write)")" 2
is "MultiEdit a specification"       "$(guard "$(edit services/api/specs/billing.lazyspec.md MultiEdit)")" 2
is "a specification nested deep"     "$(guard "$(edit a/b/c/d/deep.lazyspec.md)")" 2
is "a specification by absolute path" "$(guard "$(edit /somewhere/else/x.lazyspec.md)")" 2
is "an ordinary source file"         "$(guard "$(edit services/api/src/billing.js)")" 0
is "the married test"                "$(guard "$(edit services/api/specs/billing.lazyspec.test.js)")" 0
is "somebody else's SPEC.md"         "$(guard "$(edit vendor/proto/SPEC.md)")" 0
is "notebook_path is read" "$(guard '{"tool_name":"NotebookEdit","tool_input":{"notebook_path":"n.lazyspec.md"}}')" 2
is "an ordinary notebook whose source names a spec" \
   "$(guard '{"tool_name":"NotebookEdit","tool_input":{"notebook_path":"n.ipynb","new_source":"x.lazyspec.md"}}')" 0
is "content naming a specification stays writable" \
   "$(guard '{"tool_name":"Write","tool_input":{"file_path":"README.md","content":"see billing.lazyspec.md"}}')" 0
is "a payload with no path at all" \
   "$(guard '{"tool_name":"Other","tool_input":{"old_string":"billing.lazyspec.md"}}')" 2

# -------------------------------------------------- C. guard, shell calls

sect "C. guard - shell calls"
is "redirect into a specification"  "$(guard "$(shell 'cat > services/api/specs/billing.lazyspec.md')")" 2
is "append into a specification"    "$(guard "$(shell 'echo x >> billing.lazyspec.md')")" 2
is "sed -i on a specification"      "$(guard "$(shell 'sed -i s/a/b/ billing.lazyspec.md')")" 2
is "rm a specification"             "$(guard "$(shell 'rm -f billing.lazyspec.md')")" 2
is "tee into a specification"       "$(guard "$(shell 'echo x | tee billing.lazyspec.md')")" 2
is "python near a specification"    "$(guard "$(shell 'python3 fix.py billing.lazyspec.md')")" 2
is "cat a specification"            "$(guard "$(shell 'cat billing.lazyspec.md')")" 0
is "grep a specification"           "$(guard "$(shell 'grep -n ## billing.lazyspec.md')")" 0
is "a shell call naming no spec"    "$(guard "$(shell 'rm -rf build/')")" 0

# ---------------------------------------------------------- D. the window

sect "D. the window"
touch "$DEMO/.lazyspec-unlock"
is "empty window: any specification is writable" "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 0
is "empty window: a neighbour too"              "$(guard "$(edit apps/web/specs/checkout.lazyspec.md)")" 0
printf 'services/api/specs/billing.lazyspec.md\n' > "$DEMO/.lazyspec-unlock"
is "named window: the named file opens"         "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 0
is "named window: a shell write to it opens"    "$(guard "$(shell 'sed -i s/a/b/ services/api/specs/billing.lazyspec.md')")" 0
is "named window: a neighbour stays shut"       "$(guard "$(edit apps/web/specs/checkout.lazyspec.md)")" 2
is "named window: ordinary code is unaffected"  "$(guard "$(edit services/api/src/billing.js)")" 0
rm -f "$DEMO/.lazyspec-unlock"
is "closed: refused again"             "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 2

# two agents at work in one tree, each with a window of its own
printf 'services/api/specs/billing.lazyspec.md\n' > "$DEMO/.lazyspec-unlock.alpha"
printf 'apps/web/specs/checkout.lazyspec.md\n'    > "$DEMO/.lazyspec-unlock.beta"
is "parallel: alpha's file opens"      "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 0
is "parallel: beta's file opens"       "$(guard "$(edit apps/web/specs/checkout.lazyspec.md)")" 0
is "parallel: a third stays shut"      "$(guard "$(edit services/ledger/specs/postings.lazyspec.md)")" 2
rm -f "$DEMO/.lazyspec-unlock.alpha"
is "parallel: alpha finishing leaves beta open" "$(guard "$(edit apps/web/specs/checkout.lazyspec.md)")" 0
is "parallel: ...and closes alpha's"   "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 2
rm -f "$DEMO/.lazyspec-unlock.beta"
is "parallel: both shut"               "$(guard "$(edit apps/web/specs/checkout.lazyspec.md)")" 2
is "opening a window is never refused" "$(guard "$(shell 'printf %s specs/x.lazyspec.md > .lazyspec-unlock.gamma')")" 0

# a session that dropped, hours ago, leaving its window behind
touch "$DEMO/.lazyspec-unlock.dropped"
is "a fresh forgotten window still counts" "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 0
touch -t 200001010000 "$DEMO/.lazyspec-unlock.dropped"
is "an old one stops counting on its own"  "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 2
printf 'apps/web/specs/checkout.lazyspec.md\n' > "$DEMO/.lazyspec-unlock.live"
is "a live window works beside a stale one" "$(guard "$(edit apps/web/specs/checkout.lazyspec.md)")" 0
is "...and the stale one still opens nothing" "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 2
rm -f "$DEMO/.lazyspec-unlock.dropped" "$DEMO/.lazyspec-unlock.live"
touch "$SRC/.lazyspec-unlock.notreal"
is "the parent's window cannot open the demo's" "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 2
rm -f "$SRC/.lazyspec-unlock.notreal"

# ----------------------------------------------- E. the marriage searches

sect "E. searching for proof"
find_proof() {
  git grep --untracked -l -F -e "$1" -- . 2>/dev/null \
    | grep -v '\.lazyspec\.md$' | grep -v '^AGENTS.md$' | grep -v '^CLAUDE.md$' | tr '\n' ' '
}
is "JavaScript, describe()" "$(find_proof 'Refunds Never Exceed What Was Captured')" \
   "services/api/specs/billing.lazyspec.test.js "
is "Python, a docstring"    "$(find_proof 'Every Posting Balances To Zero')" \
   "services/ledger/tests/test_postings.py "
is "Go, t.Run"              "$(find_proof 'Unknown Routes Return Not Found')" \
   "services/router/routing_test.go "
is "Java, @DisplayName"     "$(find_proof 'A Cart Holds At Most Fifty Lines')" \
   "apps/web/CheckoutTest.java "
is "an unmarried requirement finds nothing" "$(find_proof 'Chargebacks Are Held For Review')" ""

n=$(grep -c '^## ' services/api/specs/billing.lazyspec.md)
m=$(grep '^## ' services/api/specs/billing.lazyspec.md | grep -vc 'no-test')
is "no-test requirements are skipped" "$n/$m" "3/2"

# the pasted instruction is a false positive, and is discountable
hits=$(git grep --untracked -l -F -e 'Refunds Never Exceed What Was Captured' -- . | tr '\n' ' ')
case $hits in
  *AGENTS.md*) ok "the pasted instruction does hit, as expected" ;;
  *) bad "expected AGENTS.md to hit" ;;
esac
grep -q 'lazyspec:begin' AGENTS.md && ok "...and sits inside lazyspec markers, so it is discountable" || bad "markers"

# duplicated heading across two specifications
cp services/api/specs/billing.lazyspec.md services/ledger/specs/copy.lazyspec.md
dups=$(git grep --untracked -l -F -e 'Refunds Never Exceed What Was Captured' -- . | grep -c '\.lazyspec\.md$')
is "one heading in two specifications is visible" "$dups" "2"
rm services/ledger/specs/copy.lazyspec.md

# monorepo: the same stem in two packages does not collide
mkdir -p services/ledger/specs
cp services/api/specs/billing.lazyspec.md services/ledger/specs/billing.lazyspec.md
a=$(ls services/api/specs/billing.lazyspec.md)
b=$(ls services/ledger/specs/billing.lazyspec.md)
[ "$a" != "$b" ] && ok "the same stem lives in two roots, told apart by root" || bad "monorepo"
rm services/ledger/specs/billing.lazyspec.md

# ------------------------------------------------------- F. judging a change

sect "F. judging a change"
printf -- '- A second bullet.\n' >> services/api/specs/billing.lazyspec.md
changed=$(git diff --name-only HEAD | tr '\n' ' ')
is "a specification moved alone" "$changed" "services/api/specs/billing.lazyspec.md "
echo '// touched' >> services/api/specs/billing.lazyspec.test.js
changed=$(git diff --name-only HEAD | wc -l | tr -d ' ')
is "specification and test move together" "$changed" "2"
git checkout -q -- .

echo '// new behaviour' >> services/api/src/billing.js
spec_changed=$(git diff --name-only HEAD | grep -c '\.lazyspec\.md$')
is "code changed with no requirement touched" "$spec_changed" "0"
git checkout -q -- .

# --------------------------------------------------------------- G. config

sect "G. configuration"
sets=$(grep -c 'root:' .lazyspec.yaml)
is ".lazyspec.yaml declares one set per package" "$sets" "4"
mv .lazyspec.yaml .lazyspec.yaml.off
found=$(git ls-files --cached --others --exclude-standard '*.lazyspec.md' | wc -l | tr -d ' ')
is "with no config, every specification still counts" "$found" "4"
mv .lazyspec.yaml.off .lazyspec.yaml

# ------------------------------------------- H. migrating existing names

sect "H. migrating from spec-kit, keeping its filenames"
mkdir -p "$DEMO/specs/001-billing"
cat > "$DEMO/specs/001-billing/spec.md" <<'EOF'
# Billing

## Refunds Never Exceed What Was Captured

- A refund above the captured amount is refused.
EOF
cat > "$DEMO/specs/001-billing/plan.md" <<'EOF'
Notes, not a specification.
EOF
is "before: a spec-kit file is not locked" "$(guard "$(edit specs/001-billing/spec.md)")" 0

printf 'specs/[^/]*/spec\\.md\n' > "$DEMO/.lazyspec-locked"
is "after: the named files are locked"   "$(guard "$(edit specs/001-billing/spec.md)")" 2
is "its neighbours are left alone"       "$(guard "$(edit specs/001-billing/plan.md)")" 0
is "ordinary code is left alone"         "$(guard "$(edit services/api/src/billing.js)")" 0
is "the built-in name stays locked too"  "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 2
is "shell writes to it are refused too"  "$(guard "$(shell 'sed -i s/a/b/ specs/001-billing/spec.md')")" 2
touch "$DEMO/.lazyspec-unlock"
is "and /lazyspec still opens the window" "$(guard "$(edit specs/001-billing/spec.md)")" 0
rm -f "$DEMO/.lazyspec-unlock"

printf '' > "$DEMO/.lazyspec-locked"
is "an empty file locks nothing extra"   "$(guard "$(edit specs/001-billing/spec.md)")" 0
is "...and still locks the built-in name" "$(guard "$(edit services/api/specs/billing.lazyspec.md)")" 2
rm -f "$DEMO/.lazyspec-locked"

# ---------------------------------------------------------------- report

printf '\n%s\n' "----------------------------------------"
printf 'sandbox: %s passed, %s failed\n' "$pass" "$fail"
printf 'demo repo left at %s\n' "$DEMO"
[ "$fail" -eq 0 ]
