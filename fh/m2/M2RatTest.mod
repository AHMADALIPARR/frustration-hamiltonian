(* Copyright (C) 2026 AHMAD ALI PARR
   SPDX-License-Identifier: AGPL-3.0-or-later *)

MODULE M2RatTest ;

FROM StrIO IMPORT WriteString, WriteLn ;
FROM NumberIO IMPORT WriteInt ;
FROM FIO IMPORT FlushOutErr ;
FROM M2Rational IMPORT Rational, RatOk, RatDenom, RatOverflow,
                       RatFromInt, RatAdd, RatSub, RatMul, RatDiv, RatCmp,
                       RatNumNeg, RatNumLimbs, RatDenLimbs, RatNumLimb, RatDenLimb ;

PROCEDURE Fail (s: ARRAY OF CHAR) ;
BEGIN
  WriteString ("FAIL ") ;
  WriteString (s) ;
  WriteLn ;
  FlushOutErr ;
  HALT
END Fail ;

PROCEDURE Show (q: Rational) ;
VAR
  i: INTEGER ;
BEGIN
  IF RatNumNeg (q) THEN
    WriteString ("-")
  END ;
  i := 0 ;
  WHILE i < RatNumLimbs (q) DO
    WriteInt (RatNumLimb (q, i), 0) ;
    WriteString (",") ;
    INC (i)
  END ;
  WriteString ("/") ;
  i := 0 ;
  WHILE i < RatDenLimbs (q) DO
    WriteInt (RatDenLimb (q, i), 0) ;
    WriteString (",") ;
    INC (i)
  END ;
  WriteLn
END Show ;

PROCEDURE ExpectSmall (name: ARRAY OF CHAR; q: Rational; neg: BOOLEAN; n, d: INTEGER) ;
BEGIN
  IF RatNumNeg (q) <> neg THEN
    Show (q) ;
    Fail (name)
  END ;
  IF (RatNumLimbs (q) <> 1) OR (RatDenLimbs (q) <> 1) THEN
    Show (q) ;
    Fail (name)
  END ;
  IF (RatNumLimb (q, 0) <> n) OR (RatDenLimb (q, 0) <> d) THEN
    Show (q) ;
    Fail (name)
  END
END ExpectSmall ;

PROCEDURE ExpectZero (name: ARRAY OF CHAR; q: Rational) ;
BEGIN
  IF RatNumNeg (q) OR (RatNumLimbs (q) <> 0) THEN
    Show (q) ;
    Fail (name)
  END ;
  IF (RatDenLimbs (q) <> 1) OR (RatDenLimb (q, 0) <> 1) THEN
    Show (q) ;
    Fail (name)
  END
END ExpectZero ;

PROCEDURE Must (name: ARRAY OF CHAR; st, want: INTEGER) ;
BEGIN
  IF st <> want THEN
    WriteInt (st, 0) ;
    WriteString (" <> ") ;
    WriteInt (want, 0) ;
    WriteLn ;
    Fail (name)
  END
END Must ;

VAR
  a, b, c, d, e: Rational ;
  st, cmp, i: INTEGER ;
