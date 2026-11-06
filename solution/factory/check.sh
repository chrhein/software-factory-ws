#!/usr/bin/env bash
# Sjekk i nettleseren: En agent som bare har sett saken, gjør det brukeren gjorde.
# Bruk: factory/check.sh <kjøremappe> [url]   Uten url bygger og starter den appen lokalt.
set -euo pipefail
run=$1; url=${2:-}; dir=$run/check
rm -rf "$dir"; mkdir -p "$dir"
if [ -z "$url" ]; then
  npm run build >/dev/null
  npx vite preview --port 4173 --strictPort >/dev/null 2>&1 & server=$!
  trap 'kill $server' EXIT
  sleep 2; url=http://localhost:4173
fi
{ cat "$run/0-ticket.md"; echo; echo "Appen kjører på $url"; } > "$dir/0-ticket.md"
factory/stage.sh 5-check "$dir"
