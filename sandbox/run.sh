#!/bin/sh
# Rebuild a throwaway consumer repo in sandbox/demo and run every scenario
# against it.
#
#   sh sandbox/run.sh
#
# The demo is its own git repository, so `git grep` and `git diff` see
# only the demo, and it is gitignored, so its specifications never turn up
# in this repository's own searches. sh sandbox/isolation.sh proves both.

SRC=$(cd "$(dirname "$0")/.." && pwd)
DEMO=$SRC/sandbox/demo
NOTICE='> **lazyspec.** Humans edit freely. Agents change this only through
> `/lazyspec`, with its tests, in one edit.
>
> Each `##` heading is one requirement. Its test repeats that heading as
> its own name — to find it, search the tests for that text.'
pass=0; fail=0

ok()  { pass=$((pass + 1)); printf '    ok    %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '    FAIL  %s\n' "$1"; }
is()  { [ "$2" = "$3" ] && ok "$1" || bad "$1 -- got '$2', wanted '$3'"; }
sect(){ printf '\n%s\n' "$1"; }

spec() { # spec <path>, body on stdin - every specification gets the notice
  mkdir -p "$(dirname "$DEMO/$1")"
  { printf '%s\n\n' "$NOTICE"; cat; } > "$DEMO/$1"
}

# ---------------------------------------------------------------- build

rm -rf "$DEMO"
mkdir -p "$DEMO"
cd "$DEMO" || exit 1
git init -q .
git config user.email demo@example.com
git config user.name demo

# install, the way README.md says to
mkdir -p .claude/skills .agents/skills
cp -R "$SRC"/skills/. .claude/skills/
cp -R "$SRC"/skills/. .agents/skills/

printf '<!-- lazyspec:begin -->\n' > AGENTS.md
cat "$SRC/INSTRUCTION.md" >> AGENTS.md
printf '<!-- lazyspec:end -->\n' >> AGENTS.md
printf '@AGENTS.md\n' > CLAUDE.md

cat > .claude/settings.json <<SETTINGS
{
  "claudeMdExcludes": ["$SRC/CLAUDE.md", "$SRC/AGENTS.md"]
}
SETTINGS

cat > .lazyspec.yaml <<'YAML'
sets:
  - root: services/api
    specs: specs/*.lazyspec.md
    covers: |
      The HTTP contract a caller can observe. Not internal helpers.
  - root: services/ledger
    specs: specs/*.lazyspec.md
    covers: |
      Double-entry invariants that must hold after any posting.
  - root: services/router
    specs: specs/*.lazyspec.md
    covers: |
      How a request is matched to a handler, and what happens when none is.
  - root: apps/web
    specs: specs/*.lazyspec.md
    covers: |
      What a person can see and do in the browser, proved end to end.
      Not component internals, and never a CSS class.
YAML

# --- a JavaScript service
mkdir -p services/api/src
spec services/api/specs/billing.lazyspec.md <<'EOF'
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
# the rest of a real suite: married to nothing, and correctly so
cat > services/api/src/billing.unit.test.js <<'EOF'
describe('roundHalfEven', () => {
  it('rounds .5 to the nearest even minor unit', () => {});
});
EOF
mkdir -p services/api/tests
cat > services/api/tests/billing.db.test.js <<'EOF'
describe('captures table', () => {
  it('rolls back a partial write', () => {});
});
EOF

# --- a Python service
mkdir -p services/ledger/tests services/ledger/src
spec services/ledger/specs/postings.lazyspec.md <<'EOF'
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
spec services/router/specs/routing.lazyspec.md <<'EOF'
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
spec apps/web/specs/checkout.lazyspec.md <<'EOF'
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
printf '# Wire protocol\nNot ours.\n' > vendor/proto/SPEC.md

git add -A >/dev/null 2>&1
git commit -qm "demo baseline"

printf 'built %s\n' "$DEMO"

# ------------------------------------------------------------- A. install

sect "A. install"
for d in .claude/skills .agents/skills; do
  [ -f "$DEMO/$d/lazyspec/SKILL.md" ] && ok "skills in $d" || bad "skills in $d"
done
for s in lazyspec lazyspec-setup lazyspec-validate; do
  n=$(sed -n 's/^name: *//p' "$DEMO/.claude/skills/$s/SKILL.md" | head -1)
  is "skill frontmatter name matches folder: $s" "$n" "$s"
done
grep -q 'lazyspec:begin' AGENTS.md && ok "instruction pasted between markers" || bad "markers"
is "CLAUDE.md is a one-line shim" "$(cat CLAUDE.md)" "@AGENTS.md"
grep -q 'lazyspec-validate' AGENTS.md && ok "the instruction names the check" || bad "instruction"
[ -f "$SRC/INSTRUCTION.md" ] && ok "the instruction ships beside the skills, for /lazyspec-setup" || bad "instruction not shipped"
if [ -e "$DEMO/lazyspec-guard" ]; then bad "something executable was installed"
else ok "nothing executable is installed"; fi

# --------------------------------------------------------- B. the notice

sect "B. the notice travels in the file"
head=$(sed -n '1,5p' "$DEMO/services/api/specs/billing.lazyspec.md")
is "a specification opens with the header" "$head" "$NOTICE"
case $head in *"/lazyspec"*) ok "it names /lazyspec" ;; *) bad "no /lazyspec" ;; esac
case $head in *[Aa]gents*) ok "it binds agents" ;; *) bad "does not say agents" ;; esac
case $head in *[Hh]umans*) ok "and leaves people alone" ;; *) bad "does not free humans" ;; esac
case $head in *"one requirement"*) ok "it says what a requirement is" ;; *) bad "no definition" ;; esac
case $head in *"search the tests"*) ok "and how to find its test" ;; *) bad "no way to find tests" ;; esac

