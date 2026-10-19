IMPLEMENTATION MODULE M2Rational ;

(* Copyright (C) 2026 AHMAD ALI PARR
   SPDX-License-Identifier: AGPL-3.0-or-later
   Eight-limb exact rationals. Internal scratch holds twelve limbs so a
   one-bit shift of an eight-limb remainder still fits. Results that need a
   ninth limb are rejected. *)

CONST
  Base = 1000000000 ;
  Cap = 12 ;
  Keep = 8 ;

TYPE
  Big = RECORD
          d: ARRAY [0..11] OF INTEGER ;
          n: INTEGER ;
          neg: BOOLEAN
        END ;

PROCEDURE SetZero (VAR a: Big) ;
VAR
  i: INTEGER ;
BEGIN
  FOR i := 0 TO Cap - 1 DO
    a.d[i] := 0
  END ;
  a.n := 0 ;
  a.neg := FALSE
END SetZero ;

PROCEDURE Trim (VAR a: Big) ;
BEGIN
  WHILE (a.n > 0) AND (a.d[a.n - 1] = 0) DO
    DEC (a.n)
  END ;
  IF a.n = 0 THEN
    a.neg := FALSE
  END
END Trim ;

PROCEDURE SetAbsInt (VAR a: Big; v: INTEGER) ;
VAR
  i: INTEGER ;
BEGIN
  SetZero (a) ;
  i := 0 ;
  WHILE v <> 0 DO
    a.d[i] := v MOD Base ;
    v := v DIV Base ;
    INC (i)
  END ;
  a.n := i
END SetAbsInt ;

PROCEDURE Shl1 (VAR a: Big; bit: INTEGER; VAR ov: BOOLEAN) ;
VAR
  i, v, carry: INTEGER ;
BEGIN
  ov := FALSE ;
  carry := bit ;
  IF a.n = 0 THEN
    IF bit = 0 THEN
      RETURN
    END ;
    a.d[0] := 0 ;
    a.n := 1
  END ;
  i := 0 ;
  WHILE i < a.n DO
    v := a.d[i] * 2 + carry ;
    a.d[i] := v MOD Base ;
    carry := v DIV Base ;
    INC (i)
  END ;
  IF carry <> 0 THEN
    IF a.n >= Cap THEN
      ov := TRUE ;
      RETURN
    END ;
    a.d[a.n] := carry ;
    INC (a.n)
  END
END Shl1 ;

PROCEDURE Shr1 (VAR a: Big) ;
VAR
  i, cur, nxt: INTEGER ;
BEGIN
  cur := 0 ;
  i := a.n - 1 ;
  WHILE i >= 0 DO
    nxt := a.d[i] MOD 2 ;
    a.d[i] := a.d[i] DIV 2 + cur * (Base DIV 2) ;
    cur := nxt ;
    DEC (i)
  END ;
  Trim (a)
END Shr1 ;

PROCEDURE SetPow2 (VAR a: Big; e: INTEGER; VAR ov: BOOLEAN) ;
VAR
  i: INTEGER ;
BEGIN
  SetZero (a) ;
  a.d[0] := 1 ;
  a.n := 1 ;
  i := 0 ;
  WHILE i < e DO
    Shl1 (a, 0, ov) ;
    IF ov THEN
      RETURN
    END ;
    INC (i)
  END
END SetPow2 ;

PROCEDURE CmpAbs (a, b: Big) : INTEGER ;
VAR
  i: INTEGER ;
BEGIN
  IF a.n < b.n THEN
    RETURN -1
  END ;
  IF a.n > b.n THEN
    RETURN 1
  END ;
  i := a.n - 1 ;
  WHILE i >= 0 DO
    IF a.d[i] < b.d[i] THEN
      RETURN -1
    END ;
    IF a.d[i] > b.d[i] THEN
      RETURN 1
    END ;
    DEC (i)
  END ;
  RETURN 0
END CmpAbs ;

PROCEDURE AddAbs (a, b: Big; VAR o: Big; VAR ov: BOOLEAN) ;
VAR
  i, av, bv, s, carry, nn: INTEGER ;
  t: Big ;
