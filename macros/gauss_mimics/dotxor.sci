function bool=dotxor(x1,x2)
 
// PURPOSE: adapt gauss operatror .xor: tests if elements of 2
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
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
if or(x1 .* (1-x1) ~= 0) then
   error('first arg should have only booelan, 0 or 1 elements')
end
 
if or(x2 .* (1-x2) ~= 0) then
   error('first arg should have only booelan, 0 or 1 elements')
end
 
bool=(x1 == (1-x2))
 
endfunction
