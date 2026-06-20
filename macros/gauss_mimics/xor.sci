function bool=xor(x1,x2)
 
// PURPOSE: adapt gauss operatror xor: test if elements of 2
// condition matrices are respectively true or false el. by
// el.
// ------------------------------------------------------------
// INPUT:
// * x1 = a matrix of conditions
// * x2 = a matrix of conditions of the same size
// ------------------------------------------------------------
// OUTPUT:
// * bool = %t if all elements of the 2  condition matrices
// are simultaneously true or false el. by el.
// ------------------------------------------------------------
// NOTE:
// This is not strictly equivalent to gauss function eqv: gauss
// function eqv has the following form:
// x1 eqv x2
// but function gauss2sci transforms such a gauss sentence into
// eqv(x1,x2)
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
if or(x1 .* (1-x1) ~= 0) then
   error('first arg should have only booelan, 0 or 1 elements')
end
 
if or(x2 .* (1-x2) ~= 0) then
   error('first arg should have only booelan, 0 or 1 elements')
end
 
bool=and(x1 == (1-x2))
 
endfunction
