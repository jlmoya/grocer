function s=%s_a_c(num,str)
 
// PURPOSE: perform matrix multiplication even if matrices are
// not of the same dimension, but are row or column compatible
// ------------------------------------------------------------
// INPUT:
// * num = a real vector
// * str = a string
// ------------------------------------------------------------
// OUTPUT:
// s = x.*y where x and y are row or column compatible
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
 
if and(num == 0) then
// in that case, num must be transformed into an emptystr matrix
   [n1,n2]=size(num)
   s=emptystr(n1,n2)+str
else
   s=string(num)+str
end
 
endfunction