BEGIN
  st := RatFromInt (1, 2, a) ;
  Must ("from-1/2", st, RatOk) ;
  ExpectSmall ("canon-1/2", a, FALSE, 1, 2) ;

  st := RatFromInt (1, 3, b) ;
  Must ("from-1/3", st, RatOk) ;

  st := RatAdd (a, b, c) ;
  Must ("add-st", st, RatOk) ;
  ExpectSmall ("1/2+1/3", c, FALSE, 5, 6) ;

  st := RatSub (a, b, c) ;
  Must ("sub-st", st, RatOk) ;
  ExpectSmall ("1/2-1/3", c, FALSE, 1, 6) ;

  st := RatSub (b, a, c) ;
  Must ("sub-neg-st", st, RatOk) ;
  ExpectSmall ("1/3-1/2", c, TRUE, 1, 6) ;

  st := RatMul (a, b, c) ;
  Must ("mul-st", st, RatOk) ;
  ExpectSmall ("1/2*1/3", c, FALSE, 1, 6) ;

  st := RatDiv (a, b, c) ;
  Must ("div-st", st, RatOk) ;
  ExpectSmall ("(1/2)/(1/3)", c, FALSE, 3, 2) ;

  st := RatFromInt (3, -6, c) ;
  Must ("negden", st, RatOk) ;
  ExpectSmall ("3/-6", c, TRUE, 1, 2) ;

  st := RatFromInt (-2, -4, c) ;
  Must ("negneg", st, RatOk) ;
  ExpectSmall ("-2/-4", c, FALSE, 1, 2) ;

  st := RatFromInt (0, -5, c) ;
  Must ("zeronum", st, RatOk) ;
  ExpectZero ("0/-5", c) ;

  st := RatFromInt (1, 0, c) ;
  Must ("zeroden", st, RatDenom) ;

  st := RatDiv (a, c, d) ;
  Must ("divzero", st, RatDenom) ;

  st := RatFromInt (2, 4, c) ;
  Must ("reduce", st, RatOk) ;
  ExpectSmall ("2/4", c, FALSE, 1, 2) ;

  st := RatCmp (a, b, cmp) ;
  Must ("cmp-st", st, RatOk) ;
  IF cmp <> 1 THEN
    Fail ("1/2>1/3")
  END ;
  st := RatCmp (b, a, cmp) ;
  IF (st <> RatOk) OR (cmp <> -1) THEN
    Fail ("1/3<1/2")
  END ;
  st := RatCmp (a, a, cmp) ;
  IF (st <> RatOk) OR (cmp <> 0) THEN
    Fail ("cmp-eq")
  END ;

  (* (a+b)-b = a and (a*b)/b = a *)
  st := RatAdd (a, b, c) ;
  st := RatSub (c, b, d) ;
  Must ("round-sub", st, RatOk) ;
  st := RatCmp (d, a, cmp) ;
  IF (st <> RatOk) OR (cmp <> 0) THEN
    Fail ("(a+b)-b")
  END ;
  st := RatMul (a, b, c) ;
  st := RatDiv (c, b, d) ;
  Must ("round-div", st, RatOk) ;
  st := RatCmp (d, a, cmp) ;
  IF (st <> RatOk) OR (cmp <> 0) THEN
    Fail ("(a*b)/b")
  END ;

  (* 10^9 seven times fits; the eighth multiplication overflows. *)
  st := RatFromInt (1, 1, a) ;
  Must ("one", st, RatOk) ;
  st := RatFromInt (1000000000, 1, b) ;
  Must ("base", st, RatOk) ;
  i := 0 ;
  WHILE i < 7 DO
    st := RatMul (a, b, a) ;
    IF st <> RatOk THEN
      WriteInt (i, 0) ;
      WriteLn ;
      Fail ("pow-fit")
    END ;
    INC (i)
  END ;
  IF (RatNumLimbs (a) <> 8) OR (RatNumLimb (a, 7) <> 1) OR (RatNumLimb (a, 0) <> 0) THEN
    Show (a) ;
    Fail ("10^63-shape")
  END ;
  st := RatMul (a, b, c) ;
  Must ("pow-overflow", st, RatOverflow) ;

  (* Large but exact: (10^63) / (10^27) = 10^36. *)
  st := RatFromInt (1, 1, d) ;
  i := 0 ;
  WHILE i < 3 DO
    st := RatMul (d, b, d) ;
    Must ("den-pow", st, RatOk) ;
    INC (i)
  END ;
  st := RatDiv (a, d, e) ;
  Must ("big-div", st, RatOk) ;
  IF (RatNumLimbs (e) <> 5) OR (RatNumLimb (e, 4) <> 1) OR RatNumNeg (e) THEN
    Show (e) ;
    Fail ("10^36")
  END ;

  (* Determinism *)
  st := RatFromInt (1, 2, a) ;
  st := RatFromInt (1, 3, b) ;
  st := RatAdd (a, b, c) ;
  st := RatAdd (a, b, d) ;
  st := RatCmp (c, d, cmp) ;
  IF (st <> RatOk) OR (cmp <> 0) THEN
    Fail ("determinism")
  END ;

  (* Negative penalty style: -1/1 + 2/1 = 1/1 *)
  st := RatFromInt (-1, 1, a) ;
  st := RatFromInt (2, 1, b) ;
  st := RatAdd (a, b, c) ;
  Must ("neg-add", st, RatOk) ;
  ExpectSmall ("-1+2", c, FALSE, 1, 1) ;

  WriteString ("m2rat-ok") ;
  WriteLn ;
  FlushOutErr
END M2RatTest.
