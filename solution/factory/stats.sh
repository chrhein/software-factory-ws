#!/usr/bin/env bash
# Mål fabrikken: kostnad og tid per steg, hvor ofte verify består, og hvor ofte et menneske godtok resultatet.
jq -s '
  { stages: (map(select(.usd)) | group_by(.stage) | map({stage: .[0].stage, runs: length, usd: (map(.usd) | add * 100 | round / 100), sec: (map(.sec) | add)})),
    verify:   (map(select(.stage == "5-verify")) | {pass: map(select(.ok)) | length, total: length}),
    human:    (map(select(.stage == "human"))    | {accepted: map(select(.accepted)) | length, total: length}) }' runs/log.jsonl
