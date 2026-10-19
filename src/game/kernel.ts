// Copyright (C) 2026 AHMAD ALI PARR
// SPDX-License-Identifier: AGPL-3.0-or-later

export const BOX = 7;
export const TOKEN = 0x46525354;

export type XYZ = [number, number, number];

export type Lattice = {
  x: XYZ;
  y: XYZ;
  z: XYZ;
  generation: number;
};

export type Verdict =
  | "ok"
  | "hard"
  | "auth"
  | "verify"
  | "energy"
  | "overflow"
  | "malformed"
  | "index";

export type CommitOut = {
  ok: boolean;
  code: Verdict;
  before: bigint;
  after: bigint;
  next: Lattice | null;
};

const AGENTS = ["Aether", "Keel", "Vector"] as const;
export { AGENTS };

export function clone(s: Lattice): Lattice {
  return {
    x: [...s.x] as XYZ,
    y: [...s.y] as XYZ,
    z: [...s.z] as XYZ,
    generation: s.generation,
  };
}

export function initial(): Lattice {
  return { x: [0, 3, 6], y: [4, 3, 5], z: [1, 5, 2], generation: 1 };
}

function inBox(v: number) {
  return v >= 0 && v <= BOX;
}

export function hardValid(s: Lattice): boolean {
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

function manh(s: Lattice, i: number, j: number) {
  return (
    Math.abs(s.x[i] - s.x[j]) + Math.abs(s.y[i] - s.y[j]) + Math.abs(s.z[i] - s.z[j])
  );
}

export function energy(s: Lattice): bigint {
  let h = BigInt(s.y[0] + s.y[1] + s.y[2]);
  const pairs: Array<[number, number]> = [
    [0, 1],
    [0, 2],
    [1, 2],
  ];
  for (const [i, j] of pairs) if (manh(s, i, j) === 1) h += 1n;
  return h;
}

export function formatEnergy(h: bigint): string {
  return `${h.toString()}/1`;
}

function movers(s: Lattice, t: Lattice): number[] {
  const who: number[] = [];
  for (let i = 0; i < 3; i++) {
    if (s.x[i] !== t.x[i] || s.y[i] !== t.y[i] || s.z[i] !== t.z[i]) who.push(i);
  }
  return who;
}

export function commit(
  s: Lattice,
  t: Lattice,
  actor: number,
  descent: boolean,
  token = TOKEN,
  mask = 0x7,
): CommitOut {
  const before = energy(s);
  const after = energy(t);
  const fail = (code: Verdict): CommitOut => ({
    ok: false,
    code,
    before,
    after,
    next: null,
  });
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

const DIRS: Array<[number, number, number]> = [
  [1, 0, 0],
  [-1, 0, 0],
  [0, 1, 0],
  [0, -1, 0],
  [0, 0, 1],
  [0, 0, -1],
];

export function propose(s: Lattice, actor: number, descent: boolean): Lattice {
  let best: Lattice | null = null;
  let bestE: bigint | null = null;
  for (const [dx, dy, dz] of DIRS) {
    const t = clone(s);
    t.x[actor] += dx;
    t.y[actor] += dy;
    t.z[actor] += dz;
    const out = commit(s, t, actor, descent);
    if (!out.ok || !out.next) continue;
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

export function certBound(lo: number, hi: number) {
  return lo > hi;
}

export function certPigeon(bodies: number, cells: number) {
  return bodies > 0 && cells >= 0 && bodies <= 1_000_000 && bodies > cells;
}

export function certOverlap(i: number, j: number) {
  return i >= 0 && j >= 0 && i < 3 && j < 3 && i !== j;
}
