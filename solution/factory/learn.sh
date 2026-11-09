#!/usr/bin/env bash
# Den ytre loopen: Les hva dommeren skrev og hva mennesker rettet i spec-utkastene, og la en agent forbedre promptene.
# Bruk: factory/learn.sh   Endringene blir liggende uten commit, så du kan lese dem først.
set -euo pipefail
git diff --quiet -- factory ':!factory/context.md' || { echo "Commit factory/ først, så ser du bare det læresteget endrer."; exit 1; }
run=runs/learn-$(date +%H%M%S); mkdir -p "$run"
for f in runs/*/7-judge.md; do
  [ -e "$f" ] || continue
  echo "## Dommeren om $(dirname "$f")"; cat "$f"; echo
done > "$run/0-judge.md"
for f in runs/issue-*/1-spec.md; do
  [ -e "$f" ] || continue
  n=$(sed -n 's/^issue: *//p' "$(dirname "$f")/0-ticket.md" | head -1)
  echo "## Issue $n: utkastet fra spec-steget"; cat "$f"
  echo "## Issue $n: beskrivelsen slik et menneske har redigert den"; gh issue view "$n" --json body --jq .body; echo
done > "$run/0-specs.md"
[ -s "$run/0-judge.md" ] || [ -s "$run/0-specs.md" ] || { echo "Ingenting å lære av ennå. Kjør factory/bench.sh, eller gjør oppgave 12.2 og 12.3."; exit 1; }
factory/stage.sh 8-learn "$run"
echo; git diff --stat -- factory
