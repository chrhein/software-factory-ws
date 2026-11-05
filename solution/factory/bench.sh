#!/usr/bin/env bash
# Kjør de samme sakene på nytt, la dommeren gi poeng og kast endringene etterpå.
# Bruk: factory/bench.sh
set -uo pipefail
git diff --quiet -- factory ':!factory/context.md' || { echo "Commit factory/ først, så vet vi hvilken versjon poengene hører til."; exit 1; }
for ticket in backlog/02-totalt-uten-frakt.md backlog/06-gratis-frakt-rabatt.md; do
  factory/run.sh "$ticket" </dev/null
  run=$(ls -d runs/"$(basename "$ticket" .md)"-* | tail -1)
  factory/judge.sh "$run"
  git restore src factory/context.md && git clean -fdq src
done
echo; echo "── Snittpoeng per versjon av factory/"
jq -s 'map(select(.stage == "score")) | group_by(.ver) | map({ver: .[0].ver, runs: length, snitt: (map(.score) | add / length * 10 | round / 10)})' runs/log.jsonl
