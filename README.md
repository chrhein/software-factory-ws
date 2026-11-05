# En dårlig programvarefabrikk

En workshop på to og en halv time for faggruppen for avansert AI. Den bygger på Warp-artikkelen [«What is a software factory?»](https://www.warp.dev/articles/what-is-a-software-factory).

Du bygger den minste loopen som kan kalles en fabrikk, ett steg om gangen, på Woltora (demoappen fra workshopen om triggede agenter). Så sammenligner du med å fikse en feil på vanlig måte, og avgjør om det var verdt det.

```
backlog/ ─→ triage ─→ (spec + menneske) ─→ build ─→ review ─→ verify ─→ menneske ─→ PR + CI
   ↑        agent           agent          agent    agent   vanlig kode ship.sh
   └──────────────────────── monitor (agent) melder neste sak ─────────────────────────┘
     alle stegene leser factory/context.md · alle kjøringer havner i runs/log.jsonl
```

## Agenda

| Del |
|---|
| Hva en programvarefabrikk er (lysbilde 1–10) |
| Oppgave 0–1: oppsett og én feil du fikser selv |
| Oppgave 2–7: stage.sh, triage, build, review, verify, ship |
| Oppgave 8–11: run.sh, spec, overvåking, statistikk |
| Oppgave 12–14: sjekk i nettleseren, dommer og benchmark |
| Duell og diskusjon om det var verdt det |

## Lysbilder

Åpne `workshop.html` i en nettleser, og bla med piltastene. Med `#14` i URL-en hopper du til lysbilde 14. Alle kommandoer og filer har en kopieringsknapp.

## Filer

| Sti | Innhold |
|---|---|
| `workshop.html` | Lysbildene, med alle filene som heredocs du kan kopiere |
| `solution/factory/` | Den ferdige fabrikken. Henger du etter? `cp solution/factory/<fil> factory/` |
| `backlog/` | Feilrapporter fra brukere |
| `.claude/settings.json` | Skjuler lysbildene, fasiten og fasilitatorguiden for agentene, så de ikke ser svarene |
| `src/` | Woltora. `npm test`, `npm run build`, `npm run dev` |

Du trenger Node 24, `gh`, `jq`, Claude Code og Chrome (til Playwright MCP i oppgave 12). Fasilitatorer: Se [FACILITATOR.md](FACILITATOR.md).
