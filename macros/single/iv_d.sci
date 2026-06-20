function [result1,result2]=iv_d()
// PURPOSE: An example using iv(),
// Two-stage Least-squares
//
//---------------------------------------------------
// USAGE: tsls_d
//---------------------------------------------------
//
 
 
nobs = 200;
//
x1 = rand(nobs,1,'n');
x2 = rand(nobs,1,'n');
b1 = 1;
b2 = 1;
iota = ones(nobs,1);
//
y1 = zeros(nobs,1);
y2 = zeros(nobs,1);
evec = rand(nobs,1,'n');
//
// create simultaneously determined variables y1,y2
y1 = iota+x1+evec;
y2 = iota+y1+x2+evec;
 
// do ols regression
 
result1 = ols(y2,[y1,iota,x2]);
 
//
// do iv regression
result2 = iv('y2','endo=y1','exo=iota;x2','ivar=iota;x1;x2');
 
endfunction
