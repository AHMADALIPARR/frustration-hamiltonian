// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
import { AGENTS, clone, commit, demoStart, energy } from "./law.js";
import { mountScene } from "./scene.js";

const scene = mountScene(document.querySelector("#view"));
const list = document.querySelector("#list");
const ledger = document.querySelector("#ledger");
const verdict = document.querySelector("#verdict");

const lines = [];
function say(line, kind) {
  lines.unshift({ line, kind });
  ledger.innerHTML = "";
  for (const row of lines.slice(0, 8)) {
    const li = document.createElement("li");
    li.textContent = row.line;
    if (row.kind) li.className = row.kind;
    ledger.appendChild(li);
  }
}

function show(lattice, actor) {
  scene.resetMotion();
  scene.set(lattice, actor);
}

const DEMOS = [
  {
    title: "Descent",
    blurb: "Aether steps down. The bill shrinks. The commit lives.",
    play() {
      const s = demoStart();
      const t = clone(s);
      t.y[0] = 2;
      show(s, 0);
      const out = commit(s, t, 0, true);
      window.setTimeout(() => {
        if (out.next) show(out.next, 0);
        verdict.textContent = out.ok ? "TRUE" : "FALSE";
        verdict.className = out.ok ? "true" : "false";
        say(`H ${out.before}/1 → ${out.after}/1`, out.ok ? "true" : "false");
        say("Aether y−1, descent on", "");
      }, 700);
    },
  },
  {
    title: "Refused rise",
    blurb: "The same agent climbs. Descent is on. The commit dies.",
    play() {
      const s = demoStart();
      const t = clone(s);
      t.y[0] = 4;
      show(s, 0);
      const out = commit(s, t, 0, true);
      window.setTimeout(() => {
        show(s, 0);
        verdict.textContent = "FALSE";
        verdict.className = "false";
        say(`energy  ${out.before}/1 → ${out.after}/1 refused`, "false");
        say("Aether stays put", "");
      }, 700);
    },
  },
  {
    title: "Stir",
    blurb: "Descent off. The climb is legal, so the energy is allowed to rise.",
    play() {
      const s = demoStart();
      const t = clone(s);
      t.y[0] = 4;
      show(s, 0);
      const out = commit(s, t, 0, false);
      window.setTimeout(() => {
        if (out.next) show(out.next, 0);
        verdict.textContent = "TRUE";
        verdict.className = "true";
        say(`stir  H ${out.before}/1 → ${out.after}/1`, "true");
      }, 700);
    },
  },
  {
    title: "Overlap",
    blurb: "Keel tries to stand on Aether. Hard cells do not share a site.",
    play() {
      const s = demoStart();
      s.x[1] = 0;
      s.y[1] = 2;
      s.z[1] = 0;
      const t = clone(s);
      t.y[1] = 3;
      show(s, 1);
      const out = commit(s, t, 1, true);
      window.setTimeout(() => {
        show(s, 1);
        verdict.textContent = "HARD";
        verdict.className = "false";
        say(`commit FALSE ${out.code}`, "false");
        say("Keel stepped up into Aether", "");
      }, 700);
    },
  },
  {
    title: "Forged token",
    blurb: "The geometry is fine. The token is not. Authorization fails closed.",
    play() {
      const s = demoStart();
      const t = clone(s);
      t.y[0] = 2;
      show(s, 0);
      const out = commit(s, t, 0, true, 1);
      window.setTimeout(() => {
        show(s, 0);
        verdict.textContent = "AUTH";
        verdict.className = "false";
        say(`commit FALSE ${out.code}`, "false");
        say("token was 1, not FRST", "");
      }, 700);
    },
  },
  {
    title: "Two movers",
    blurb: "Aether and Vector both step. A verified commit moves at most one body.",
    play() {
      const s = demoStart();
      const t = clone(s);
      t.y[0] = 2;
      t.y[2] = 3;
      show(s, 0);
      const out = commit(s, t, 0, true);
      window.setTimeout(() => {
        show(s, 0);
        verdict.textContent = "VERIFY";
        verdict.className = "false";
        say(`commit FALSE ${out.code}`, "false");
        say("two bodies, one generation", "");
      }, 700);
    },
  },
];

let active = 0;
function renderList() {
  list.innerHTML = "";
  DEMOS.forEach((demo, i) => {
    const b = document.createElement("button");
    b.type = "button";
    if (i === active) b.className = "on";
    b.innerHTML = `${demo.title}<small>${demo.blurb}</small>`;
    b.addEventListener("click", () => {
      active = i;
      lines.length = 0;
      say(demo.title, "");
      const s = demoStart();
      verdict.textContent = "…";
      verdict.className = "";
      say(`open H ${energy(s)}/1   ${AGENTS.map((n, k) => `${n}(${s.x[k]},${s.y[k]},${s.z[k]})`).join("  ")}`, "");
      show(s, 0);
      renderList();
      demo.play();
    });
    list.appendChild(b);
  });
}

renderList();
show(demoStart(), 0);
say("pick a demo", "");
verdict.textContent = "—";
