<p align="center">
  <img src="media/mark.jpg" alt="Frustra. Three masses, one bond lit." width="520">
</p>

<h1 align="center">Frustration Hamiltonian</h1>

<p align="center">
  Exact rational commit law for three agents in a closed box.<br>
  Height is potential. Contact costs. Overlap is not a bargain.
</p>

<p align="center">
  <img src="media/pit.gif" alt="Aether, Keel, and Vector. Scout, measure, commit." width="720">
</p>

<p align="center"><sub>Scout. Measure. Commit.</sub></p>

<table>
  <tr>
    <td align="center" width="33%">
      <img src="media/plate-measure.png" alt="The lattice while Keel is measured."><br>
      <sub>Measure</sub>
    </td>
    <td align="center" width="33%">
      <img src="media/plate-drop.png" alt="A mass falling through the pit."><br>
      <sub>Mass in flight</sub>
    </td>
    <td align="center" width="33%">
      <img src="media/plate-stir.png" alt="The same pit with descent off."><br>
      <sub>Stir</sub>
    </td>
  </tr>
</table>

<p align="center">
  <img src="media/deck.png" alt="Controls, ledger, and emptiness certificates." width="880">
</p>

<p align="center"><sub>Six axes. The ledger. Bound, pigeon, and forced overlap.</sub></p>

<p align="center">
  <img src="media/phone.png" alt="The pit on a phone." width="280">
</p>

<p align="center"><sub>The same instrument, one column wide.</sub></p>

---

Aether, Keel, and Vector live on an 8×8×8 lattice.

```
H_F(s) = y₀ + y₁ + y₂ + C₀₁ + C₀₂ + C₁₂
```

`Cᵢⱼ` is 1 only when the Manhattan distance is exactly 1.

A commit requires a hard-valid cell, an authorized actor, and a verified unit step of at most one body. With descent on, `H` may not rise. A better soft value never buys a shared cell. Overflow rejects. It does not wrap.

## Certified

Lean 4.21.0, no Mathlib and no `sorry`, proves the commit law, rational normalization, and the emptiness certificates. The C kernel and the Modula-2 rationals are tested on the same examples. GLPK shows one model feasible and one empty.

Not certified: there is no proof the C matches the Lean, and `kernel.s` is `gcc -S`, not CompCert. The ledger is [fh/STATUS.md](fh/STATUS.md).

```
cd fh
make demo
make test
```

`make demo` exits 0 only when descent, the refused rise, stir, overlap, a bad token, and a zero denominator all match.

| Path | |
| --- | --- |
| `fh/c` | C kernel, host FFI, `demo.c` |
| `fh/lean` | Proofs |
| `fh/m2` | Modula-2 exact rationals, and the call into C |
| `fh/ampl` | One feasible model, one empty model |
| `fh/asm` | `gcc -S` listing. Not a semantics proof |

## License

Copyright (C) 2026 AHMAD ALI PARR

The kernel, the proofs, and the models are [GNU AGPL v3 or later](LICENSE) (`AGPL-3.0-or-later`).
