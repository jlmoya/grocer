function [rnd]=unif_rnd(n,a,b)
 
// PURPOSE: returns a uniform random number between a,b
// ------------------------------------------------------------
// INPUT:
// * a = scalar left limit
// * b = scalar right limit
// *  n = a scalar for the size of the vector to be generated
// or n(1) = nrows, n(2) = ncols for a matrix to be generated
// ------------------------------------------------------------
// OUTPUT:
// rnd = (nx1) draws from the normal distribution
// ------------------------------------------------------------
// NOTE:
// * mean = (a+b)/2, variance = (b-a)^2/12
// * this a simple transposition of grand, but the function has
// been preserved for the sake of ascending compatibility
 
if size(n) == 1 then
   n=[n;1]
end
 
rnd = grand(n(1),n(2),'unf',a,b);
 
endfunction
