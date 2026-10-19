// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
import { AGENTS, clone, commit, contacts, energy, initial, nudge, propose } from "./law.js";
import { mountScene } from "./scene.js";

const PHASES = ["scout", "measure", "commit"];
const state = {
  lattice: initial(),
  phase: "scout",
  descent: true,
  running: true,
  actor: 0,
  proposal: initial(),
  log: ["pit armed · descent on"],
};

const energyEl = document.querySelector("#energy");
const ledgerEl = document.querySelector("#ledger");
const factsEl = document.querySelector("#facts");
const runBtn = document.querySelector("#run");
const descentBtn = document.querySelector("#descent");
const agentsEl = document.querySelector("#agents");
const scene = mountScene(document.querySelector("#view"));

function push(line) {
  state.log = [line, ...state.log].slice(0, 7);
  paint();
}

function paint() {
  const h = energy(state.lattice);
  energyEl.textContent = `${h}/1`;
  document.querySelectorAll("[data-phase]").forEach((el) => {
    el.classList.toggle("on", el.dataset.phase === state.phase);
  });
  runBtn.textContent = state.running ? "Pause" : "Run";
  descentBtn.classList.toggle("on", state.descent);
  descentBtn.textContent = state.descent ? "Descent" : "Stir";
  factsEl.textContent = `Heights ${state.lattice.y.join(" · ")} · contacts ${contacts(state.lattice)} · gen ${state.lattice.generation}`;
  ledgerEl.innerHTML = "";
  for (const line of state.log) {
    const li = document.createElement("li");
    li.textContent = line;
    if (line.includes("TRUE")) li.className = "true";
    if (line.includes("FALSE")) li.className = "false";
    ledgerEl.appendChild(li);
  }
  agentsEl.innerHTML = "";
  AGENTS.forEach((name, i) => {
    const b = document.createElement("button");
    b.type = "button";
    b.textContent = name;
    if (state.actor === i) b.className = "on";
    b.addEventListener("click", () => {
      state.actor = i;
      paint();
    });
    agentsEl.appendChild(b);
  });
  scene.set(state.lattice, state.actor);
}

function step() {
  if (state.phase === "scout") {
    const who = state.lattice.generation % 3;
    state.actor = who;
    state.proposal = propose(state.lattice, who, state.descent);
    const same =
      state.proposal.x.every((v, i) => v === state.lattice.x[i]) &&
      state.proposal.y.every((v, i) => v === state.lattice.y[i]) &&
      state.proposal.z.every((v, i) => v === state.lattice.z[i]);
    push(same ? `${AGENTS[who]} holds` : `${AGENTS[who]} offers a step`);
    state.phase = "measure";
  } else if (state.phase === "measure") {
    const before = energy(state.lattice);
    const after = energy(state.proposal);
    const delta = after - before;
    push(`measure ${before}/1 → ${after}/1 (${delta > 0 ? "+" : ""}${delta})`);
    state.phase = "commit";
  } else {
    const who = state.lattice.generation % 3;
    const out = commit(state.lattice, state.proposal, who, state.descent);
    if (out.ok && out.next) {
      state.lattice = out.next;
      push(`${AGENTS[who]} commit TRUE · H ${out.before}/1 → ${out.after}/1`);
    } else {
      push(`${AGENTS[who]} commit FALSE ${out.code}`);
    }
    state.phase = "scout";
  }
  paint();
}

runBtn.addEventListener("click", () => {
  state.running = !state.running;
  paint();
});
document.querySelector("#step").addEventListener("click", step);
descentBtn.addEventListener("click", () => {
  state.descent = !state.descent;
  push(state.descent ? "descent constraint on" : "stir · ascent allowed");
});
document.querySelector("#reset").addEventListener("click", () => {
  state.lattice = initial();
  state.phase = "scout";
  state.proposal = clone(state.lattice);
  scene.resetMotion();
  push("lattice reset");
  paint();
});
document.querySelector("#drop").addEventListener("click", () => scene.drop());
document.querySelectorAll("[data-axis]").forEach((btn) => {
  btn.addEventListener("click", () => {
    const out = nudge(state.lattice, state.actor, btn.dataset.axis, Number(btn.dataset.dir), state.descent);
    if (out.ok && out.next) {
      state.lattice = out.next;
      push(`${AGENTS[state.actor]} ${btn.textContent.trim()} TRUE`);
    } else {
      push(`${AGENTS[state.actor]} ${btn.textContent.trim()} FALSE ${out.code}`);
    }
    paint();
  });
});

paint();
setInterval(() => {
  if (state.running) step();
}, 1100);
