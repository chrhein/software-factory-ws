#!/usr/bin/env bash
# Ett steg med Codex CLI: prompt + felles kontekst + alt tidligere i kjøringen → codex exec → en fil og en linje i loggen.
# Bruk: factory/stage.sh <steg> <kjøremappe>
set -euo pipefail
{ # Bash leser hele blokken før den kjører, så en endret stage.sh slår ikke inn midt i kjøringen.
stage=$1; run=$2; conf=""; keep=""
case $stage in
  2-test)    sandbox=workspace-write; keep=$(find src -type f ! -name '*.test.ts') ;;
  3-build)   sandbox=workspace-write; keep=$(find src -name '*.test.ts') ;;
  5-check)   sandbox=read-only; conf='mcp_servers.playwright={command="npx",args=["-y","@playwright/mcp@0.0.83","--isolated"]}' ;;
  6-monitor) sandbox=workspace-write; conf='sandbox_workspace_write.network_access=true'; keep=$(find src backlog -type f) ;;
  *)         sandbox=read-only ;;
esac
# Codex har ingen verktøyliste per fil. Låste filer tas vare på før steget og settes tilbake hvis agenten endret dem.
keep="$keep factory/*.sh factory/7-judge.md factory/8-learn.md"
snap=$(mktemp); tar cf "$snap" $keep 2>/dev/null || true; before=$(shasum $keep 2>/dev/null || true)
start=$(date +%s)
{ cat "factory/$stage.md" factory/context.md; echo "<input>"; cat "$run"/*.md 2>/dev/null || true; echo "</input>"; } \
  | codex exec --sandbox "$sandbox" ${conf:+-c "$conf"} -o "$run/$stage.md" - > /dev/null
[ "$(shasum $keep 2>/dev/null || true)" = "$before" ] || { tar xf "$snap"; echo "$stage endret låste filer. stage.sh satte dem tilbake." >&2; }
echo "{\"run\":\"$run\",\"stage\":\"$stage\",\"sec\":$(( $(date +%s) - start ))}" >> runs/log.jsonl
grep '^LESSON:' "$run/$stage.md" | sed 's/^LESSON: */- /' >> factory/context.md || true
cat "$run/$stage.md"
exit; }
