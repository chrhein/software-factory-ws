import { test } from "node:test";
import assert from "node:assert/strict";
import { MENY } from "./handlekurv.ts";
import { sokIMeny, skjulAllergener } from "./meny.ts";

test("søk med eksakt skrivemåte finner retten", () => {
  assert.deepEqual(sokIMeny(MENY, "taco").map((r) => r.id), ["taco"]);
});

test("tomt søk viser hele menyen", () => {
  assert.equal(sokIMeny(MENY, "").length, MENY.length);
});

test("utelater retter med valgt allergen", () => {
  assert.deepEqual(skjulAllergener(MENY, "melk").map((r) => r.id), ["suppe", "poke"]);
});
