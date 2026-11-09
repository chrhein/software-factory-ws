#!/usr/bin/env bash
# Ett steg med Copilot CLI: prompt + felles kontekst + alt tidligere i kjøringen → copilot -p → en fil og en linje i loggen.
# Bruk: factory/stage.sh <steg> <kjøremappe>
set -euo pipefail
stage=$1; run=$2; mcp=""; deny=""
tests=$(cd src/lib && ls *.test.ts | sed 's/.*/write(&)/' | paste -sd, -)
case $stage in
  2-test)    tools="read,shell(npm test),$tests" ;;
  3-build)   tools="read,write,shell(npm test),shell(npm run build)"; deny=$tests ;;
  5-check)   tools="playwright"; mcp='{"mcpServers":{"playwright":{"type":"local","command":"npx","args":["-y","@playwright/mcp@0.0.83","--isolated"],"tools":["*"]}}}' ;;
  6-monitor) tools="read,shell(gh issue list)" ;;
  8-learn)   tools="read,$(cd factory && ls [1-6]-*.md context.md | sed 's/.*/write(&)/' | paste -sd, -)" ;;
  *)         tools="read,shell(git diff),shell(git status),shell(npm test)" ;;
esac
prompt=$(cat "factory/$stage.md" factory/context.md; echo "<input>"; cat "$run"/*.md 2>/dev/null || true; echo "</input>")
start=$(date +%s)
copilot -p "$prompt" -s --no-ask-user --allow-tool="$tools" ${deny:+--deny-tool="$deny"} ${mcp:+--additional-mcp-config "$mcp"} > "$run/$stage.md"
echo "{\"run\":\"$run\",\"stage\":\"$stage\",\"sec\":$(( $(date +%s) - start ))}" >> runs/log.jsonl
grep '^LESSON:' "$run/$stage.md" | sed 's/^LESSON: */- /' >> factory/context.md || true
cat "$run/$stage.md"
