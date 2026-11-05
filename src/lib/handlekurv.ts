export type Tone = "accent" | "dominant" | "info" | "success" | "warning";
export type Rett = { id: string; navn: string; pris: number; beskrivelse: string; kategori: string; tone: Tone; allergener: string[] };
export type Linje = { rett: Rett; antall: number };

export const MENY: Rett[] = [
  { id: "taco", navn: "Fredagstaco", pris: 129, beskrivelse: "Myke lefser, guacamole og syltet rødløk.", kategori: "Populær", tone: "accent", allergener: ["gluten", "melk"] },
  { id: "suppe", navn: "Dagens suppe", pris: 89, beskrivelse: "Gresskar og ingefær, servert med surdeig.", kategori: "Vegetar", tone: "dominant", allergener: ["gluten", "selleri"] },
  { id: "poke", navn: "Poké bowl", pris: 149, beskrivelse: "Laks, edamame, ris og sesam.", kategori: "Sjømat", tone: "dominant", allergener: ["fisk", "soya", "sesam"] },
  { id: "pasta", navn: "Pasta al limone", pris: 119, beskrivelse: "Sitron, parmesan og sort pepper.", kategori: "Vegetar", tone: "accent", allergener: ["gluten", "melk", "egg"] },
  { id: "burger", navn: "Smash-burger", pris: 159, beskrivelse: "Dobbel cheddar, pickles og potetbåter.", kategori: "Ny", tone: "accent", allergener: ["gluten", "melk", "sennep"] },
  { id: "bolle", navn: "Kanelbolle", pris: 39, beskrivelse: "Nystekt i morges. Kanskje.", kategori: "Søtt", tone: "dominant", allergener: ["gluten", "melk", "egg"] },
];

const RABATTKODER: Record<string, { prosent: number }> = {
  BEKK10: { prosent: 10 },
  LOOP25: { prosent: 25 },
};

export function sumHandlekurv(linjer: Linje[]): number {
  return linjer.reduce((sum, linje) => sum + linje.rett.pris, 0);
}

export function brukRabattkode(total: number, kode: string): number {
  const rabatt = RABATTKODER[kode.trim().toUpperCase()];
  return Math.round(total * (1 - rabatt.prosent / 100));
}

export function formaterKroner(belop: number): string {
  return `${belop.toLocaleString("nb-NO")} kr`;
}

export const MAKS_ANTALL_PER_RETT = 12;

export function kanLeggeTil(linjer: Linje[], rett: Rett): boolean {
  const antall = linjer.find((l) => l.rett.id === rett.id)?.antall ?? 0;
  return antall < MAKS_ANTALL_PER_RETT;
}

export function leggTilRett(linjer: Linje[], rett: Rett): Linje[] {
  if (!kanLeggeTil(linjer, rett)) return linjer;
  return linjer.find((l) => l.rett.id === rett.id)
    ? linjer.map((l) => (l.rett.id === rett.id ? { ...l, antall: l.antall + 1 } : l))
    : [...linjer, { rett, antall: 1 }];
}
