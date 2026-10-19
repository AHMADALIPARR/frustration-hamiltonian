# Same hard separation, but agents 0 and 1 are forced onto one cell.
param B := 7;
set A := 0 .. 2;
var x {A} integer >= 0, <= B;
var y {A} integer >= 0, <= B;
var z {A} integer >= 0, <= B;

s.t. f0x: x[0] = 0;
s.t. f0y: y[0] = 0;
s.t. f0z: z[0] = 0;
s.t. f1x: x[1] = 0;
s.t. f1y: y[1] = 0;
s.t. f1z: z[1] = 0;

var d {1..6} binary;
s.t. dxp: x[0] >= x[1] + 1 - (B + 1) * (1 - d[1]);
s.t. dxn: x[1] >= x[0] + 1 - (B + 1) * (1 - d[2]);
s.t. dyp: y[0] >= y[1] + 1 - (B + 1) * (1 - d[3]);
s.t. dyn: y[1] >= y[0] + 1 - (B + 1) * (1 - d[4]);
s.t. dzp: z[0] >= z[1] + 1 - (B + 1) * (1 - d[5]);
s.t. dzn: z[1] >= z[0] + 1 - (B + 1) * (1 - d[6]);
s.t. cover: sum {k in 1..6} d[k] >= 1;

minimize H: y[0] + y[1] + y[2];
solve;
end;
