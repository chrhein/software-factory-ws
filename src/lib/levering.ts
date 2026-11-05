export const FRAKT_KR = 49;
export const GRATIS_FRAKT_FRA_KR = 300;
const BESTILLINGSFRIST = { time: 10, minutt: 30 };

export type Oppsummering = { varer: number; frakt: number; totalt: number };

export function leveringsgebyr(varesum: number): number {
  return varesum >= GRATIS_FRAKT_FRA_KR ? 0 : FRAKT_KR;
}

export function ordreOppsummering(varesum: number, etterRabatt: number | null): Oppsummering {
  const varer = etterRabatt ?? varesum;
  const frakt = leveringsgebyr(varesum);
  return { varer, frakt, totalt: varer };
}

export function erBestillingStengt(nå: Date): boolean {
  const minutter = nå.getHours() * 60 + nå.getMinutes();
  return minutter >= BESTILLINGSFRIST.time * 60 + BESTILLINGSFRIST.minutt;
}
