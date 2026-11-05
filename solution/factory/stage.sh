#!/usr/bin/env bash
# Ett steg: prompt + felles kontekst + alt tidligere i kjøringen → claude -p → en fil og en linje i loggen.
# Bruk: factory/stage.sh <steg> <kjøremappe>
set -euo pipefail
stage=$1; run=$2; mcp=""
case $stage in
  3-build)   tools="Read,Edit,Write,Glob,Grep,Bash(npm test:*),Bash(npm run build:*)" ;;
  5-check)   tools="mcp__playwright"; mcp=factory/mcp.json ;;
  6-monitor) tools="Read,Glob,Grep,Write" ;;
  *)         tools="Read,Glob,Grep,Bash(git diff:*),Bash(npm test:*)" ;;
esac
json=$({ cat "factory/$stage.md" factory/context.md; echo "<input>"; cat "$run"/*.md 2>/dev/null || true; echo "</input>"; } \
  | claude -p --output-format json --allowedTools "$tools" ${mcp:+--mcp-config "$mcp"} --max-budget-usd 1)
jq -r .result <<<"$json" > "$run/$stage.md"
jq -c --arg run "$run" --arg stage "$stage" '{run: $run, stage: $stage, usd: .total_cost_usd, sec: (.duration_ms / 1000 | floor)}' <<<"$json" >> runs/log.jsonl
grep '^LESSON:' "$run/$stage.md" | sed 's/^LESSON: */- /' >> factory/context.md || true
cat "$run/$stage.md"
