#!/bin/sh
# Everything that has to be true before a single requirement is written:
# the manifests, the skills the plugin carries, each install route the
# README describes, and the paste /lazyspec-setup performs.
#
#   sh sandbox/install.sh
#
# Nothing here needs the plugin to be installed. It checks that what
# ships would install, and that the documentation matches what ships.

SRC=$(cd "$(dirname "$0")/.." && pwd)
WORK=$SRC/sandbox/install-demo
pass=0; fail=0
ok()  { pass=$((pass + 1)); printf '    ok    %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '    FAIL  %s\n' "$1"; }
is()  { [ "$2" = "$3" ] && ok "$1" || bad "$1 -- got '$2', wanted '$3'"; }
sect(){ printf '\n%s\n' "$1"; }
j()   { node -e "const d=require('$1');console.log(eval('d$2')??'')" 2>/dev/null; }

# ------------------------------------------------------- A. the manifests

sect "A. the manifests"
for m in .claude-plugin/plugin.json .claude-plugin/marketplace.json \
         .cursor-plugin/plugin.json .cursor-plugin/marketplace.json \
         .codex-plugin/plugin.json .codex-plugin/marketplace.json; do
  node -e "JSON.parse(require('fs').readFileSync('$SRC/$m'))" 2>/dev/null \
    && ok "$m parses" || bad "$m is not valid JSON"
done

# `/plugin install lazyspec@lazyspec` is plugin@marketplace, so both names
# have to be what the README types.
is "marketplace is named lazyspec" "$(j "$SRC/.claude-plugin/marketplace.json" .name)" "lazyspec"
is "the plugin inside it is named lazyspec" \
   "$(j "$SRC/.claude-plugin/marketplace.json" .plugins[0].name)" "lazyspec"
grep -q '/plugin install lazyspec@lazyspec' "$SRC/README.md" \
  && ok "README types that pair exactly" || bad "README install command disagrees"

# source "./" makes the plugin root the repository root, which is the only
# reason ${CLAUDE_PLUGIN_ROOT}/INSTRUCTION.md resolves.
is "claude marketplace source is ./" "$(j "$SRC/.claude-plugin/marketplace.json" .plugins[0].source)" "./"
is "cursor marketplace source is ./" "$(j "$SRC/.cursor-plugin/marketplace.json" .plugins[0].source)" "./"
[ -f "$SRC/INSTRUCTION.md" ] && ok "so INSTRUCTION.md sits at the plugin root" \
  || bad "INSTRUCTION.md is not where the plugin root would put it"
grep -q 'CLAUDE_PLUGIN_ROOT}/INSTRUCTION.md' "$SRC/skills/lazyspec-setup/SKILL.md" \
  && ok "and the setup skill looks for it there" || bad "setup skill looks elsewhere"

# Claude discovers skills/; Cursor and Codex are told, as a string. This
# is the shape superpowers and episodic-memory ship.
is "claude declares no skills key" "$(j "$SRC/.claude-plugin/plugin.json" .skills)" ""
is "cursor declares the skills string" "$(j "$SRC/.cursor-plugin/plugin.json" .skills)" "./skills/"
is "codex declares the skills string" "$(j "$SRC/.codex-plugin/plugin.json" .skills)" "./skills/"
v=$(j "$SRC/.claude-plugin/plugin.json" .version)
is "cursor ships the same version" "$(j "$SRC/.cursor-plugin/plugin.json" .version)" "$v"
is "codex ships the same version"  "$(j "$SRC/.codex-plugin/plugin.json" .version)" "$v"

# ------------------------------------------------ B. what the plugin carries

sect "B. what the plugin carries"
n=$(ls -d "$SRC"/skills/*/ | wc -l | tr -d ' ')
is "three skills ship" "$n" "3"
grep -q 'It is three skills' "$SRC/AGENTS.md" && ok "AGENTS.md says three" || bad "AGENTS.md miscounts the skills"
for d in "$SRC"/skills/*/; do
  name=$(basename "$d")
  [ -f "$d/SKILL.md" ] || { bad "$name has no SKILL.md"; continue; }
  declared=$(sed -n 's/^name: *//p' "$d/SKILL.md" | head -1)
  is "$name declares its own directory name" "$declared" "$name"
  desc=$(sed -n 's/^description: *//p' "$d/SKILL.md" | head -1)
  [ -n "$desc" ] && ok "$name has a description for the skill list" \
    || bad "$name has no description, so nothing will know when to run it"
done
for s in lazyspec lazyspec-setup lazyspec-validate; do
  grep -q "/$s\b" "$SRC/README.md" && ok "README names /$s" || bad "README never names /$s"
done

# --------------------------------------------- C. the clone-and-copy route

sect "C. the clone-and-copy route"
rm -rf "$WORK"; mkdir -p "$WORK"; cd "$WORK" || exit 1
git init -q .; git config user.email a@b.c; git config user.name t
printf 'print("hello")\n' > main.py
printf '# Someone else project\n\nRules we already keep.\n' > CONSTITUTION.md
git add -A >/dev/null; git commit -qm initial

mkdir -p .claude/skills .agents/skills
cp -R "$SRC"/skills/. .claude/skills/
cp -R "$SRC"/skills/. .agents/skills/
is "Claude Code and opencode find three skills" "$(ls .claude/skills | wc -l | tr -d ' ')" "3"
is "Codex and opencode find three skills"       "$(ls .agents/skills | wc -l | tr -d ' ')" "3"

# the product itself, not just the skills that place it
cp "$SRC/INSTRUCTION.md" .claude/skills/
cp "$SRC/INSTRUCTION.md" .agents/skills/
[ -f .claude/skills/INSTRUCTION.md ] && [ -f .agents/skills/INSTRUCTION.md ] \
  && ok "the instruction lands beside them, so setup needs no network" \
  || bad "the instruction is not on disk after a copy install"
grep -q 'cp /tmp/lazyspec/INSTRUCTION.md .claude/skills/' "$SRC/README.md" \
  && ok "README prints that copy too" || bad "README's copy route drops the instruction"
grep -q 'cp -R /tmp/lazyspec/skills/\. \.claude/skills/' "$SRC/README.md" \
  && ok "README prints the command that does this" || bad "README's copy command differs"

# ------------------------------------------------ D. what /lazyspec-setup does

sect "D. what /lazyspec-setup does"
paste_it() { # its step 3, by hand, into the file its step 2 would choose
  { sed '/<!-- lazyspec:begin -->/,$d' CONSTITUTION.md
    printf '<!-- lazyspec:begin -->\n'
    cat "$SRC/INSTRUCTION.md"
    printf '<!-- lazyspec:end -->\n'
    sed -n '/<!-- lazyspec:end -->/,$p' CONSTITUTION.md | tail -n +2
  } > .tmp && mv .tmp CONSTITUTION.md
}
paste_it
grep -q 'Rules we already keep' CONSTITUTION.md \
  && ok "it goes beside rules the team already keeps" || bad "it replaced their file"
grep -q 'lazyspec:begin' CONSTITUTION.md && ok "between markers" || bad "no markers"
node -e "
const fs=require('fs');
const body=fs.readFileSync('$SRC/INSTRUCTION.md','utf8').trim();
process.exit(fs.readFileSync('CONSTITUTION.md','utf8').includes(body)?0:1)" \
  && ok "word for word, so a reader gets the whole rule" || bad "the paste is not verbatim"

before=$(cat CONSTITUTION.md); paste_it
[ "$before" = "$(cat CONSTITUTION.md)" ] && ok "running it again changes nothing" \
  || bad "a second run is not idempotent"
is "and never doubles the markers" "$(grep -c 'lazyspec:begin' CONSTITUTION.md)" "1"

printf '@AGENTS.md\n' > CLAUDE.md
printf '# Rules\n\nSee CONSTITUTION.md\n' > AGENTS.md
lines=$(wc -l < CLAUDE.md | tr -d ' ')
[ "$lines" -le 2 ] && ok "Claude Code gets a pointer, not a copy" || bad "CLAUDE.md holds content"
node -e "
const fs=require('fs');
const inst=fs.readFileSync('$SRC/INSTRUCTION.md','utf8').trim();
const dup=['CLAUDE.md','AGENTS.md'].filter(f=>fs.readFileSync(f,'utf8').includes(inst));
process.exit(dup.length?1:0)" \
  && ok "no second copy to drift" || bad "the instruction is in two files"

# ------------------------------------------------- E. what the README claims

sect "E. what the README claims"
grep -qE 'https?://[^ ]*INSTRUCTION\.md' "$SRC/skills/lazyspec-setup/SKILL.md" \
  && bad "setup would fetch the instruction over the network" \
  || ok "setup never fetches the instruction, so it cannot paste a stranger's"
grep -q 'stop and ask for it' "$SRC/skills/lazyspec-setup/SKILL.md" \
  && ok "it stops and asks when the file is missing" || bad "no answer when it is missing"
grep -q 'lazyspec-setup' "$SRC/README.md" && ok "README sends you to /lazyspec-setup after installing" \
  || bad "README never mentions the step that does the work"

cd "$SRC" || exit 1
rm -rf "$WORK"
printf '\n%s\n' "----------------------------------------"
printf 'install: %s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
