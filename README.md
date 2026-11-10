# Bygg en programvarefabrikk

En workshop på to timer for faggruppen AI-superbrukerne. Den bygger på Warp-artikkelen [«What is a software factory?»](https://www.warp.dev/articles/what-is-a-software-factory) og på hvordan [StrongDM shipper uten å lese koden](https://simonwillison.net/2026/feb/7/software-factory/).

Du bygger en loop som tar en feilmelding fra matbestillingsappen Woltora helt ut i produksjon uten at noen leser koden. Underveis prøver du å lure hvert steg, så du vet hva du kan stole på.

```
issue med label factory ─→ triage ─→ test ─→ build ─→ review ─→ verify ─→ ship.sh: PR, CI, merge til main, sjekk etterpå
        ↑  watch.sh          agent     agent   agent    agent   tradisjonell kode
        └──────────── monitor (agent) melder neste sak ───────────────────────────────────────────┘
   Stopper et steg saken, får et menneske svaret som en kommentar i issuen.
   Alle stegene leser factory/context.md, og alle kjøringer havner i runs/log.jsonl.
```

## Agenda

| Del |
|---|
| Hva en programvarefabrikk er, og hva som skal til for å shippe uten å lese koden |
| Oppgave 0–6: oppsett, motoren (stage.sh), triage, test, build, review og verify |
| Oppgave 7–12: fiks og ship med øynene lukket. Sjekk i nettleseren, ship.sh, run.sh, trigger fra en issue, overvåking og lur fabrikken |
| Diskusjon: Stoler du på den? |
| Ekstra, oppgave 13–15: dommer, benchmark og en fabrikk som lærer |

## Lysbilder

Lysbildene ligger på [chrhein.github.io/software-factory-ws/workshop.html](https://chrhein.github.io/software-factory-ws/workshop.html). Du kan også åpne `workshop.html` lokalt i en nettleser. Bla med piltastene. Med `#14` i URL-en hopper du til lysbilde 14. Alle kommandoer og filer har en kopieringsknapp.

## Filer

| Sti | Innhold |
|---|---|
| `workshop.html` | Lysbildene, med alle filene som heredocs du kan kopiere |
| `bilder/` | Skjermbildene av Woltora og build.warp.dev som lysbildene bruker, og ikonet til lysbildene |
| `backlog/` | Feilrapporter fra brukere |
| `.github/workflows/ci.yml` | Tester hver pull request og hver push til `main`. Deployer `main` til GitHub Pages hvis du har skrudd det på (frivillig, oppgave 0.7) |
| `.claude/settings.json` | Skjuler lysbildene, fasiten og fasilitatorguiden for Claude Code, så agentene ikke ser svarene |
| `src/` | Woltora. `npm test`, `npm run build`, `npm run dev` |

Du trenger Node 24, `gh`, Chrome (til Playwright MCP i oppgave 7) og enten Claude Code eller Copilot CLI. Fasilitatorer: Se [FACILITATOR.md](FACILITATOR.md).
