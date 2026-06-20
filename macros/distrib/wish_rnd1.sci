function [w]=wish_rnd1(sigma,v)
 
// PURPOSE: generate random wishart matrix
// ------------------------------------------------------------
// INPUT:
// * sigma = a (n x n) symmetric input matrix
// * v = degrees of freedom parameter
// ------------------------------------------------------------
// OUTPUT:
// w = a (n x n) matrix of draws
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
 
[n,k] = size(sigma);
 
y=grand(v,'mn',zeros(n,1),sigma)
w = y*y';
 
endfunction
