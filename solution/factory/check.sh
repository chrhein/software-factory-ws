#!/usr/bin/env bash
# Sjekk i nettleseren: bygg appen, start den og la en agent klikke seg gjennom saken.
# Bruk: factory/check.sh <kjøremappe>
set -euo pipefail
run=$1
npm run build >/dev/null
npx vite preview --port 4173 --strictPort >/dev/null 2>&1 & server=$!
trap 'kill $server' EXIT
sleep 2
factory/stage.sh 5-check "$run"
