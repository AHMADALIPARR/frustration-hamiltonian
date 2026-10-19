# FRUSTRATION HAMILTONIAN

Exact-rational commit law for a three-agent lattice, with a browser pit that watches the same predicate.

`H_F(s) = y0 + y1 + y2 + C01 + C02 + C12`, where `Cij = 1` iff the Manhattan distance is 1.
A commit needs a hard-valid destination, authorization, and a verified unit step of at most one agent.
Descent additionally requires `H(s') ≤ H(s)`. A better soft value never buys a hard failure.

## Tree

| Path | What |
| --- | --- |
| `fh/c` | ISO C kernel: limb rationals, commit classification, host FFI |
| `fh/c/demo.c` | Scripted commit-law demo (`make demo`) |
| `fh/include/fh.h` | ABI |
| `fh/lean` | Lean 4.21.0 proofs, no Mathlib |
| `fh/m2` | Modula-2 exact rationals and the host call into the C kernel |
| `fh/ampl` | GLPK models: one feasible, one infeasible |
| `fh/asm/fh_kernel.s` | `gcc -S` listing. Not CompCert |
| `fh/evidence` | GLPK logs and hashes |
| `src/components/playground` | Three.js / Rapier pit (Aether, Keel, Vector) |
| `src/game` | TypeScript viewer of the integer commit cases |
| `attachments/Pasted Text.txt` | Build contract |
| `fh/STATUS.md` | Proved / tested / unverified |

## Rebuild

```
cd fh
make test test-compile-fail test-link-fail asm m2 host
glpsol --math ampl/feasible.mod
glpsol --math ampl/infeasible.mod
cd lean && lake build
```

Needs `gcc`, GNU Modula-2 (`gm2`, GCC 12), `glpsol` 5, and `leanprover/lean4:v4.21.0`.
CompCert (`ccomp`) is not part of this tree. The assembly file is unverified `gcc -S` output.

The browser pit is a viewer. It is not the certified kernel.
Certification detail, including what is still unverified, is in [fh/STATUS.md](fh/STATUS.md).

## Demo

```
cd fh
make demo
```

Prints one descent commit, one refused rise, the same rise with descent off, a hard overlap rejection, a bad token, and a zero denominator. Exit status is 0 only when each of those outcomes matches the kernel.

## License

Copyright (C) 2026 AHMAD ALI PARR

The Frustration Hamiltonian kernel, proofs, models, and pit (`fh/`, `src/game/`, `src/components/playground/`) are licensed under the GNU Affero General Public License v3.0 or any later version. See [LICENSE](LICENSE) and SPDX identifier `AGPL-3.0-or-later`.

`kernel.s` and `fh/asm/fh_kernel.s` are generated `gcc -S` listings. They are not CompCert output.

The app shell under `src/lib/`, `scripts/`, and `server/` is the viewer scaffold and is not part of that grant.
