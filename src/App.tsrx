import { useState } from "octane";
import { MENY, type Linje, type Rett, type Tone, sumHandlekurv, brukRabattkode, formaterKroner, kanLeggeTil, leggTilRett } from "./lib/handlekurv.ts";
import { ordreOppsummering, erBestillingStengt } from "./lib/levering.ts";
import { sokIMeny, skjulAllergener } from "./lib/meny.ts";

// These classes are copied from Kilden's Button, Badge, Card and Input components (which are React),
// so the Octane app looks the same without using the components themselves.
const fokus = "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-dominant-base-default";
const knapp = `inline-flex whitespace-nowrap items-center justify-center gap-2 rounded-md border px-4 h-10 font-action font-medium uppercase text-action transition-colors duration-fast disabled:pointer-events-none disabled:opacity-50 ${fokus}`;
const knappPrimar = `${knapp} border-transparent bg-dominant-base-default text-dominant-base-contrast-default hover:bg-dominant-base-hover active:bg-dominant-base-active`;
const knappSekundar = `${knapp} border-neutral-border-default text-neutral-text-default hover:bg-accent-base-hover hover:border-transparent`;
const merke = "inline-flex items-center whitespace-nowrap rounded-full px-2.5 py-1 text-caption font-action leading-none uppercase tracking-widest";
const felt = "min-h-10 w-full rounded-md border border-neutral-border-default bg-neutral-background-default px-3 text-body text-neutral-text-default placeholder:text-neutral-text-subtle focus:outline-2 focus:outline-offset-2 focus:outline-dominant-base-default";

const TONE: Record<Tone, string> = {
  accent: "bg-accent-base-default text-accent-base-contrast-default",
  dominant: "bg-dominant-base-default text-dominant-base-contrast-default",
  info: "bg-info-base-default text-info-base-contrast-default",
  success: "bg-success-base-default text-success-base-contrast-default",
  warning: "bg-warning-base-default text-warning-base-contrast-default",
};

const REPO = import.meta.env.VITE_GITHUB_REPO as string;

function issueLenke(linjer: Linje[], total: string): string {
  const kurv = linjer.length
    ? linjer.map((l) => `- ${l.antall} × ${l.rett.navn} (${formaterKroner(l.rett.pris * l.antall)})`).join("\n")
    : "- (tom)";
  const body = `## Hva skjedde?\n\n\n## Hva forventet du?\n\n\n## Handlekurven da det skjedde\n\n${kurv}\n\nTotalt i appen: ${total}\n`;
  const q = new URLSearchParams({ labels: "bug,factory", body });
  return `https://github.com/${REPO}/issues/new?${q}`;
}

