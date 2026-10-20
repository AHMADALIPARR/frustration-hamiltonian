<!--
Copyright (C) 2026 AHMAD ALI PARR
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Certification status

Model shared by the C kernel, the Lean development, the Modula-2 host call, and the browser viewer:

`H_F(s) = y0 + y1 + y2 + C01 + C02 + C12` with `Cij = 1` iff Manhattan distance is 1.
`Commit` requires hard validity of the destination, authorization, and a verified unit step of at most one agent.
Descent additionally requires `H(s') ≤ H(s)`. Hard failure is never bought by a better soft value.

## Proved (Lean 4.21.0, no Mathlib, no `sorry`, no added axioms)

`fh/lean/Frustration/Basic.lean`, checked by `lake build`.

1. A committed state is hard-valid.
2. An accepted transition preserves that hard validity.
3. An unauthorized transition cannot commit.
4. A descent commit does not increase energy.
5. `normalize` rejects a zero denominator, keeps a positive denominator, cancels the gcd, and preserves the rational value (`q.num * d = n * q.den`).
7. `commit` is a pure function of its inputs.
8. An empty integer interval, a forced overlap, and a pigeonhole (`bodies > cells` with distinct cell ids) are unsatisfiable.

Kernel axioms these proofs depend on, and no others: `propext`, `Quot.sound`, and `Classical.choice` (the last two arrive through `omega` / decidable branching). Nothing was declared with `axiom` or `sorry`.

## Tested

| Check | Result |
| --- | --- |
| C kernel `make test` | pass, including zero and negative denominators, `INT64_MIN`, `2^60`/`2^100`, limb overflow, commit descent, energy increase, overlap, auth, verify, generation overflow, determinism, negative `J` |
| `make test-compile-fail` / `test-link-fail` | both rejected |
| Modula-2 `M2Rational` | `m2rat-ok`: add/sub/mul/div/cmp, negative denominators, zero denominator, `10^63` exact, next product overflows, `(10^63)/(10^27) = 10^36`, determinism |
| Modula-2 host FFI | `commit-true code 0`, `unauth-false` |
| GLPK `feasible.mod` | `INTEGER OPTIMAL`, `H.val = 0` |
| GLPK `infeasible.mod` | `PROBLEM HAS NO PRIMAL FEASIBLE SOLUTION` |
| Viewer kernel | `ts-kernel-ok` on the unit-weight commit cases |

`fh_solver_probe` returns `FH_REJECT_SOLVER`. There is no solver inside the C kernel. GLPK is an external check of the AMPL model, not a proof of the kernel.

## Unverified

- Obligation 9. There is no machine-checked correspondence between Lean and the C (or Modula-2) code. The C and Modula-2 suites test the same arithmetic examples; they do not prove translation.
- Obligation 10. `ccomp` is not installed. `ocaml` is not installed. `apt-get` cannot write `/var/cache/apt`, so CompCert cannot be provisioned here. `fh/asm/fh_kernel.s` and `fh/asm/kernel.s` are `gcc -S` output with an AGPL header comment in front. They are not CompCert assembly and carry no semantics-preservation claim.
- Obligation 6 in Lean. Limb overflow is a C/Modula-2 rejection test. Lean `Int` does not wrap, so there is no Lean theorem about a 16-limb overflow.
- The browser pit evaluates the default integer model in TypeScript. It is not the certified kernel.

## Rebuild

```
cd fh
make test test-compile-fail test-link-fail asm m2 host
glpsol --math ampl/feasible.mod
glpsol --math ampl/infeasible.mod
cd lean && lake build    # leanprover/lean4:v4.21.0
```

In this sandbox `gm2` and `glpsol` live under `/opt/fh-tools` and need
`LD_LIBRARY_PATH=/opt/fh-tools/usr/lib/x86_64-linux-gnu`.
A stock machine uses the same `make` targets once `gcc`, `gm2` (GCC 12), and `glpsol` 5 are on `PATH`.
CompCert remains an external blocker until `ccomp` exists.
