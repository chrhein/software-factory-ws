#!/usr/bin/env bash
# Fabrikken: én sak gjennom alle stegene, med et menneske til slutt.
# Bruk: factory/run.sh backlog/<sak>.md
set -euo pipefail
ticket=$1
git diff --quiet -- src || { echo "src/ har endringer som ikke er committet. Ship eller kast dem først."; exit 1; }
run=runs/$(basename "$ticket" .md)-$(date +%H%M%S)
mkdir -p "$run"; cp "$ticket" "$run/0-ticket.md"
step() { echo; echo "── $1"; factory/stage.sh "$1" "$run"; }

step 1-triage
decision=$(head -1 "$run/1-triage.md")
case $decision in
  *needs-spec*)  step 2-spec
                 read -rp "Svar på spørsmålene i $run/2-spec.md, lagre og trykk Enter " ;;
  *automatable*) ;;
  *)             echo; echo "Stoppet: triage svarte «$decision». Se $run/1-triage.md"; exit 0 ;;
esac
step 3-build
step 4-review
echo; echo "── 5-verify"; factory/verify.sh "$run" || true
echo; echo "Din tur: Les git diff og $run/, og kjør så factory/ship.sh $run   (eller factory/ship.sh $run no)"
