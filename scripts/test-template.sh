#!/usr/bin/env bash
# Self test for the template: agent and skill files are valid, and the PRD gate works.
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
fail() { echo "FAIL: $*"; exit 1; }
pass() { echo "ok: $*"; }

# 1. Frontmatter
for f in "$here"/template/.claude/agents/*.md; do
  n=$(basename "$f" .md)
  head -1 "$f" | grep -qx -- '---' || fail "$f has no frontmatter"
  grep -qx "name: $n" "$f" || fail "$f name does not match file name"
  grep -q '^description: ' "$f" || fail "$f has no description"
  grep -Eq '^model: (haiku|sonnet|opus)$' "$f" || fail "$f has no valid model"
done
pass "agents valid"
for f in "$here"/template/.claude/skills/*/SKILL.md; do
  n=$(basename "$(dirname "$f")")
  grep -qx "name: $n" "$f" || fail "$f name does not match folder"
  grep -q '^description: ' "$f" || fail "$f has no description"
done
for f in "$here"/.claude/skills/*/SKILL.md; do
  grep -qx "name: $(basename "$(dirname "$f")")" "$f" || fail "$f name does not match folder"
done
pass "skills valid"
python3 -m json.tool "$here/template/.claude/settings.json" >/dev/null || fail "settings.json invalid"
pass "settings.json valid"

# 2. New app scaffolding
fcopy="$tmp/factory"; mkdir -p "$fcopy" && cp -R "$here/scripts" "$fcopy/" && mkdir -p "$fcopy/template"
git -C "$fcopy" init -q && git -C "$fcopy" remote add origin https://github.com/dalhhorn-ship-it/Kidgames.git
( cd "$fcopy" && ! ./scripts/make-app.sh >/dev/null ) || fail "make-app.sh ran in the factory repo"
[[ -d "$fcopy/template" ]] || fail "make-app.sh touched the factory repo"
pass "make-app.sh refuses to run in the factory repo"
git config --global user.email >/dev/null 2>&1 || export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
# Same as GitHub "Use this template": a copy of the whole factory repo, then make-app.sh.
app="$tmp/app"
mkdir -p "$app" && (cd "$here" && tar --exclude=.git -cf - .) | tar -xf - -C "$app"
git -C "$app" init -q && git -C "$app" remote add origin https://github.com/someone/space-bunnies.git
git -C "$app" add -A && git -C "$app" commit -qm "Initial commit"
( cd "$app" && ./scripts/make-app.sh >/dev/null ) || fail "make-app.sh failed"
[[ ! -e "$app/template" && ! -e "$app/learnings" && ! -e "$app/scripts/make-app.sh" ]] || fail "factory files left in app"
grep -q "^# App Factory" "$app/CLAUDE.md" || fail "app CLAUDE.md not in place"
grep -Eq '^started: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$app/.factory" || fail ".factory start date not set"
( cd "$app" && git add -A && git commit -qm "chore: start app from kidgames template" )
[[ -x "$app/.claude/hooks/prd-gate.sh" ]] || fail "hook not executable in new app"
grep -q '^factory_repo: ' "$app/.factory" || fail ".factory missing factory_repo"
grep -q '^started:' "$app/.factory" || fail ".factory missing started"
[[ -f "$app/.claude/skills/retro/SKILL.md" && -f "$app/docs/FRICTION.md" ]] || fail "retro files missing"
for f in "$here"/template/.claude/skills/*/SKILL.md "$here"/template/.claude/agents/*.md; do
  rel="${f#"$here"/template/}"
  git -C "$app" ls-files --error-unmatch "$rel" >/dev/null 2>&1 || fail "$rel is not committed in a new app (gitignore?)"
done
pass "make-app.sh turns a template copy into an app linked to the factory"

hook() { printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":"x"}}' "$1" \
  | CLAUDE_PROJECT_DIR="$app" "$app/.claude/hooks/prd-gate.sh" 2>/dev/null; }
expect() { local want=$1 path=$2 got=0; hook "$path" || got=$?; [[ $got -eq $want ]] || fail "hook $path: want $want got $got"; }

# 3. Gate closed before signoff
expect 0 "$app/docs/PRD.md"
expect 0 "$app/CLAUDE.md"
expect 2 "$app/src/main.ts"
expect 2 "$app/docs/PRD.approved"
expect 2 "$app/scripts/signoff.sh"
expect 2 "$app/.claude/settings.json"
pass "gate blocks code before signoff"

# 4. Signoff requires READY status, and the approval hook stamps only on a real approve
approve() { printf '%s' "$1" | CLAUDE_PROJECT_DIR="$app" "$app/.claude/hooks/prd-approve.sh" >/dev/null; }
unstamp() { rm "$app/docs/PRD.approved"; sed -i.bak 's/Status: APPROVED by .*/Status: READY FOR SIGNOFF/' "$app/docs/PRD.md"; }
q="Approve this PRD so we can start building?"
( cd "$app" && ! ./scripts/signoff.sh "Founder" >/dev/null ) || fail "signed a template PRD"
sed -i.bak 's/Status: TEMPLATE/Status: READY FOR SIGNOFF/' "$app/docs/PRD.md"
approve "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"AskUserQuestion\",\"tool_response\":{\"answers\":{\"$q\":\"Change something\"}}}"
approve '{"hook_event_name":"UserPromptSubmit","prompt":"looks good but do not approve yet"}'
[[ ! -f "$app/docs/PRD.approved" ]] || fail "hook stamped without approval"
approve "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"AskUserQuestion\",\"tool_response\":{\"answers\":{\"$q\":\"Approve\"}}}"
( cd "$app" && ./scripts/signoff.sh --check >/dev/null ) || fail "hook did not stamp after Approve"
unstamp
approve "{\"hook_event_name\":\"PostToolUse\",\"tool_name\":\"AskUserQuestion\",\"tool_response\":\"User has answered: \\\"$q\\\"=\\\"Approve\\\"\"}"
( cd "$app" && ./scripts/signoff.sh --check >/dev/null ) || fail "hook did not stamp from a text answer"
unstamp
approve '{"hook_event_name":"UserPromptSubmit","prompt":"Approve!"}'
grep -q 'Status: APPROVED by Founder' "$app/docs/PRD.md" || fail "status not flipped"
expect 0 "$app/src/main.ts"
expect 2 "$app/docs/PRD.approved"
pass "signoff opens the gate"

# 5. Changing the PRD closes the gate again
echo "* sneaky new feature" >> "$app/docs/PRD.md"
expect 2 "$app/src/main.ts"
( cd "$app" && ! ./scripts/signoff.sh --check >/dev/null ) || fail "check passed on changed PRD"
pass "PRD change closes the gate"

( cd "$app" && ./scripts/check.sh >/dev/null ) || fail "check.sh fails on empty app"
pass "check.sh runs on empty app"
echo "All template tests passed."
