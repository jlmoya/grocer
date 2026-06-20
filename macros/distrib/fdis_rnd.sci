function [x]=fdis_rnd(n,a,b)
 
// PURPOSE: returns random draws from the F(a,b) distribution
// ------------------------------------------------------------
// INPUT:
// *  n = a scalar for the size of the vector to be generated
// or n(1) = nrows, n(2) = ncols for a matrix to be generated
// * a = scalar dof parameter
// * b = scalar dof parameter
// ------------------------------------------------------------
// OUPTUT:
// x = a vector of random draws from the F(a,b) distribution
// ------------------------------------------------------------
// NOTES:
// * mean should equal (b/a)*((a/2)/(b/2-1))
// * this a simple transposition of grand, but the function has
// been preserved for the sake of ascending compatibility
 
if size(n) == 1 then
   n=[n;1]
end
 
x=grand(n(1),n(2),'f',a,b)
 
endfunction
