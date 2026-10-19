import { commit, energy, hardValid, initial, type Lattice } from "./kernel.ts";

function assert(cond: boolean, msg: string) {
  if (!cond) {
    console.error("FAIL", msg);
    process.exit(1);
  }
}

function moved(base: Lattice, i: number, axis: "x" | "y" | "z", delta: number): Lattice {
  const t = {
    x: [...base.x] as Lattice["x"],
    y: [...base.y] as Lattice["y"],
    z: [...base.z] as Lattice["z"],
    generation: base.generation,
  };
  t[axis][i] += delta;
  return t;
}

const s = initial();
assert(hardValid(s), "initial hard");
assert(energy(s) === 12n, `initial energy ${energy(s)}`);

const down = moved(s, 0, "y", -1);
const ok = commit(s, down, 0, true);
assert(ok.ok && ok.next?.generation === 2 && ok.after === 11n, "descent commits");

const up = moved(s, 0, "y", 1);
const rise = commit(s, up, 0, true);
assert(!rise.ok && rise.code === "energy", "ascent rejected");

const stir = commit(s, up, 0, false);
assert(stir.ok, "stir allows ascent");

const bad = commit(s, down, 0, true, 1);
assert(!bad.ok && bad.code === "auth", "bad token");

const jump = moved(s, 0, "y", -2);
const jumped = commit(s, jump, 0, true);
assert(!jumped.ok && jumped.code === "verify", "jump");

const overlap = moved(s, 1, "x", -3);
overlap.y[1] = s.y[0];
overlap.z[1] = s.z[0];
const hard = commit(s, overlap, 1, false);
assert(!hard.ok && hard.code === "hard", "overlap");

const stale = { ...down, generation: down.generation + 1 };
const mal = commit(s, stale, 0, true);
assert(!mal.ok && mal.code === "malformed", "stale generation before other classes");

const idx = commit(s, down, 9, true);
assert(!idx.ok && idx.code === "index", "actor");

const top = { ...s, generation: 0xffffffff };
const held = { ...top };
const overflow = commit(top, held, 0, false);
assert(!overflow.ok && overflow.code === "overflow", "generation wrap");

const again = commit(s, down, 0, true);
assert(again.ok === ok.ok && again.code === ok.code && again.after === ok.after, "deterministic");

console.log("ts-kernel-ok");
