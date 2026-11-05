# Woltora – agentworkshop

Regler for alle kodeagenter i dette repoet. Claude Code leser dem via `CLAUDE.md`, mens Codex og Copilot leser denne filen direkte.

En liten app for matbestilling som agentene i denne workshopen jobber på. Grensesnittet er på norsk.

## Stack
- Octane (`.tsrx`-komponenter, hooks i React-stil, ingen virtuell DOM). Syntaks:
  - Komponentkropp: `export function App() @{ ... }`. Markup skrives direkte, uten `return`.
  - Kontrollflyt: `@if (x) { } @else { }`, `@for (const x of xs; key x.id) { }`.
  - Tekst i markup pakkes inn i uttrykk: `{"Hei"}`, `{rett.navn}`.
  - Bruk `class`, ikke `className`.
- Kilden (designsystemet til Bekk) brukes bare gjennom Tailwind-tokenklassene. Komponentene er skrevet i React og brukes ikke her.
  - Bruk tokenklasser bare for farge, typografi og skygge: `bg-neutral-surface-default`, `text-neutral-text-subtle`, `text-body`, `text-title`, `font-action`, `shadow-subtle`.
  - Aldri `text-sm`, `bg-blue-500`, `p-[12px]` eller lignende. Sjekk med `npx kilden-check src`.
  - Fargene kommer fra Woltora-temaet i `src/woltora-tema.css` (`data-theme="bekk-woltora"`). Endre farger der, aldri med hex-verdier i komponentene.
- PostHog fanger opp exceptions i nettleseren (`src/main.ts`).
- Forretningslogikken ligger i `src/lib/` og testes med `node --test` (Node 24 kjører TypeScript direkte).

## Når du fikser en feil
1. Finn årsaken. Skriv først en test i `src/lib/*.test.ts` som feiler.
2. Gjør den minste endringen som får testen til å gå grønt. Ikke refaktorer noe annet.
3. Kjør `npm test` og `npm run build`. Begge må gå gjennom.
4. Ikke rør `.github/`, `package.json` eller lockfilen.
