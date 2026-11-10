#!/usr/bin/env bash
# Ship uten at noen leser koden: pull request, CI, merge til main og en sjekk av main etterpå.
# Bruk: factory/ship.sh <kjøremappe>
set -euo pipefail
run=$1
title=$(sed -n 's/^# //p' "$run/0-ticket.md" | head -1)
issue=$(sed -n 's/^issue: *//p' "$run/0-ticket.md" | head -1)
end() { echo "$2" | tee "$run/9-end.md"; echo "{\"run\":\"$run\",\"stage\":\"end\",\"end\":\"${2%%:*}\",\"at\":\"$1\"}" >> runs/log.jsonl; }
ci()  { until id=$(gh run list --commit "$1" --json databaseId --jq '.[0].databaseId // empty') && [ -n "$id" ]; do sleep 5; done
        gh run watch "$id" --exit-status >/dev/null; }

git switch -qc "factory/$(basename "$run")"
git add src && git commit -qm "fix: $title"
git push -qu origin HEAD; sha=$(git rev-parse HEAD)
pr=$({ cat "$run/4-review.md"; [ -z "$issue" ] || printf '\nFixes #%s\n' "$issue"; } | gh pr create --title "fix: $title" --body-file -)
git switch -q main
echo "CI kjører på $pr"
ci "$sha" || { end ci "STOPPET: CI feilet på $pr"; exit 0; }
gh pr merge "$pr" --squash --delete-branch && git pull -q --no-rebase --ff-only
echo "Merget. Sjekker main …"
factory/check.sh "$run"
if head -1 "$run/check/5-check.md" | grep -q pass; then end ship "SHIPPET: $pr er merget til main, og sjekken etterpå gikk gjennom."
else end main "FEIL PÅ MAIN: $pr er merget, men sjekken ser fortsatt feilen."; [ -z "$issue" ] || gh issue reopen "$issue" || true; fi
