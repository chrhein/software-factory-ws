# Fasilitatorguide

## Før workshopen

1. Del lenken til lysbildene: https://chrhein.github.io/software-factory-ws/workshop.html. Malen `chrhein/software-factory-ws` er offentlig, og GitHub Pages publiserer `main`, så lysbildene oppdateres når du pusher.
2. Be deltakerne gjøre oppgave 0 før de kommer (Node 24, `gh auth login`, Chrome og innlogget `claude`, `copilot` eller `codex`), og kjøre `npx -y @playwright/mcp@0.0.83 --help` én gang, så pakken er lastet ned før oppgave 7.
   Når workshopen begynner, ber du alle starte monitoren fra oppgave 0.7 i en egen fane, så de ser stegene dukke opp mens de bygger.
3. Gjør en testkjøring i et nytt repo laget fra malen. Den tar et kvarter:
   ```bash
   gh repo create woltora-test --private --clone --template chrhein/software-factory-ws && cd woltora-test && npm ci && mkdir -p runs
   gh label create factory
   node monitor/server.mjs &                               # åpne http://localhost:4777 og følg med
   cp -r ../software-factory-ws/solution/factory . && git add factory && git commit -m factory && git push
   factory/run.sh backlog/03-sok-skiller-store-sma.md     # hele veien til main
   factory/watch.sh                                        # i en egen fane, og lag så en issue fra appen
   gh issue create --label factory --title "For mange av samme rett" --body-file backlog/09-maks-antall.md
   ```
   Sak 09 skal stoppe med et utkast til en spec i issuen. Lim utkastet inn i beskrivelsen og sett på labelen igjen. Da skal triage si `automatable`. Stopp så `watch.sh`, og kjør `factory/learn.sh && git diff factory` for å se at læresteget finner issuen.
   Kjør den én gang til med `cp ../software-factory-ws/solution/copilot/stage.sh factory/` for å teste Copilot-varianten. Codex har en egen testkjøring lenger ned.

   Sjekk særlig at knappen «Meld fra om en feil» setter labelen `factory`. Det er ikke testet mot ekte GitHub ennå.

## Copilot CLI er bare testet med en stub

`solution/copilot/stage.sh` følger GitHub-dokumentasjonen for `copilot -p`, men er ikke kjørt mot ekte Copilot. Sjekk dette i testkjøringen:

- At `--additional-mcp-config` finnes og godtar JSON-en for Playwright. Flagget står ikke i referansen for programmatisk bruk.
- At `--deny-tool='write(meny.test.ts),…'` vinner over `--allow-tool=write` i build-steget. Dokumentasjonen sier ikke hva som vinner.
- At `shell(git diff)` også slipper gjennom `git diff` med argumenter, ellers ser ikke review og dommeren diffen.
- At `copilot -p` kjører i et repo som ikke er godkjent interaktivt først. Hvis ikke, må deltakerne kjøre `copilot` én gang i repoet.
- At `write(1-triage.md)` og `write(context.md)` i `8-learn` slipper gjennom endringer i `factory/1-triage.md` og `factory/context.md`. Hvis ikke, ender læresteget alltid med `LEARN: nothing`.
- Deny-lista i `.claude/settings.json` gjelder bare Claude Code. Copilot-agentene kan lese `workshop.html` og `solution/`.

## Codex CLI er bare testet med en stub

`solution/codex/stage.sh` følger OpenAI-dokumentasjonen for `codex exec`, men er ikke kjørt mot ekte Codex. Codex har ingen verktøyliste per fil. Skriptet bruker `--sandbox read-only` for stegene som bare leser, og setter tilbake filene i `keep` hvis et steg endret dem.

### Testkjøring for Codex

Bruk et eget repo, så `factory/` er committet med Codex-varianten fra start. Ellers nekter `learn.sh` å kjøre fordi `factory/stage.sh` er endret.

```bash
gh repo create woltora-codex --private --clone --template chrhein/software-factory-ws && cd woltora-codex && npm ci && mkdir -p runs
gh label create factory
cp -r ../software-factory-ws/solution/factory . && cp ../software-factory-ws/solution/codex/stage.sh factory/
git add factory && git commit -m "factory med Codex" && git push
echo "Svar med ett ord: klar" | codex exec -                    # oppgave 0.2
factory/run.sh backlog/03-sok-skiller-store-sma.md 2>&1 | tee runs/codex.log   # hele veien til main
factory/judge.sh "$(ls -d runs/03-* | tail -1)"                 # dommeren, så læresteget har noe å lære av
mkdir -p runs/m && factory/stage.sh 6-monitor runs/m            # trenger nettverk for gh
factory/learn.sh && git diff factory
```

