# Fasilitatorguide

## Før workshopen

1. Publiser denne mappen som et template-repo. Lysbildene (oppgave 0.2) forventer `chrhein/software-factory-ws`:
   ```bash
   git init -b main && git add -A && git commit -m "Software factory workshop"
   gh repo create chrhein/software-factory-ws --public --source . --push && gh repo edit chrhein/software-factory-ws --template
   ```
2. Be deltakerne gjøre oppgave 0 før de kommer (Node 24, `gh auth login`, innlogget `claude`, `jq`), og kjøre `npx -y @playwright/mcp@0.0.83 --help` én gang, så pakken er lastet ned før oppgave 12.
3. Gjør en testkjøring i et nytt repo laget fra malen: `cp -r solution/factory . && git add -A && git commit -m factory && git push && factory/run.sh backlog/03-sok-skiller-store-sma.md`.

## Slik gikk en testkjøring (5. november 2026, Opus)

| Sak | Resultat | Tid | Kostnad |
|---|---|---|---|
| 03 store og små bokstaver i søk | automatable → build → review approve → verify pass | 50 sekunder | ca. 0,40 dollar |
| 10 prompt injection | needs-human, stoppet i triage | 8 sekunder | ca. 0,10 dollar |
| 09 maks antall | needs-spec. Ingen svar, build endret ingenting, og review «godkjente» ingenting | ca. 60 sekunder | ikke målt |
| overvåking | skrev en ny sak: mellomrom på slutten av søket | 17 sekunder | ca. 0,17 dollar |
| 04 sjekk i nettleseren | `CHECK: pass` med fiksen, `CHECK: fail` når fiksen var skjult | ca. 30 sekunder | ikke målt |
| benchmark (02 og 06) | to kjøringer og to dommere, snitt 7,5. Dommeren ba om at review kjører testene selv | 2,5 minutter | ca. 1 dollar |

Regn med 5–8 dollar per deltaker. Oppgave 14 kjører benchmarken to ganger.

## Verdt å peke på

- **09 uten svar:** Review godkjente en tom endring. Det er en dårlig fabrikk som gjør akkurat det den har fått beskjed om. Spør: Hvilket steg burde ha stoppet den, og med vanlig kode eller en prompt?
- **Lærdommene hoper seg opp:** `LESSON:`-linjer havner i `factory/context.md` uten at noen ser over dem. Spør: Hvem bør godkjenne en endring i konteksten som alle stegene leser?
- **Overvåkingssteget ser injection-saken** i `backlog/` og kommenterer den. Konteksten er felles, på godt og vondt.
- **Dommeren er også en agent:** Den kan ta feil, og den gir gjerne 7 eller 8 uansett. Spør: Hvordan vet du at dommeren er god? Sammenlign poengene med det du selv ville gitt.
- **To saker er lite:** Et hopp fra 7,5 til 8 kan være støy. Det er et godt utgangspunkt for å snakke om hvor mange saker en ekte benchmark trenger.
- **Det ærlige svaret** for en feil som tar to minutter, er ofte «Claude Code i terminalen gikk raskere». Fabrikken lønner seg på volum, på kjøringer uten tilsyn og på tallene i `stats.sh`. La gruppa komme fram til det selv.
