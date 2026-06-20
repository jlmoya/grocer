function [M,P] = base10(x);
 
// PURPOSE: mimics gauss function base10: Breaks number into a
// number of the form #.####... and a power of 10
// ------------------------------------------------------------
// INPUT:
// * x = a scalar, number to break down
// ------------------------------------------------------------
// OUTPUT:
// * M = scalar, in the range −10 < M < 10
// * P = scalar, integer power such that: M*10^P = x
// ------------------------------------------------------------
// NOTE: could perhaps be made more accurate
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
P=floor(log10(abs(x)))
M=x/10^P
 
endfunction
 