unmarked=0
for f in $(find "$DEMO" -name '*.lazyspec.md'); do
  head -1 "$f" | grep -q 'lazyspec' || unmarked=$((unmarked + 1))
done
is "every specification carries one" "$unmarked" "0"

mkdir -p "$DEMO/copied"
cp "$DEMO/services/api/specs/billing.lazyspec.md" "$DEMO/copied/"
is "and it survives being copied anywhere" "$(sed -n '1,5p' "$DEMO/copied/billing.lazyspec.md")" "$NOTICE"
rm -rf "$DEMO/copied"

# ------------------------------------------------- C. searching for proof

sect "C. searching for proof"
find_proof() {
  git grep --untracked -l -F -e "$1" -- . 2>/dev/null \
    | grep -v '\.lazyspec\.md$' | grep -v '^AGENTS.md$' | grep -v '^CLAUDE.md$' \
    | grep -v '^\.claude/' | grep -v '^\.agents/' | tr '\n' ' '
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

# The words say a file is the proof. The name says it is the right one:
# it carries the specification's stem, capitals and separators aside.
carries() {
  stem=$(basename "$1" | sed 's/\.lazyspec\.md$//' | tr 'A-Z' 'a-z' | tr -d '_-')
  file=$(basename "$2" | tr 'A-Z' 'a-z' | tr -d '_-')
  case $file in *"$stem"*) return 0 ;; *) return 1 ;; esac
}
for pair in \
  "services/api/specs/billing.lazyspec.md|services/api/specs/billing.lazyspec.test.js" \
  "services/ledger/specs/postings.lazyspec.md|services/ledger/tests/test_postings.py" \
  "services/router/specs/routing.lazyspec.md|services/router/routing_test.go" \
  "apps/web/specs/checkout.lazyspec.md|apps/web/CheckoutTest.java"; do
  carries "${pair%%|*}" "${pair##*|}" \
    || bad "$(basename "${pair##*|}") does not carry its specification's stem"
done
ok "each proof file carries the stem, whatever the language calls it"
carries "services/api/specs/billing.lazyspec.md" "services/ledger/tests/test_postings.py" \
  && bad "a foreign test file matched the stem" \
  || ok "a test file for another specification does not"

n=$(grep -c '^## ' services/api/specs/billing.lazyspec.md)
m=$(grep '^## ' services/api/specs/billing.lazyspec.md | grep -vc 'no-test')
is "no-test requirements are skipped" "$n/$m" "3/2"

hits=$(git grep --untracked -l -F -e 'Refunds Never Exceed What Was Captured' -- . | tr '\n' ' ')
case $hits in
  *AGENTS.md*) ok "the pasted instruction hits, as expected" ;;
  *) bad "expected AGENTS.md to hit" ;;
