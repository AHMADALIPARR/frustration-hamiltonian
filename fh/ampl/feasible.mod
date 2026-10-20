# Copyright (C) 2026 AHMAD ALI PARR
# SPDX-License-Identifier: AGPL-3.0-or-later

# Hard box + pairwise separation. Soft objective is height potential.
# Pairwise contact is enforced as an exact indicator and priced at 1.
param B := 7;
set A := 0 .. 2;

var x {A} integer >= 0, <= B;
var y {A} integer >= 0, <= B;
var z {A} integer >= 0, <= B;

# Pair 0-1
var p01 binary;
var ax01 integer >= 0, <= B;
var ay01 integer >= 0, <= B;
var az01 integer >= 0, <= B;
var manh01 integer >= 0, <= 3 * B;
var c01 binary;
var below01 binary;
var above01 binary;
s.t. ax01a: ax01 >= x[0] - x[1];
s.t. ax01b: ax01 >= x[1] - x[0];
s.t. ax01c: ax01 <= x[0] - x[1] + (2 * B) * (1 - p01);
s.t. ax01d: ax01 <= x[1] - x[0] + (2 * B) * p01;
var q01 binary;
s.t. ay01a: ay01 >= y[0] - y[1];
s.t. ay01b: ay01 >= y[1] - y[0];
s.t. ay01c: ay01 <= y[0] - y[1] + (2 * B) * (1 - q01);
s.t. ay01d: ay01 <= y[1] - y[0] + (2 * B) * q01;
var r01 binary;
s.t. az01a: az01 >= z[0] - z[1];
s.t. az01b: az01 >= z[1] - z[0];
s.t. az01c: az01 <= z[0] - z[1] + (2 * B) * (1 - r01);
s.t. az01d: az01 <= z[1] - z[0] + (2 * B) * r01;
s.t. manh01e: manh01 = ax01 + ay01 + az01;
s.t. c01a: manh01 <= 1 + (3 * B) * (1 - c01);
s.t. c01b: manh01 >= 1 - (3 * B) * (1 - c01);
s.t. bel01: manh01 <= 0 + (3 * B) * (1 - below01);
s.t. abv01: manh01 >= 2 - (3 * B) * (1 - above01);
s.t. part01: c01 + below01 + above01 = 1;

# Pair 0-2
var p02 binary;
var ax02 integer >= 0, <= B;
var ay02 integer >= 0, <= B;
var az02 integer >= 0, <= B;
var manh02 integer >= 0, <= 3 * B;
var c02 binary;
var below02 binary;
var above02 binary;
s.t. ax02a: ax02 >= x[0] - x[2];
s.t. ax02b: ax02 >= x[2] - x[0];
s.t. ax02c: ax02 <= x[0] - x[2] + (2 * B) * (1 - p02);
s.t. ax02d: ax02 <= x[2] - x[0] + (2 * B) * p02;
var q02 binary;
s.t. ay02a: ay02 >= y[0] - y[2];
s.t. ay02b: ay02 >= y[2] - y[0];
s.t. ay02c: ay02 <= y[0] - y[2] + (2 * B) * (1 - q02);
s.t. ay02d: ay02 <= y[2] - y[0] + (2 * B) * q02;
var r02 binary;
s.t. az02a: az02 >= z[0] - z[2];
s.t. az02b: az02 >= z[2] - z[0];
s.t. az02c: az02 <= z[0] - z[2] + (2 * B) * (1 - r02);
s.t. az02d: az02 <= z[2] - z[0] + (2 * B) * r02;
s.t. manh02e: manh02 = ax02 + ay02 + az02;
s.t. c02a: manh02 <= 1 + (3 * B) * (1 - c02);
s.t. c02b: manh02 >= 1 - (3 * B) * (1 - c02);
s.t. bel02: manh02 <= 0 + (3 * B) * (1 - below02);
s.t. abv02: manh02 >= 2 - (3 * B) * (1 - above02);
s.t. part02: c02 + below02 + above02 = 1;

# Pair 1-2
var p12 binary;
var ax12 integer >= 0, <= B;
var ay12 integer >= 0, <= B;
var az12 integer >= 0, <= B;
var manh12 integer >= 0, <= 3 * B;
var c12 binary;
var below12 binary;
var above12 binary;
s.t. ax12a: ax12 >= x[1] - x[2];
s.t. ax12b: ax12 >= x[2] - x[1];
s.t. ax12c: ax12 <= x[1] - x[2] + (2 * B) * (1 - p12);
s.t. ax12d: ax12 <= x[2] - x[1] + (2 * B) * p12;
var q12 binary;
s.t. ay12a: ay12 >= y[1] - y[2];
s.t. ay12b: ay12 >= y[2] - y[1];
s.t. ay12c: ay12 <= y[1] - y[2] + (2 * B) * (1 - q12);
s.t. ay12d: ay12 <= y[2] - y[1] + (2 * B) * q12;
var r12 binary;
s.t. az12a: az12 >= z[1] - z[2];
s.t. az12b: az12 >= z[2] - z[1];
s.t. az12c: az12 <= z[1] - z[2] + (2 * B) * (1 - r12);
s.t. az12d: az12 <= z[2] - z[1] + (2 * B) * r12;
s.t. manh12e: manh12 = ax12 + ay12 + az12;
s.t. c12a: manh12 <= 1 + (3 * B) * (1 - c12);
s.t. c12b: manh12 >= 1 - (3 * B) * (1 - c12);
s.t. bel12: manh12 <= 0 + (3 * B) * (1 - below12);
s.t. abv12: manh12 >= 2 - (3 * B) * (1 - above12);
s.t. part12: c12 + below12 + above12 = 1;

# Same cell (Manhattan 0) is forbidden. Contact (Manhattan 1) is allowed and priced.
s.t. sep01: c01 + above01 >= 1;
s.t. sep02: c02 + above02 >= 1;
s.t. sep12: c12 + above12 >= 1;

minimize H: y[0] + y[1] + y[2] + c01 + c02 + c12;

solve;
display H;
end;
