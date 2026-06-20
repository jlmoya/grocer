function [M]=dmult(A,B)
 
// PURPOSE: computes the product of diag(A) and B
// ------------------------------------------------------------
// INPUT:
// * A = a matrix
// * B = a matrix
// ------------------------------------------------------------
// OUTPUT:
//  m = diag(A) times B
// ------------------------------------------------------------
// NOTE: a Gauss compatability function
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted to scilab from
// Gordon K Smyth, U of Queensland, Australia,
// gks@maths.uq.oz.au
 
[mb,nb] = size(B);
M = A*ones(1,nb) .* B;
 
endfunction
 