esac
grep -q 'lazyspec:begin' AGENTS.md && ok "...inside markers, so it is discountable" || bad "markers"

cp services/api/specs/billing.lazyspec.md services/ledger/specs/copy.lazyspec.md
dups=$(git grep --untracked -l -F -e 'Refunds Never Exceed What Was Captured' -- . | grep -c '\.lazyspec\.md$')
is "one heading in two specifications is visible" "$dups" "2"
rm services/ledger/specs/copy.lazyspec.md

cp services/api/specs/billing.lazyspec.md services/ledger/specs/billing.lazyspec.md
if [ "$(find . -name 'billing.lazyspec.md' | wc -l | tr -d ' ')" = "2" ]; then
  ok "the same stem lives in two roots, told apart by root"
else bad "monorepo"; fi
rm services/ledger/specs/billing.lazyspec.md

# --------------------------------------------------- D. judging a change

sect "C1. the rest of the suite marries nothing"
is "a unit test states no requirement" \
   "$(git grep --untracked -l -F -e 'Refunds Never Exceed What Was Captured' -- services/api/src/billing.unit.test.js | wc -l | tr -d ' ')" "0"
is "a database test states no requirement" \
   "$(git grep --untracked -l -F -e 'Refunds Never Exceed What Was Captured' -- services/api/tests/billing.db.test.js | wc -l | tr -d ' ')" "0"
is "the married test is still the only proof" "$(find_proof 'Refunds Never Exceed What Was Captured')" \
   "services/api/specs/billing.lazyspec.test.js "
extra=$(ls services/api/src/billing.unit.test.js services/api/tests/billing.db.test.js 2>/dev/null | wc -l | tr -d ' ')
is "they sit beside it, sharing its name, unbothered" "$extra" "2"

sect "C2. an orphaned specification test"
# the convention makes the name a claim, so it can be checked backwards
orphans() {
  for t in $(find . -name '*.lazyspec.test.*'); do
    stem=$(basename "$t" | sed 's/\.lazyspec\.test\..*$//')
    [ -f "$(dirname "$t")/$stem.lazyspec.md" ] || echo "$t"
  done
}
is "no orphans while the specification is there" "$(orphans | wc -l | tr -d ' ')" "0"
mv services/api/specs/billing.lazyspec.md services/api/specs/payments.lazyspec.md
is "renaming the specification orphans its test" "$(orphans | tr -d ' ')" "./services/api/specs/billing.lazyspec.test.js"
mv services/api/specs/payments.lazyspec.md services/api/specs/billing.lazyspec.md
is "and putting it back clears the orphan" "$(orphans | wc -l | tr -d ' ')" "0"
unit=$(orphans | grep -c 'unit.test' || true)
is "an ordinary test is never an orphan" "$unit" "0"

sect "D. judging a change"
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

# ------------------------------------------------------- E. configuration

sect "E. configuration"
sets=$(grep -c 'root:' .lazyspec.yaml)
is ".lazyspec.yaml declares one set per package" "$sets" "4"
covers=$(grep -c 'covers:' .lazyspec.yaml)
is "every set says what it covers" "$covers" "4"
api=$(sed -n '/root: services\/api/,/covers:/p' .lazyspec.yaml | tail -1)
web=$(sed -n '/root: apps\/web/,/covers:/p' .lazyspec.yaml | tail -1)
[ -n "$api" ] && [ -n "$web" ] && ok "two sets each declare their own level" \
  || bad "a set is missing its level"
mv .lazyspec.yaml .lazyspec.yaml.off
found=$(git ls-files --cached --others --exclude-standard '*.lazyspec.md' | wc -l | tr -d ' ')
is "with no config, every specification still counts" "$found" "4"
mv .lazyspec.yaml.off .lazyspec.yaml

# ---------------------------------------------------------------- report

printf '\n%s\n' "----------------------------------------"
printf 'sandbox: %s passed, %s failed\n' "$pass" "$fail"
printf 'demo repo left at %s\n' "$DEMO"
[ "$fail" -eq 0 ]
