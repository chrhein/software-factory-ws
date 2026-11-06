#!/usr/bin/env bash
# Kjør de samme sakene uten å shippe, la dommeren gi poeng og kast endringene etterpå.
# Bruk: factory/bench.sh
set -uo pipefail
git diff --quiet -- factory ':!factory/context.md' || { echo "Commit factory/ først, så vet vi hvilken versjon poengene hører til."; exit 1; }
for ticket in backlog/01-total-ignorerer-antall.md backlog/06-gratis-frakt-rabatt.md; do
  factory/run.sh "$ticket" --dry-run
  run=$(ls -d runs/"$(basename "$ticket" .md)"-* | tail -1)
  factory/judge.sh "$run"
  git restore src factory/context.md && git clean -fdq src
done
echo; echo "── Snittpoeng per versjon av factory/"
node -e '
const scores = {};
for (const r of require("fs").readFileSync("runs/log.jsonl", "utf8").trim().split("\n").map(JSON.parse))
  if (r.stage === "score") (scores[r.ver] ??= []).push(r.score);
console.table(Object.fromEntries(Object.entries(scores).map(([ver, s]) => [ver, { kjøringer: s.length, snitt: +(s.reduce((a, b) => a + b, 0) / s.length).toFixed(1) }])));
'
