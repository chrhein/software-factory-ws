#!/usr/bin/env bash
# Ship uten at noen leser koden: pull request, CI, merge, deploy og en sjekk i produksjon.
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
gh pr merge "$pr" --squash --delete-branch && git pull -q
echo "Merget. Venter på deploy …"
ci "$(gh pr view "$pr" --json mergeCommit --jq .mergeCommit.oid)" || { end deploy "STOPPET: $pr er merget, men deploy feilet."; exit 0; }
factory/check.sh "$run" "$(gh api 'repos/{owner}/{repo}/pages' --jq .html_url)"
if head -1 "$run/check/5-check.md" | grep -q pass; then end ship "SHIPPET: $pr er i produksjon, og sjekken der gikk gjennom."
else end prod "FEIL I PRODUKSJON: $pr er ute, men sjekken ser fortsatt feilen."; [ -z "$issue" ] || gh issue reopen "$issue" || true; fi