BEGIN
  ov := FALSE ;
  SetZero (t) ;
  carry := 0 ;
  IF a.n > b.n THEN
    nn := a.n
  ELSE
    nn := b.n
  END ;
  i := 0 ;
  WHILE (i < nn) OR (carry <> 0) DO
    IF i >= Cap THEN
      ov := TRUE ;
      SetZero (o) ;
      RETURN
    END ;
    av := 0 ;
    bv := 0 ;
    IF i < a.n THEN
      av := a.d[i]
    END ;
    IF i < b.n THEN
      bv := b.d[i]
    END ;
    s := av + bv + carry ;
    t.d[i] := s MOD Base ;
    carry := s DIV Base ;
    INC (i)
  END ;
  t.n := i ;
  Trim (t) ;
  o := t
END AddAbs ;

PROCEDURE SubAbs (a, b: Big; VAR o: Big) ;
VAR
  i, av, bv, s, borrow: INTEGER ;
  t: Big ;
BEGIN
  SetZero (t) ;
  borrow := 0 ;
  i := 0 ;
  WHILE i < a.n DO
    av := a.d[i] ;
    bv := 0 ;
    IF i < b.n THEN
      bv := b.d[i]
    END ;
    s := av - bv - borrow ;
    IF s < 0 THEN
      s := s + Base ;
      borrow := 1
    ELSE
      borrow := 0
    END ;
    t.d[i] := s ;
    INC (i)
  END ;
  t.n := a.n ;
  Trim (t) ;
  o := t
END SubAbs ;

PROCEDURE AddSmall (VAR a: Big; v: INTEGER; VAR ov: BOOLEAN) ;
VAR
  i, s, carry: INTEGER ;
BEGIN
  ov := FALSE ;
  carry := v ;
  i := 0 ;
  WHILE carry <> 0 DO
    IF i >= Cap THEN
      ov := TRUE ;
      RETURN
    END ;
    IF i >= a.n THEN
      a.d[i] := 0 ;
      a.n := i + 1
    END ;
    s := a.d[i] + carry ;
    a.d[i] := s MOD Base ;
    carry := s DIV Base ;
    INC (i)
  END ;
  Trim (a)
END AddSmall ;

PROCEDURE BitsOf (a: Big; VAR nbits: INTEGER; VAR bits: ARRAY OF BOOLEAN) ;
VAR
  t: Big ;
BEGIN
  t := a ;
  nbits := 0 ;
  WHILE t.n <> 0 DO
    IF t.d[0] MOD 2 = 1 THEN
      bits[nbits] := TRUE
    ELSE
      bits[nbits] := FALSE
    END ;
    Shr1 (t) ;
    INC (nbits)
  END
END BitsOf ;

PROCEDURE DivMod (a, b: Big; VAR q, r: Big; VAR ov: BOOLEAN) ;
VAR
  bits: ARRAY [0..399] OF BOOLEAN ;
  nb, i, bit: INTEGER ;
BEGIN
  ov := FALSE ;
  SetZero (q) ;
  SetZero (r) ;
  IF b.n = 0 THEN
    ov := TRUE ;
    RETURN
  END ;
  IF a.n = 0 THEN
    RETURN
  END ;
  BitsOf (a, nb, bits) ;
  i := nb - 1 ;
  WHILE i >= 0 DO
    IF bits[i] THEN
      bit := 1
    ELSE
      bit := 0
    END ;
    Shl1 (r, bit, ov) ;
    IF ov THEN
      RETURN
    END ;
    Shl1 (q, 0, ov) ;
    IF ov THEN
      RETURN
    END ;
    IF CmpAbs (r, b) >= 0 THEN
      SubAbs (r, b, r) ;
      AddSmall (q, 1, ov) ;
      IF ov THEN
        RETURN
      END
    END ;
    DEC (i)
  END
END DivMod ;

PROCEDURE GcdAbs (a, b: Big; VAR g: Big; VAR ov: BOOLEAN) ;
VAR
  aa, bb, q, r: Big ;
