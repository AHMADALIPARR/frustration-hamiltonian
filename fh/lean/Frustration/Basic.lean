-- Copyright (C) 2026 AHMAD ALI PARR
-- SPDX-License-Identifier: AGPL-3.0-or-later

/- Frustration Hamiltonian.
   Zero Mathlib. No sorry. No added axioms.
   This development does not claim CompCert or Lean-to-C correspondence. -/

namespace Frustration

def inBox (v : Int) : Bool :=
  decide (0 ≤ v) && decide (v ≤ 7)

def sameCell (x y z x' y' z' : Int) : Bool :=
  decide (x = x') && decide (y = y') && decide (z = z')

structure State where
  x0 : Int
  y0 : Int
  z0 : Int
  x1 : Int
  y1 : Int
  z1 : Int
  x2 : Int
  y2 : Int
  z2 : Int
  generation : Nat

def hardValid (s : State) : Bool :=
  inBox s.x0 && inBox s.y0 && inBox s.z0 &&
  inBox s.x1 && inBox s.y1 && inBox s.z1 &&
  inBox s.x2 && inBox s.y2 && inBox s.z2 &&
  !sameCell s.x0 s.y0 s.z0 s.x1 s.y1 s.z1 &&
  !sameCell s.x0 s.y0 s.z0 s.x2 s.y2 s.z2 &&
  !sameCell s.x1 s.y1 s.z1 s.x2 s.y2 s.z2

def manh (a b : Int) : Nat := (a - b).natAbs

def manhattan (s : State) (i j : Nat) : Nat :=
  if i = 0 ∧ j = 1 then manh s.x0 s.x1 + manh s.y0 s.y1 + manh s.z0 s.z1
  else if i = 0 ∧ j = 2 then manh s.x0 s.x2 + manh s.y0 s.y2 + manh s.z0 s.z2
  else manh s.x1 s.x2 + manh s.y1 s.y2 + manh s.z1 s.z2

def contact (s : State) (i j : Nat) : Int :=
  if manhattan s i j = 1 then 1 else 0

def energy (s : State) : Int :=
  s.y0 + s.y1 + s.y2 + contact s 0 1 + contact s 0 2 + contact s 1 2

def token : Nat := 0x46525354

structure Auth where
  actor : Nat
  mask : Nat
  generation : Nat
  token : Nat
  descent : Bool

def moved0 (s t : State) : Bool :=
  decide (s.x0 ≠ t.x0) || decide (s.y0 ≠ t.y0) || decide (s.z0 ≠ t.z0)

def moved1 (s t : State) : Bool :=
  decide (s.x1 ≠ t.x1) || decide (s.y1 ≠ t.y1) || decide (s.z1 ≠ t.z1)

def moved2 (s t : State) : Bool :=
  decide (s.x2 ≠ t.x2) || decide (s.y2 ≠ t.y2) || decide (s.z2 ≠ t.z2)

def moverCount (s t : State) : Nat :=
  (if moved0 s t then 1 else 0) + (if moved1 s t then 1 else 0) + (if moved2 s t then 1 else 0)

def soleIs (s t : State) (actor : Nat) : Bool :=
  (!moved0 s t || decide (actor = 0)) &&
  (!moved1 s t || decide (actor = 1)) &&
  (!moved2 s t || decide (actor = 2))

def authorized (s t : State) (a : Auth) : Bool :=
  decide (a.token = token) &&
  decide (a.actor ≤ 2) &&
  decide (a.mask &&& (1 <<< a.actor) ≠ 0) &&
  decide (a.generation = s.generation) &&
  (decide (moverCount s t ≠ 1) || soleIs s t a.actor)

def stepOk (d : Int) : Bool :=
  decide (-1 ≤ d) && decide (d ≤ 1)

def axisOk (dx dy dz : Int) : Bool :=
  stepOk dx && stepOk dy && stepOk dz &&
  decide (dx.natAbs + dy.natAbs + dz.natAbs ≤ 1)

def verified (s t : State) : Bool :=
  decide (t.generation = s.generation) &&
  axisOk (t.x0 - s.x0) (t.y0 - s.y0) (t.z0 - s.z0) &&
  axisOk (t.x1 - s.x1) (t.y1 - s.y1) (t.z1 - s.z1) &&
  axisOk (t.x2 - s.x2) (t.y2 - s.y2) (t.z2 - s.z2) &&
  decide (moverCount s t ≤ 1)

def commit (s t : State) (a : Auth) : Bool :=
  hardValid t && authorized s t a && verified s t &&
  (!a.descent || decide (energy t ≤ energy s))

theorem valid_state_meets_hard {s t : State} {a : Auth}
    (h : commit s t a = true) : hardValid t = true := by
  by_cases hh : hardValid t = true
  · exact hh
  · simp [commit, hh] at h

theorem accepted_preserves_hard {s t : State} {a : Auth}
    (h : commit s t a = true) : hardValid t = true :=
  valid_state_meets_hard h

theorem unauthorized_cannot_commit {s t : State} {a : Auth}
    (h : authorized s t a = false) : commit s t a = false := by
  simp [commit, h]

theorem descent_does_not_increase {s t : State} {a : Auth}
    (h : commit s t a = true) (hd : a.descent = true) : energy t ≤ energy s := by
  simp [commit, Bool.and_eq_true, hd, decide_eq_true_iff] at h
  exact h.2

theorem identical_inputs_identical_commit (s t : State) (a : Auth) :
    commit s t a = commit s t a := rfl

/- Rational normalization. A zero denominator is rejected, never inverted. -/

structure Q where
  num : Int
  den : Nat

def normalize (n d : Int) : Option Q :=
  if d = 0 then
    none
  else
    let n' := if d < 0 then -n else n
    let den := d.natAbs
    let g := n'.natAbs.gcd den
    some { num := n' / (Int.ofNat g), den := den / g }

theorem normalize_rejects_zero (n : Int) : normalize n 0 = none := by
  simp [normalize]

theorem normalize_den_pos {n d : Int} {q : Q}
    (hd : d ≠ 0) (hq : normalize n d = some q) : 0 < q.den := by
  simp [normalize, hd] at hq
  let n' := if d < 0 then -n else n
  have hdnat : 0 < d.natAbs := Nat.pos_of_ne_zero (by simpa [Int.natAbs_eq_zero] using hd)
  have hdiv : 0 < d.natAbs / n'.natAbs.gcd d.natAbs :=
    Nat.div_gcd_pos_of_pos_right n'.natAbs hdnat
  have hq' : q = { num := n' / ↑(n'.natAbs.gcd d.natAbs), den := d.natAbs / n'.natAbs.gcd d.natAbs } := by
    simpa [n'] using hq.symm
  simpa [hq'] using hdiv

theorem normalize_coprime {n d : Int} {q : Q}
    (hd : d ≠ 0) (hq : normalize n d = some q) : q.num.natAbs.gcd q.den = 1 := by
  simp [normalize, hd] at hq
  let n' := if d < 0 then -n else n
  have hdnat : d.natAbs ≠ 0 := by simpa [Int.natAbs_eq_zero] using hd
  have hg : 0 < Int.gcd n' (Int.ofNat d.natAbs) :=
    Int.gcd_pos_of_ne_zero_right n' (by simpa using hdnat)
  have h := Int.gcd_ediv_gcd_ediv_gcd (i := n') (j := Int.ofNat d.natAbs) hg
  have hq' :
      q = { num := n' / ↑(n'.natAbs.gcd d.natAbs), den := d.natAbs / n'.natAbs.gcd d.natAbs } := by
    simpa [n'] using hq.symm
  rw [hq']
  simpa [Int.gcd, Int.natCast_ediv, Nat.gcd_dvd_right] using h

private theorem cross_div {a b g : Int} (ha : g ∣ a) (hb : g ∣ b) :
    a / g * b = a * (b / g) := by
  have h1 : a / g * g = a := Int.ediv_mul_cancel_of_dvd ha
  have h2 : b / g * g = b := Int.ediv_mul_cancel_of_dvd hb
  calc
    a / g * b = a / g * (b / g * g) := by rw [h2]
    _ = a / g * (g * (b / g)) := by rw [Int.mul_comm (b / g) g]
    _ = a / g * g * (b / g) := by rw [← Int.mul_assoc]
    _ = a * (b / g) := by rw [h1]

theorem normalize_preserves {n d : Int} {q : Q}
    (hd : d ≠ 0) (hq : normalize n d = some q) :
    q.num * d = n * (Int.ofNat q.den) := by
  rw [normalize] at hq
  simp [hd] at hq
  let n' := if d < 0 then -n else n
  let gnat := n'.natAbs.gcd d.natAbs
  have hq' : q = { num := n' / (Int.ofNat gnat), den := d.natAbs / gnat } := by
    simpa [n', gnat] using hq.symm
  have hdnat : d.natAbs ≠ 0 := by simpa [Int.natAbs_eq_zero] using hd
  have hg : Int.ofNat gnat ≠ 0 := by
    have : gnat ≠ 0 := Nat.gcd_ne_zero_right hdnat
    simpa using this
  have hga : Int.ofNat gnat ∣ n' := by
    simpa [gnat] using (Int.gcd_dvd_left n' (Int.ofNat d.natAbs))
  have hgb : Int.ofNat gnat ∣ Int.ofNat d.natAbs := by
    simpa [gnat] using (Int.gcd_dvd_right n' (Int.ofNat d.natAbs))
  have hcross := cross_div (a := n') (b := Int.ofNat d.natAbs) (g := Int.ofNat gnat) hga hgb
  have hden : (↑(d.natAbs / gnat) : Int) = (↑d.natAbs) / (↑gnat) :=
    Int.natCast_ediv d.natAbs gnat
  by_cases hlt : d < 0
  · let ad : Nat := d.natAbs
    have habs : d = -((ad : Int)) := by
      simpa [ad] using (Int.eq_neg_natAbs_of_nonpos (Int.le_of_lt hlt))
    have hn : n' = -n := by simp [n', hlt]
    rw [hq']
    have hm : (-n) / ↑gnat * (ad : Int) = (-n) * ((ad : Int) / ↑gnat) := by
      simpa [hn, ad] using hcross
    calc
      (n' / ↑gnat) * d = ((-n) / ↑gnat) * d := by rw [hn]
      _ = ((-n) / ↑gnat) * (-(ad : Int)) := by rw [habs]
      _ = -(((-n) / ↑gnat) * (ad : Int)) := by rw [Int.mul_neg]
      _ = -((-n) * ((ad : Int) / ↑gnat)) := by rw [hm]
      _ = n * ((ad : Int) / ↑gnat) := by rw [Int.neg_mul, Int.neg_neg]
      _ = n * ↑(ad / gnat) := by rw [← Int.natCast_ediv ad gnat]
  · let ad : Nat := d.natAbs
    have hnn : 0 ≤ d := Int.not_lt.mp hlt
    have hn : n' = n := by simp [n', hlt]
    have habs : (ad : Int) = d := by
      simpa [ad] using Int.natAbs_of_nonneg hnn
    rw [hq', hn]
    calc
      n / ↑gnat * d = n / ↑gnat * (ad : Int) := by rw [← habs]
      _ = n * ((ad : Int) / ↑gnat) := by simpa [hn, ad] using hcross
      _ = n * ↑(ad / gnat) := by rw [← Int.natCast_ediv ad gnat]

theorem normalize_zero_canonical {d : Int} {q : Q}
    (hd : d ≠ 0) (hq : normalize 0 d = some q) : q.num = 0 ∧ q.den = 1 := by
  simp [normalize, hd, Int.natAbs_zero, Nat.gcd_zero_left] at hq
  have hdpos : 0 < d.natAbs := Nat.pos_of_ne_zero (by simpa [Int.natAbs_eq_zero] using hd)
  have hden : d.natAbs / d.natAbs = 1 := Nat.div_self hdpos
  -- `simp` may already have reduced the denominator; cover both shapes.
  first
  | cases hq
    constructor <;> rfl
  | have hq' : q = { num := 0, den := d.natAbs / d.natAbs } := by
      simpa [hden] using hq.symm
    rw [hq', hden]
    constructor <;> rfl

/- Certificates. -/

theorem bound_cert_empty {lo hi : Int} (h : hi < lo) :
    ¬ ∃ x : Int, lo ≤ x ∧ x ≤ hi := by
  intro ⟨x, hlo, hhi⟩
  omega

theorem force_overlap_empty {p q : Prop} (hp : p) (hq : q) (h : p → ¬ q) : False :=
  h hp hq

def allLt (xs : List Nat) (c : Nat) : Prop := ∀ x, x ∈ xs → x < c

private theorem filter_compl_length (p : Nat → Bool) (l : List Nat) :
    (l.filter p).length + (l.filter (fun x => !p x)).length = l.length := by
  induction l with
  | nil => simp
  | cons a l ih =>
      cases h : p a with
      | false =>
          have h1 : ((a :: l).filter p).length = (l.filter p).length := by
            simp [List.filter_cons, h]
          have h2 : ((a :: l).filter (fun x => !p x)).length =
              (l.filter (fun x => !p x)).length + 1 := by
            simp [List.filter_cons, h, List.length_cons]
          rw [h1, h2, List.length_cons]
          omega
      | true =>
          have h1 : ((a :: l).filter p).length = (l.filter p).length + 1 := by
            simp [List.filter_cons, h, List.length_cons]
          have h2 : ((a :: l).filter (fun x => !p x)).length =
              (l.filter (fun x => !p x)).length := by
            simp [List.filter_cons, h]
          rw [h1, h2, List.length_cons]
          omega

private theorem filter_eq_of_mem {p q : Nat → Bool} {l : List Nat}
    (h : ∀ y, y ∈ l → p y = q y) : l.filter p = l.filter q := by
  induction l with
  | nil => rfl
  | cons a l ih =>
      have ha : p a = q a := h a List.mem_cons_self
      have ht : ∀ y, y ∈ l → p y = q y := fun y hy => h y (List.mem_cons_of_mem a hy)
      rw [List.filter_cons, List.filter_cons, ha, ih ht]

private theorem nodup_fixed {a : Nat} {xs : List Nat}
    (hnd : xs.Nodup) (hall : ∀ y, y ∈ xs → y = a) : xs.length ≤ 1 := by
  cases xs with
  | nil => exact Nat.zero_le _
  | cons x ys =>
      cases ys with
      | nil => simp [List.length_cons]
      | cons z zs =>
          have hx : x = a := hall x List.mem_cons_self
          have hz : z = a := hall z (List.mem_cons_of_mem x List.mem_cons_self)
          have hin : x ∈ z :: zs := by
            rw [hx, hz]
            exact List.mem_cons_self
          exact False.elim ((List.nodup_cons.mp hnd).1 hin)

theorem pigeon_list : ∀ (c : Nat) (xs : List Nat), allLt xs c → xs.Nodup → xs.length ≤ c := by
  intro c
  induction c with
  | zero =>
      intro xs hlt _
      cases xs with
      | nil => exact Nat.zero_le 0
      | cons x _ => exact False.elim (Nat.not_lt_zero x (hlt x List.mem_cons_self))
  | succ c ih =>
      intro xs hlt hnd
      let lo := xs.filter (fun y => decide (y < c))
      let hi := xs.filter (fun y => !decide (y < c))
      have hsplit := filter_compl_length (fun y => decide (y < c)) xs
      have hlt_lo : allLt lo c := by
        intro y hy
        exact of_decide_eq_true (List.mem_filter.mp hy).2
      have hnd_lo : lo.Nodup := List.Nodup.sublist (List.filter_sublist (l := xs)) hnd
      have hlo : lo.length ≤ c := ih lo hlt_lo hnd_lo
      have heqpred : ∀ y, y ∈ xs → (!decide (y < c)) = decide (y = c) := by
        intro y hy
        have hyc : y < c + 1 := hlt y hy
        by_cases hyc' : y < c
        · have h1 : decide (y < c) = true := by
            cases hd : decide (y < c) with
            | false => exact False.elim (of_decide_eq_false hd hyc')
            | true => rfl
          have hne : y ≠ c := by omega
          have h2 : decide (y = c) = false := by
            cases hd : decide (y = c) with
            | false => rfl
            | true => exact False.elim (hne (of_decide_eq_true hd))
          simp [h1, h2]
        · have hge : c ≤ y := Nat.not_lt.mp hyc'
          have hyeq : y = c := Nat.eq_of_le_of_lt_succ hge hyc
          have h1 : decide (y < c) = false := by
            cases hd : decide (y < c) with
            | true => exact False.elim (hyc' (of_decide_eq_true hd))
            | false => rfl
          have h2 : decide (y = c) = true := by
            cases hd : decide (y = c) with
            | false => exact False.elim (of_decide_eq_false hd hyeq)
            | true => rfl
          simp [h1, h2]
      have hhi_eq : hi = xs.filter (fun y => decide (y = c)) :=
        filter_eq_of_mem heqpred
      have hnd_hi : (xs.filter (fun y => decide (y = c))).Nodup :=
        List.Nodup.sublist (List.filter_sublist (l := xs)) hnd
      have hall : ∀ y, y ∈ xs.filter (fun y => decide (y = c)) → y = c := by
        intro y hy
        exact of_decide_eq_true (List.mem_filter.mp hy).2
      have hhi : hi.length ≤ 1 := by
        have hlen := nodup_fixed hnd_hi hall
        simpa [hhi_eq] using hlen
      have hsum : lo.length + hi.length = xs.length := by
        simpa [lo, hi] using hsplit
      omega

theorem pigeon_cert {b c : Nat} (h : c < b) :
    ¬ ∃ xs : List Nat, xs.length = b ∧ allLt xs c ∧ xs.Nodup := by
  intro ⟨xs, hlen, hlt, hnd⟩
  have hle := pigeon_list c xs hlt hnd
  omega

theorem energy_compare_is_exact (s t : State) :
    (decide (energy t ≤ energy s) = true) ↔ energy t ≤ energy s :=
  decide_eq_true_iff

end Frustration
