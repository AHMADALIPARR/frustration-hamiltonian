// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later
// Integer viewer of the commit law. Not the certified C kernel.

export const BOX = 7;
export const TOKEN = 0x46525354;
export const AGENTS = ["Aether", "Keel", "Vector"];

export function clone(s) {
  return { x: [...s.x], y: [...s.y], z: [...s.z], generation: s.generation };
}

export function initial() {
  return { x: [0, 3, 6], y: [4, 3, 5], z: [1, 5, 2], generation: 1 };
}

export function demoStart() {
  return { x: [0, 2, 4], y: [3, 2, 4], z: [0, 0, 1], generation: 5 };
}

function inBox(v) {
  return v >= 0 && v <= BOX;
}

export function hardValid(s) {
  for (let i = 0; i < 3; i++) {
    if (!inBox(s.x[i]) || !inBox(s.y[i]) || !inBox(s.z[i])) return false;
  }
  for (let i = 0; i < 3; i++) {
    for (let j = i + 1; j < 3; j++) {
      if (s.x[i] === s.x[j] && s.y[i] === s.y[j] && s.z[i] === s.z[j]) return false;
    }
  }
  return true;
}

function manh(s, i, j) {
  return Math.abs(s.x[i] - s.x[j]) + Math.abs(s.y[i] - s.y[j]) + Math.abs(s.z[i] - s.z[j]);
}

export function contacts(s) {
  let n = 0;
  if (manh(s, 0, 1) === 1) n++;
  if (manh(s, 0, 2) === 1) n++;
  if (manh(s, 1, 2) === 1) n++;
  return n;
}

export function energy(s) {
  return s.y[0] + s.y[1] + s.y[2] + contacts(s);
}

function movers(s, t) {
  const who = [];
  for (let i = 0; i < 3; i++) {
    if (s.x[i] !== t.x[i] || s.y[i] !== t.y[i] || s.z[i] !== t.z[i]) who.push(i);
  }
  return who;
}

export function commit(s, t, actor, descent, token = TOKEN, mask = 0x7) {
  const before = energy(s);
  const after = energy(t);
  const fail = (code) => ({ ok: false, code, before, after, next: null });
  if (t.generation !== s.generation) return fail("malformed");
  if (!Number.isInteger(actor) || actor > 2 || actor < 0) return fail("index");
  if (!hardValid(t)) return fail("hard");
  const who = movers(s, t);
  if (token !== TOKEN || (mask & (1 << actor)) === 0) return fail("auth");
  if (who.length === 1 && who[0] !== actor) return fail("auth");
  if (who.length > 1) return fail("verify");
  for (let i = 0; i < 3; i++) {
    const dx = t.x[i] - s.x[i];
    const dy = t.y[i] - s.y[i];
    const dz = t.z[i] - s.z[i];
    if (Math.abs(dx) > 1 || Math.abs(dy) > 1 || Math.abs(dz) > 1) return fail("verify");
    if (Math.abs(dx) + Math.abs(dy) + Math.abs(dz) > 1) return fail("verify");
  }
  if (s.generation >= 0xffffffff) return fail("overflow");
  if (descent && after > before) return fail("energy");
  const next = clone(t);
  next.generation = s.generation + 1;
  return { ok: true, code: "ok", before, after, next };
}

const DIRS = [
  [1, 0, 0],
  [-1, 0, 0],
  [0, 1, 0],
  [0, -1, 0],
  [0, 0, 1],
  [0, 0, -1],
];

export function propose(s, actor, descent) {
  let best = null;
  let bestE = null;
  for (const [dx, dy, dz] of DIRS) {
    const t = clone(s);
    t.x[actor] += dx;
    t.y[actor] += dy;
    t.z[actor] += dz;
    const out = commit(s, t, actor, descent);
    if (!out.ok) continue;
    if (bestE === null || out.after < bestE) {
      best = t;
      bestE = out.after;
    }
  }
  if (!descent) {
    const offset = (s.generation + actor) % DIRS.length;
    for (let k = 0; k < DIRS.length; k++) {
      const [dx, dy, dz] = DIRS[(offset + k) % DIRS.length];
      const t = clone(s);
      t.x[actor] += dx;
      t.y[actor] += dy;
      t.z[actor] += dz;
      const out = commit(s, t, actor, false);
      if (out.ok) return t;
    }
  }
  if (best && bestE !== null && bestE < energy(s)) return best;
  return clone(s);
}

export function nudge(s, actor, axis, dir, descent) {
  const t = clone(s);
  t[axis][actor] += dir;
  return commit(s, t, actor, descent);
}