BEGIN
  ov := FALSE ;
  aa := a ;
  bb := b ;
  aa.neg := FALSE ;
  bb.neg := FALSE ;
  WHILE bb.n <> 0 DO
    DivMod (aa, bb, q, r, ov) ;
    IF ov THEN
      SetZero (g) ;
      RETURN
    END ;
    aa := bb ;
    bb := r
  END ;
  g := aa ;
  g.neg := FALSE
END GcdAbs ;

PROCEDURE MulAbs (a, b: Big; VAR o: Big; VAR ov: BOOLEAN) ;
VAR
  acc: ARRAY [0..15] OF INTEGER ;
  i, j, k, carry, t: INTEGER ;
BEGIN
  ov := FALSE ;
  FOR i := 0 TO 15 DO
    acc[i] := 0
  END ;
  IF (a.n = 0) OR (b.n = 0) THEN
    SetZero (o) ;
    RETURN
  END ;
  FOR i := 0 TO a.n - 1 DO
    carry := 0 ;
    FOR j := 0 TO b.n - 1 DO
      k := i + j ;
      t := acc[k] + a.d[i] * b.d[j] + carry ;
      acc[k] := t MOD Base ;
      carry := t DIV Base
    END ;
    k := i + b.n ;
    WHILE carry <> 0 DO
      IF k > 15 THEN
        ov := TRUE ;
        SetZero (o) ;
        RETURN
      END ;
      t := acc[k] + carry ;
      acc[k] := t MOD Base ;
      carry := t DIV Base ;
      INC (k)
    END
  END ;
  FOR i := Keep TO 15 DO
    IF acc[i] <> 0 THEN
      ov := TRUE ;
      SetZero (o) ;
      RETURN
    END
  END ;
  SetZero (o) ;
  FOR i := 0 TO Keep - 1 DO
    o.d[i] := acc[i]
  END ;
  o.n := Keep ;
  Trim (o)
END MulAbs ;

PROCEDURE AddSigned (a, b: Big; VAR o: Big; VAR ov: BOOLEAN) ;
VAR
  aa, bb, t: Big ;
BEGIN
  ov := FALSE ;
  aa := a ;
  bb := b ;
  aa.neg := FALSE ;
  bb.neg := FALSE ;
  IF a.neg = b.neg THEN
    AddAbs (aa, bb, t, ov) ;
    IF ov THEN
      SetZero (o) ;
      RETURN
    END ;
    IF a.neg AND (t.n <> 0) THEN
      t.neg := TRUE
    END ;
    o := t
  ELSIF CmpAbs (aa, bb) >= 0 THEN
    SubAbs (aa, bb, t) ;
    IF a.neg AND (t.n <> 0) THEN
      t.neg := TRUE
    END ;
    o := t
  ELSE
    SubAbs (bb, aa, t) ;
    IF b.neg AND (t.n <> 0) THEN
      t.neg := TRUE
    END ;
    o := t
  END
END AddSigned ;

PROCEDURE LoadNum (q: Rational; VAR a: Big) ;
VAR
  i: INTEGER ;
BEGIN
  SetZero (a) ;
  a.n := q.nn ;
  a.neg := q.nneg ;
  FOR i := 0 TO Cap - 1 DO
    a.d[i] := q.nl[i]
  END ;
  Trim (a)
END LoadNum ;

PROCEDURE LoadDen (q: Rational; VAR a: Big) ;
VAR
  i: INTEGER ;
BEGIN
  SetZero (a) ;
  a.n := q.dn ;
  FOR i := 0 TO Cap - 1 DO
    a.d[i] := q.dl[i]
  END ;
  Trim (a)
END LoadDen ;

PROCEDURE Store (num, den: Big; VAR o: Rational) ;
VAR
  i: INTEGER ;
BEGIN
  FOR i := 0 TO Cap - 1 DO
    o.nl[i] := 0 ;
    o.dl[i] := 0
  END ;
  FOR i := 0 TO Cap - 1 DO
    o.nl[i] := num.d[i] ;
    o.dl[i] := den.d[i]
  END ;
  o.nn := num.n ;
  o.dn := den.n ;
  o.nneg := num.neg
