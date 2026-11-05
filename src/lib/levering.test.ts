import { test } from "node:test";
import assert from "node:assert/strict";
import { leveringsgebyr, GRATIS_FRAKT_FRA_KR, FRAKT_KR } from "./levering.ts";

test("frakt koster under grensen", () => {
  assert.equal(leveringsgebyr(GRATIS_FRAKT_FRA_KR - 1), FRAKT_KR);
});

test("frakt er gratis fra grensen", () => {
  assert.equal(leveringsgebyr(GRATIS_FRAKT_FRA_KR), 0);
});
