#!/usr/bin/env bash
# Ett steg: prompt + felles kontekst + alt tidligere i kjøringen → claude -p → en fil og en linje i loggen.
# Bruk: factory/stage.sh <steg> <kjøremappe>
set -euo pipefail
stage=$1; run=$2; mcp=""; deny=""
case $stage in
  2-test)    tools="Read,Glob,Grep,Edit(src/**/*.test.ts),Bash(npm test:*)" ;;
  3-build)   tools="Read,Glob,Grep,Edit(src/**),Bash(npm test:*),Bash(npm run build:*)"; deny="Edit(src/**/*.test.ts)" ;;
  5-check)   tools="mcp__playwright"; mcp=factory/mcp.json ;;
  6-monitor) tools="Read,Glob,Grep,Bash(gh issue list:*)" ;;
  8-learn)   tools="Read,Glob,Grep,Edit(factory/*.md)"; deny="Edit(factory/7-judge.md),Edit(factory/8-learn.md)" ;;
  *)         tools="Read,Glob,Grep,Bash(git diff:*),Bash(git status:*),Bash(npm test:*)" ;;
esac
start=$(date +%s)
out=$({ cat "factory/$stage.md" factory/context.md; echo "<input>"; cat "$run"/*.md 2>/dev/null || true; echo "</input>"; } \
  | claude -p --permission-mode dontAsk --allowedTools "$tools" ${deny:+--disallowedTools "$deny"} ${mcp:+--mcp-config "$mcp"} --max-budget-usd 1)
printf '%s\n' "$out" > "$run/$stage.md"
echo "{\"run\":\"$run\",\"stage\":\"$stage\",\"sec\":$(( $(date +%s) - start ))}" >> runs/log.jsonl
grep '^LESSON:' "$run/$stage.md" | sed 's/^LESSON: */- /' >> factory/context.md || true
cat "$run/$stage.md"