export function App() @{
  const [linjer, setLinjer] = useState<Linje[]>([]);
  const [kode, setKode] = useState("");
  const [rabattert, setRabattert] = useState<number | null>(null);
  const [sok, setSok] = useState("");
  const [utelat, setUtelat] = useState("");

  const leggTil = (rett: Rett) => {
    setRabattert(null);
    setLinjer((forrige) => leggTilRett(forrige, rett));
  };
  const antallAv = (rett: Rett) => linjer.find((l) => l.rett.id === rett.id)?.antall ?? 0;
  const antallTotalt = linjer.reduce((sum, l) => sum + l.antall, 0);
  const total = sumHandlekurv(linjer);
  const oppsummering = ordreOppsummering(total, rabattert);
  const synlige = skjulAllergener(sokIMeny(MENY, sok), utelat);
  const stengt = erBestillingStengt(new Date());

  <div class="min-h-dvh bg-neutral-background-tinted">
    @if (stengt) {
      <div class="mx-auto max-w-6xl px-6 pt-6 md:px-12">
        <p role="status" class="rounded-md border border-warning-border-default border-l-4 border-l-warning-base-default bg-warning-background-default px-4 py-3 text-body text-warning-text-default">{"Bestillingsfristen kl. 10:30 er passert. Du kan bestille igjen i morgen."}</p>
      </div>
    }
    <header class="bg-dominant-base-default text-dominant-base-contrast-default">
      <div class="mx-auto max-w-6xl px-6 py-10 md:px-12 md:py-14 grid gap-8">
        <div class="flex flex-wrap items-center justify-between gap-4">
          <div class="flex items-center gap-4">
            <img src="woltora-ikon-oransje.svg" alt="" class="size-14 md:size-16" />
            <div class="grid">
              <span class="font-display font-medium text-heading-md tracking-tight leading-none">{"Woltora"}</span>
              <span class="text-body text-accent-base-default">{"mat til døra"}</span>
            </div>
          </div>
          @if (REPO) {
            <a
              class={knapp + " border-dominant-base-contrast-subtle text-dominant-base-contrast-default hover:bg-accent-base-default hover:text-accent-base-contrast-default hover:border-transparent"}
              href={issueLenke(linjer, formaterKroner(oppsummering.totalt))}
              target="_blank"
              rel="noreferrer"
            >
              {"Meld fra om en feil"}
            </a>
          }
        </div>
        <h1 class="font-display font-medium text-heading-lg tracking-tight">{"Hva blir det til lunsj?"}</h1>
        <div class="flex flex-wrap gap-3">
          <div class="rounded-lg bg-dominant-base-hover px-4 py-3 grid gap-1">
            <span class="text-caption font-action uppercase tracking-widest text-dominant-base-contrast-subtle">{"Bestill før"}</span>
            <span class="text-title font-medium">{"10:30"}</span>
          </div>
          <div class="rounded-lg bg-dominant-base-hover px-4 py-3 grid gap-1">
            <span class="text-caption font-action uppercase tracking-widest text-dominant-base-contrast-subtle">{"Levert"}</span>
            <span class="text-title font-medium">{"11:30 i 4. etasje"}</span>
          </div>
          <div class="rounded-lg bg-accent-base-default text-accent-base-contrast-default px-4 py-3 grid gap-1">
            <span class="text-caption font-action uppercase tracking-widest text-accent-base-contrast-subtle">{"På menyen"}</span>
            <span class="text-title font-medium">{MENY.length + " retter i dag"}</span>
          </div>
        </div>
      </div>
    </header>

    <main class="mx-auto max-w-6xl px-6 py-10 md:px-12 grid gap-8 lg:grid-cols-[1fr_22rem] items-start">
      <section aria-labelledby="meny-tittel" class="grid gap-4">
        <h2 id="meny-tittel" class="text-heading-sm font-medium">{"Meny"}</h2>
        <div class="grid gap-3 sm:grid-cols-2">
          <label class="grid gap-1 text-small font-medium" for="sok">
            {"Søk i menyen"}
            <input
              id="sok"
              class={felt}
              placeholder="For eksempel taco"
              value={sok}
              onInput={(e: Event) => setSok((e.target as HTMLInputElement).value)}
            />
          </label>
          <label class="grid gap-1 text-small font-medium" for="utelat">
            {"Utelat allergener"}
            <input
              id="utelat"
              class={felt}
              placeholder="For eksempel melk, gluten"
              value={utelat}
              onInput={(e: Event) => setUtelat((e.target as HTMLInputElement).value)}
            />
          </label>
        </div>
        @if (synlige.length === 0) {
          <p class="rounded-lg border border-dashed border-neutral-border-default p-4 text-small text-neutral-text-subtle text-center">{"Ingen retter passer med valgene dine."}</p>
        }
        <ul class="grid gap-4 sm:grid-cols-2">
          @for (const rett of synlige; key rett.id) {
            <li class="flex flex-col overflow-hidden rounded-xl border border-neutral-border-subtle bg-neutral-surface-default shadow-raised transition-shadow duration-fast hover:shadow-raised-hover">
              <div class={TONE[rett.tone] + " flex items-start justify-between gap-3 px-5 pt-5 pb-10"}>
                <span class={merke + " bg-neutral-surface-default text-neutral-text-default"}>{rett.kategori}</span>
                <span class="text-heading-md font-medium whitespace-nowrap">{formaterKroner(rett.pris)}</span>
              </div>
              <div class="flex flex-1 flex-col gap-2 p-5">
                <h3 class="text-title font-medium">{rett.navn}</h3>
                <p class="text-small text-neutral-text-subtle flex-1">{rett.beskrivelse}</p>
                <div class="flex items-center justify-between gap-2 pt-3">
                  @if (antallAv(rett) > 0) {
                    <span class={merke + " bg-neutral-surface-tinted text-neutral-text-default"}>{antallAv(rett) + " i kurven"}</span>
                  } @else {
                    <span></span>
                  }
                  <button class={knappSekundar} disabled={!kanLeggeTil(linjer, rett)} onClick={() => leggTil(rett)}>{"Legg til"}</button>
                </div>
              </div>
            </li>
          }
        </ul>
      </section>

      <aside aria-labelledby="kurv-tittel" class="lg:sticky lg:top-6 overflow-hidden rounded-xl border border-dominant-border-subtle bg-neutral-surface-default shadow-floating">
        <div class="flex items-center justify-between gap-2 bg-dominant-surface-tinted px-5 py-4">
          <h2 id="kurv-tittel" class="text-title font-medium">{"Handlekurv"}</h2>
          <span class={merke + " bg-dominant-base-default text-dominant-base-contrast-default"}>{antallTotalt + " varer"}</span>
        </div>
        <div class="grid gap-4 p-5">
          @if (linjer.length === 0) {
            <p class="rounded-lg border border-dashed border-neutral-border-default p-4 text-small text-neutral-text-subtle text-center">{"Tom foreløpig. Velg noe fra menyen."}</p>
          } @else {
            <ul class="grid gap-3">
              @for (const linje of linjer; key linje.rett.id) {
                <li class="flex items-center justify-between gap-3 text-body">
                  <span class="flex items-center gap-3">
                    <span class={merke + " " + TONE[linje.rett.tone]}>{linje.antall + "×"}</span>
                    <span>{linje.rett.navn}</span>
                  </span>
                  <span class="tabular-nums">{formaterKroner(linje.rett.pris * linje.antall)}</span>
                </li>
              }
            </ul>
          }

          <dl class="grid gap-2 border-t border-neutral-border-subtle pt-4 text-body">
            <div class="flex justify-between gap-3">
              <dt>{"Varer"}</dt>
              <dd class="tabular-nums">{formaterKroner(oppsummering.varer)}</dd>
            </div>
            <div class="flex justify-between gap-3">
              <dt>{"Frakt"}</dt>
              <dd class="tabular-nums">{formaterKroner(oppsummering.frakt)}</dd>
            </div>
          </dl>
          <div class="flex items-baseline justify-between border-t border-neutral-border-subtle pt-4">
            <span class="text-title font-medium">{"Totalt"}</span>
            <span class="text-heading-sm font-medium tabular-nums" data-testid="total">{formaterKroner(oppsummering.totalt)}</span>
          </div>
          @if (rabattert !== null) {
            <p role="status" class="rounded-md border border-success-border-default border-l-4 border-l-success-base-default bg-success-background-default px-3 py-2 text-small text-success-text-default">{"Rabattkoden er brukt."}</p>
          }

          <label class="grid gap-1 text-small font-medium" for="rabattkode">
            {"Rabattkode"}
            <input
              id="rabattkode"
              class={felt}
              placeholder="For eksempel BEKK10"
              value={kode}
              onInput={(e: Event) => setKode((e.target as HTMLInputElement).value)}
            />
          </label>
          <button class={knappPrimar} disabled={linjer.length === 0} onClick={() => setRabattert(brukRabattkode(total, kode))}>
            {"Bruk rabattkode"}
          </button>
        </div>
      </aside>
    </main>
  </div>
}
