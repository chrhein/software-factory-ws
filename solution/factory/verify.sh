#!/usr/bin/env bash
# Verify er vanlig kode, ikke en agent. Rødt uten fiksen, grønt med den, og et build som går gjennom.
# Bruk: factory/verify.sh <kjøremappe>
set -uo pipefail
run=$1
say() { echo "$1" | tee "$run/5-verify.md"; echo "{\"run\":\"$run\",\"stage\":\"5-verify\",\"ok\":$2}" >> runs/log.jsonl; [ "$2" = true ]; }
code=$(git diff --name-only -- src ':!*.test.ts')
tests=$(git status --porcelain -- 'src/*.test.ts')
[ -n "$code" ]  || { say "VERIFY: fail. Ingen kode i src/ er endret." false; exit 1; }
[ -n "$tests" ] || { say "VERIFY: fail. Ingen test er endret." false; exit 1; }
git stash push -q -- $code; npm test >/dev/null 2>&1; red=$?; git stash pop -q
[ $red -ne 0 ]                   || { say "VERIFY: fail. Testene går grønt uten fiksen, så testen beviser ingenting." false; exit 1; }
npm test >/dev/null 2>&1          || { say "VERIFY: fail. npm test feiler." false; exit 1; }
npm run build >/dev/null 2>&1     || { say "VERIFY: fail. npm run build feiler." false; exit 1; }
say "VERIFY: pass. Rødt uten fiksen, grønt med den, build ok." true
