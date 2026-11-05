#!/usr/bin/env bash
# Dommeren gir kjøringen poeng. Poengene logges sammen med hvilken versjon av factory/ som laget dem.
# Bruk: factory/judge.sh <kjøremappe>
set -euo pipefail
run=$1
factory/stage.sh 7-judge "$run"
score=$(sed -n 's/^SCORE: *\([0-9]*\).*/\1/p' "$run/7-judge.md" | head -1)
ver=$(git log -1 --format=%h -- factory)
echo "{\"run\":\"$run\",\"stage\":\"score\",\"score\":${score:-0},\"ver\":\"$ver\"}" >> runs/log.jsonl
