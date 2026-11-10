#!/usr/bin/env bash
# Fabrikken: én sak gjennom alle stegene og ut i produksjon. Stopper en sperre saken, får et menneske den.
# Bruk: factory/run.sh <sak.md> [--dry-run]   --dry-run stopper før ship og lar endringen ligge i src/.
set -Eeuo pipefail
ticket=$1
git diff --quiet -- src || { echo "src/ har endringer som ikke er committet. Kast dem med: git restore src"; exit 1; }
git pull -q --no-rebase --ff-only
run=runs/$(basename "$ticket" .md)-$(date +%H%M%S)
mkdir -p "$run"; cp "$ticket" "$run/0-ticket.md"
step() { echo; echo "── $1"; factory/stage.sh "$1" "$run"; }
log()  { echo "{\"run\":\"$run\",\"stage\":\"end\",\"end\":\"$(head -1 "$run/9-end.md" | cut -d: -f1)\",\"at\":\"$1\"}" >> runs/log.jsonl; }
stop() { git restore src && git clean -fdq src; { echo "STOPPET: $2"; echo; cat "$3"; } | tee "$run/9-end.md"; log "$1"; exit 0; }
trap 'stop krasj "et steg krasjet." /dev/null' ERR

step 1-triage
if head -1 "$run/1-triage.md" | grep -q needs-spec; then
  step 1-spec
  stop spec "saken trenger en spec. Rett utkastet, lim det inn i beskrivelsen og sett på labelen factory igjen." "$run/1-spec.md"
fi
head -1 "$run/1-triage.md" | grep -q automatable || stop triage "triage vil at et menneske ser på saken." "$run/1-triage.md"
step 2-test
step 3-build
step 4-review
echo; echo "── 5-verify"
factory/verify.sh "$run"                     || stop verify "verify sa nei." "$run/5-verify.md"
head -1 "$run/4-review.md" | grep -q approve || stop review "review sa nei." "$run/4-review.md"
[ "${2:-}" != --dry-run ] || { echo; echo "Tørrkjøring: endringen ligger i src/."; exit 0; }
echo; echo "── ship"
factory/ship.sh "$run"
