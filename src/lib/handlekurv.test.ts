import { test } from "node:test";
import assert from "node:assert/strict";
import { MENY, sumHandlekurv, brukRabattkode, leggTilRett } from "./handlekurv.ts";

const [taco, suppe] = MENY;

test("tom handlekurv koster ingenting", () => {
  assert.equal(sumHandlekurv([]), 0);
});

test("summerer flere retter", () => {
  assert.equal(sumHandlekurv([{ rett: taco, antall: 1 }, { rett: suppe, antall: 1 }]), 218);
});

test("gyldig rabattkode gir rabatt", () => {
  assert.equal(brukRabattkode(200, "bekk10"), 180);
});

test("legger til en rett i kurven", () => {
  const kurv = leggTilRett(leggTilRett([], taco), taco);
  assert.deepEqual(kurv, [{ rett: taco, antall: 2 }]);
});
