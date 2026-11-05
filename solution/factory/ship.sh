#!/usr/bin/env bash
# Et menneske godkjenner, CI kjører, og endringen blir shippet. Eller så sier mennesket nei.
# Bruk: factory/ship.sh <kjøremappe> [yes|no]
set -euo pipefail
run=$1; answer=${2:-yes}
log() { echo "{\"run\":\"$run\",\"stage\":\"human\",\"accepted\":$1}" >> runs/log.jsonl; }
if [ "$answer" = no ]; then git restore src && git clean -fdq src && log false && echo "Kastet."; exit 0; fi
title=$(sed -n 's/^# //p' "$run/0-ticket.md" | head -1)
git switch -c "factory/$(basename "$run")"
git add src && git commit -qm "fix: $title"
git push -qu origin HEAD
gh pr create --title "fix: $title" --body-file "$run/4-review.md"
git switch -q main
log true