END Store ;

PROCEDURE Clear (VAR o: Rational) ;
VAR
  z, one: Big ;
BEGIN
  SetZero (z) ;
  SetZero (one) ;
  one.d[0] := 1 ;
  one.n := 1 ;
  Store (z, one, o)
END Clear ;

PROCEDURE Finish (num, den: Big; VAR o: Rational) : INTEGER ;
VAR
  g, qn, qd, junk: Big ;
  ov: BOOLEAN ;
  sign: BOOLEAN ;
BEGIN
  IF den.neg THEN
    den.neg := FALSE ;
    IF num.n <> 0 THEN
      num.neg := NOT num.neg
    END
  END ;
  IF den.n = 0 THEN
    Clear (o) ;
    RETURN RatDenom
  END ;
  sign := num.neg AND (num.n <> 0) ;
  num.neg := FALSE ;
  GcdAbs (num, den, g, ov) ;
  IF ov THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  DivMod (num, g, qn, junk, ov) ;
  IF ov THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  DivMod (den, g, qd, junk, ov) ;
  IF ov THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  IF (qn.n > Keep) OR (qd.n > Keep) THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  IF qn.n = 0 THEN
    sign := FALSE ;
    SetZero (qd) ;
    qd.d[0] := 1 ;
    qd.n := 1
  END ;
  qn.neg := sign ;
  Store (qn, qd, o) ;
  RETURN RatOk
END Finish ;

PROCEDURE TooBig (a: Big) : BOOLEAN ;
BEGIN
  RETURN a.n > Keep
END TooBig ;

PROCEDURE RatFromInt (num, den: INTEGER; VAR o: Rational) : INTEGER ;
VAR
  nb, db: Big ;
  nneg, dneg, ov: BOOLEAN ;
BEGIN
  IF den = 0 THEN
    Clear (o) ;
    RETURN RatDenom
  END ;
  nneg := num < 0 ;
  dneg := den < 0 ;
  IF num = MIN (INTEGER) THEN
    SetPow2 (nb, 63, ov) ;
    IF ov THEN
      Clear (o) ;
      RETURN RatOverflow
    END
  ELSIF num < 0 THEN
    SetAbsInt (nb, -num)
  ELSE
    SetAbsInt (nb, num)
  END ;
  IF den = MIN (INTEGER) THEN
    SetPow2 (db, 63, ov) ;
    IF ov THEN
      Clear (o) ;
      RETURN RatOverflow
    END
  ELSIF den < 0 THEN
    SetAbsInt (db, -den)
  ELSE
    SetAbsInt (db, den)
  END ;
  IF nneg <> dneg THEN
    nb.neg := nb.n <> 0
  END ;
  RETURN Finish (nb, db, o)
END RatFromInt ;

PROCEDURE RatAdd (a, b: Rational; VAR o: Rational) : INTEGER ;
VAR
  an, ad, bn, bd, left, right, num, den: Big ;
  ov: BOOLEAN ;
BEGIN
  LoadNum (a, an) ;
  LoadDen (a, ad) ;
  LoadNum (b, bn) ;
  LoadDen (b, bd) ;
  IF (ad.n = 0) OR (bd.n = 0) THEN
    Clear (o) ;
    RETURN RatDenom
  END ;
  MulAbs (an, bd, left, ov) ;
  IF ov THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  left.neg := an.neg ;
  MulAbs (bn, ad, right, ov) ;
  IF ov THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  right.neg := bn.neg ;
  AddSigned (left, right, num, ov) ;
  IF ov OR TooBig (num) THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  MulAbs (ad, bd, den, ov) ;
  IF ov OR TooBig (den) THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  RETURN Finish (num, den, o)
END RatAdd ;

PROCEDURE RatSub (a, b: Rational; VAR o: Rational) : INTEGER ;
VAR
  nb: Rational ;
