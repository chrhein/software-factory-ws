#!/usr/bin/env bash
# Mål fabrikken: hvordan sakene endte, hvilken sperre som stoppet dem, og tid per steg.
node -e '
const log = require("fs").readFileSync("runs/log.jsonl", "utf8").trim().split("\n").map(JSON.parse);
const count = (rows, key) => rows.reduce((acc, r) => ({ ...acc, [r[key]]: (acc[r[key]] ?? 0) + 1 }), {});
const ends = log.filter(r => r.stage === "end");
const steps = {};
for (const r of log.filter(r => r.sec !== undefined)) { const s = (steps[r.stage] ??= { kjøringer: 0, sekunder: 0 }); s.kjøringer++; s.sekunder += r.sec; }
console.log("Slik endte sakene:", count(ends, "end"));
console.log("Stoppet av:", count(ends.filter(r => r.end !== "SHIPPET"), "at"));
console.table(steps);
'
