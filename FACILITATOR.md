# Fasilitatorguide

## Før workshopen

1. Gjør malen offentlig. Lysbildene (oppgave 0.3) forventer `chrhein/software-factory-ws`, og den er privat nå:
   ```bash
   gh repo edit chrhein/software-factory-ws --visibility public --accept-visibility-change-consequences
   ```
2. Be deltakerne gjøre oppgave 0 før de kommer (Node 24, `gh auth login`, Chrome og innlogget `claude` eller `copilot`), og kjøre `npx -y @playwright/mcp@0.0.83 --help` én gang, så pakken er lastet ned før oppgave 7.
3. Gjør en testkjøring i et nytt repo laget fra malen. Den tar et kvarter:
   ```bash
   gh repo create woltora-test --public --clone --template chrhein/software-factory-ws && cd woltora-test && npm ci && mkdir -p runs
   gh api -X POST "repos/{owner}/{repo}/pages" -f build_type=workflow >/dev/null && gh label create factory && gh workflow run ci.yml
   cp -r ../software-factory-ws/solution/factory . && git add factory && git commit -m factory && git push
   factory/run.sh backlog/03-sok-skiller-store-sma.md     # hele veien til produksjon
   factory/watch.sh                                        # i en egen fane, og lag så en issue fra appen
   ```
   Kjør den én gang til med `cp ../software-factory-ws/solution/copilot/stage.sh factory/` for å teste Copilot-varianten.

   Sjekk særlig tre ting som ikke er testet mot ekte GitHub ennå: at `ship.sh` finner CI-kjøringen med `gh run list --commit`, at deployen til Pages er ferdig før sjekken i produksjon starter, og at knappen «Meld fra om en feil» setter labelen `factory`.

## Copilot CLI er bare testet med en stub

`solution/copilot/stage.sh` følger GitHub-dokumentasjonen for `copilot -p`, men er ikke kjørt mot ekte Copilot. Sjekk dette i testkjøringen:

- At `--additional-mcp-config` finnes og godtar JSON-en for Playwright. Flagget står ikke i referansen for programmatisk bruk.
- At `--deny-tool='write(meny.test.ts),…'` vinner over `--allow-tool=write` i build-steget. Dokumentasjonen sier ikke hva som vinner.
- At `shell(git diff)` også slipper gjennom `git diff` med argumenter, ellers ser ikke review og dommeren diffen.
- At `copilot -p` kjører i et repo som ikke er godkjent interaktivt først. Hvis ikke, må deltakerne kjøre `copilot` én gang i repoet.
- Deny-lista i `.claude/settings.json` gjelder bare Claude Code. Copilot-agentene kan lese `workshop.html` og `solution/`.

## Slik gikk en testkjøring (5. november 2026, Opus)

Tallene er fra før fabrikken shippet selv, men stegene er de samme.

| Sak | Resultat | Tid | Kostnad |
|---|---|---|---|
| 03 store og små bokstaver i søk | automatable → build → review approve → verify pass | 50 sekunder | ca. 0,40 dollar |
| 10 prompt injection | needs-human, stoppet i triage | 8 sekunder | ca. 0,10 dollar |
| overvåking | skrev en ny sak: mellomrom på slutten av søket | 17 sekunder | ca. 0,17 dollar |
| 04 sjekk i nettleseren | `CHECK: pass` med fiksen, `CHECK: fail` når fiksen var skjult | ca. 30 sekunder | ikke målt |
| benchmark (to saker) | to kjøringer og to dommere, snitt 7,5. Dommeren ba om at review kjører testene selv | 2,5 minutter | ca. 1 dollar |

I tillegg kommer test-steget, CI, deploy og sjekken i produksjon, så regn med tre til fire minutter per sak som shippes. Regn med 5–8 dollar per deltaker.

## Verdt å peke på

- **Ingen leser koden:** Spør hvem som likevel åpnet diffen, og hva som fikk dem til det. Det svaret sier hvilken sperre de ikke stoler på.
- **Test-steget og build:** Build kan ikke endre testfiler, fordi `stage.sh` nekter det med `--disallowedTools`. Det håndheves av Claude Code, så det virker selv om prompten blir lurt.
- **Labelen er tilgangskontrollen:** Bare folk med skrivetilgang kan sette `factory`. Men forfatteren av en issue kan endre teksten etter at labelen er satt. Spør hva det betyr.
- **Lærdommene hoper seg opp:** `LESSON:`-linjer havner i `factory/context.md` uten at noen ser over dem. Spør: Hvem bør godkjenne en endring i konteksten som alle stegene leser?
- **Overvåkingen setter label selv:** Da går loopen uten noe menneske i det hele tatt. Spør om det er greit, og hvilke sperrer som må være på plass først.
- **Sjekken i produksjon feiler:** `ship.sh` åpner issuen igjen, men endringen ligger fortsatt i produksjon. Spør om fabrikken burde reverte selv.
- **Dommeren er også en agent:** Den kan ta feil, og den gir gjerne 7 eller 8 uansett. Spør: Hvordan vet du at dommeren er god?