BEGIN
  nb := b ;
  IF nb.nn <> 0 THEN
    nb.nneg := NOT nb.nneg
  END ;
  RETURN RatAdd (a, nb, o)
END RatSub ;

PROCEDURE RatMul (a, b: Rational; VAR o: Rational) : INTEGER ;
VAR
  an, ad, bn, bd, num, den: Big ;
  ov: BOOLEAN ;
BEGIN
  LoadNum (a, an) ;
  LoadDen (a, ad) ;
  LoadNum (b, bn) ;
  LoadDen (b, bd) ;
  IF (ad.n = 0) OR (bd.n = 0) THEN
    Clear (o) ;
    RETURN RatDenom
  END ;
  MulAbs (an, bn, num, ov) ;
  IF ov THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  IF an.neg <> bn.neg THEN
    num.neg := num.n <> 0
  END ;
  MulAbs (ad, bd, den, ov) ;
  IF ov OR TooBig (num) OR TooBig (den) THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  RETURN Finish (num, den, o)
END RatMul ;

PROCEDURE RatDiv (a, b: Rational; VAR o: Rational) : INTEGER ;
VAR
  an, ad, bn, bd, num, den: Big ;
  ov: BOOLEAN ;
BEGIN
  LoadNum (a, an) ;
  LoadDen (a, ad) ;
  LoadNum (b, bn) ;
  LoadDen (b, bd) ;
  IF (ad.n = 0) OR (bd.n = 0) OR (bn.n = 0) THEN
    Clear (o) ;
    RETURN RatDenom
  END ;
  MulAbs (an, bd, num, ov) ;
  IF ov THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  IF an.neg <> bn.neg THEN
    num.neg := num.n <> 0
  END ;
  MulAbs (ad, bn, den, ov) ;
  IF ov OR TooBig (num) OR TooBig (den) THEN
    Clear (o) ;
    RETURN RatOverflow
  END ;
  RETURN Finish (num, den, o)
END RatDiv ;

PROCEDURE RatCmp (a, b: Rational; VAR c: INTEGER) : INTEGER ;
VAR
  an, ad, bn, bd, left, right: Big ;
  ov: BOOLEAN ;
BEGIN
  c := 0 ;
  LoadNum (a, an) ;
  LoadDen (a, ad) ;
  LoadNum (b, bn) ;
  LoadDen (b, bd) ;
  IF (ad.n = 0) OR (bd.n = 0) THEN
    RETURN RatDenom
  END ;
  MulAbs (an, bd, left, ov) ;
  IF ov THEN
    RETURN RatOverflow
  END ;
  left.neg := an.neg ;
  MulAbs (bn, ad, right, ov) ;
  IF ov THEN
    RETURN RatOverflow
  END ;
  right.neg := bn.neg ;
  IF (left.n = 0) AND (right.n = 0) THEN
    c := 0 ;
    RETURN RatOk
  END ;
  IF left.neg <> right.neg THEN
    IF left.neg THEN
      c := -1
    ELSE
      c := 1
    END ;
    RETURN RatOk
  END ;
  c := CmpAbs (left, right) ;
  IF left.neg THEN
    c := -c
  END ;
  RETURN RatOk
END RatCmp ;

PROCEDURE RatNumNeg (a: Rational) : BOOLEAN ;
BEGIN
  RETURN a.nneg
END RatNumNeg ;

PROCEDURE RatNumLimbs (a: Rational) : INTEGER ;
BEGIN
  RETURN a.nn
END RatNumLimbs ;

PROCEDURE RatDenLimbs (a: Rational) : INTEGER ;
BEGIN
  RETURN a.dn
END RatDenLimbs ;

PROCEDURE RatNumLimb (a: Rational; i: INTEGER) : INTEGER ;
BEGIN
  RETURN a.nl[i]
END RatNumLimb ;

PROCEDURE RatDenLimb (a: Rational; i: INTEGER) : INTEGER ;
BEGIN
  RETURN a.dl[i]
END RatDenLimb ;

END M2Rational.