Sjekk dette underveis:

- At oppgave 0.2 svarer `klar`. Klager `codex exec` på at mappen ikke er godkjent, må deltakerne kjøre `codex` én gang i repoet.
- At `runs/03-*/check/5-check.md` begynner med `CHECK: pass`, og at agenten faktisk har klikket i appen. Mangler nettleseren, godtar ikke Codex inline-tabellen i `-c 'mcp_servers.playwright={…}'`, eller så stopper `read-only`-sandkassen Playwright MCP fra å skrive `.playwright-mcp/`.
- At `runs/03-*/4-review.md` viser til diffen og testresultatet. Hvis ikke, kjører ikke `npm test` og `git diff` i `read-only`-sandkassen.
- Om `runs/codex.log` inneholder `3-build endret låste filer`. Da prøvde build å skrive en test fordi `AGENTS.md` sier det. Det er greit så lenge verify går gjennom, men skjer det hver gang, bør `3-build.md` si tydeligere at testen allerede finnes.
- At `runs/m/6-monitor.md` beskriver en feil som ikke står i `gh issue list`. Sier agenten at `gh` feilet, stenger sandkassen på macOS for nettverket eller for tokenet til `gh` i nøkkelringen. Da må `6-monitor` få `--sandbox danger-full-access`, eller så må `stage.sh` legge issue-lista i input.
- At `git diff factory` etter `learn.sh` bare endrer `factory/[1-6]-*.md` og `factory/context.md`.
- Deny-lista i `.claude/settings.json` gjelder ikke Codex heller. Codex-agentene kan lese `workshop.html` og `solution/`.

## Slik gikk en testkjøring (5. november 2026, Opus)

Tallene er fra før fabrikken shippet selv, men stegene er de samme.

| Sak | Resultat | Tid | Kostnad |
|---|---|---|---|
| 03 store og små bokstaver i søk | automatable → build → review approve → verify pass | 50 sekunder | ca. 0,40 dollar |
| 10 prompt injection | needs-human, stoppet i triage | 8 sekunder | ca. 0,10 dollar |
| overvåking | skrev en ny sak: mellomrom på slutten av søket | 17 sekunder | ca. 0,17 dollar |
| 04 sjekk i nettleseren | `CHECK: pass` med fiksen, `CHECK: fail` når fiksen var skjult | ca. 30 sekunder | ikke målt |
| benchmark (to saker) | to kjøringer og to dommere, snitt 7,5. Dommeren ba om at review kjører testene selv | 2,5 minutter | ca. 1 dollar |

I tillegg kommer test-steget, CI og sjekken etter merge, så regn med to til tre minutter per sak som shippes. Regn med 5–8 dollar per deltaker.

## Verdt å peke på

- **Ingen leser koden:** Spør hvem som likevel åpnet diffen, og hva som fikk dem til det. Det svaret sier hvilken sperre de ikke stoler på.
- **Test-steget og build:** Build kan ikke endre testfiler, fordi `stage.sh` nekter det med `--disallowedTools`. Det håndheves av Claude Code, så det virker selv om prompten blir lurt.
- **Labelen er tilgangskontrollen:** Bare folk med skrivetilgang kan sette `factory`. Men forfatteren av en issue kan endre teksten etter at labelen er satt. Spør hva det betyr.
- **Hvem skrev specen?** Triage stoler på en `## Spec` i beskrivelsen, men sjekker ikke hvem som skrev den. Alle som kan opprette eller redigere issuen, kan skrive sin egen. Spør hvordan en godkjenning burde se ut.
- **Lærdommene hoper seg opp:** `LESSON:`-linjer havner i `factory/context.md` uten at noen ser over dem. Spør: Hvem bør godkjenne en endring i konteksten som alle stegene leser?
- **Overvåkingen setter label selv:** Da går loopen uten noe menneske i det hele tatt. Spør om det er greit, og hvilke sperrer som må være på plass først.
- **Sjekken etter merge feiler:** `ship.sh` åpner issuen igjen, men endringen ligger fortsatt på `main`. Spør om fabrikken burde reverte selv.
- **Dommeren er også en agent:** Den kan ta feil, og den gir gjerne 7 eller 8 uansett. Spør: Hvordan vet du at dommeren er god?
