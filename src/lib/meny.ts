import type { Rett } from "./handlekurv.ts";

export function sokIMeny(meny: Rett[], sok: string): Rett[] {
  if (sok === "") return meny;
  return meny.filter((r) => r.navn.includes(sok) || r.beskrivelse.includes(sok));
}

export function skjulAllergener(meny: Rett[], skriv: string): Rett[] {
  const utelat = skriv.split(",").filter((a) => a !== "");
  return meny.filter((r) => !r.allergener.some((a) => utelat.includes(a)));
}
