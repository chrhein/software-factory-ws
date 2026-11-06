#!/usr/bin/env bash
# Triggeren: Hver issue med label factory går gjennom fabrikken, og resultatet havner som en kommentar i issuen.
# Bruk: factory/watch.sh   Stopp med Ctrl+C.
set -uo pipefail
echo "Venter på issues med label factory …"
while true; do
  for n in $(gh issue list --label factory --state open --json number --jq '.[].number'); do
    gh issue edit "$n" --remove-label factory >/dev/null
    gh issue view "$n" --json number,title,body --jq '"---\nissue: \(.number)\n---\n\n# \(.title)\n\n\(.body)"' > "runs/issue-$n.md"
    factory/run.sh "runs/issue-$n.md" || { gh issue comment "$n" --body "Fabrikken kunne ikke starte. Se terminalen der watch.sh kjører, og sett på labelen factory igjen."; continue; }
    gh issue comment "$n" --body-file "$(ls -d runs/issue-"$n"-* | tail -1)/9-end.md"
  done
  sleep 30
done
