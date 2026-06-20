function [v]=vec2row(v)
 
// PURPOSE: transform a vector in its row form
// ------------------------------------------------------------
// INPUT:
// v = (n x 1) or (1 x n) vector
// ------------------------------------------------------------
// OUTPUT:
// v = v if v is a column vector
//   = v' if v is a row vector
// ------------------------------------------------------------
 
if size(v,2) == 1 then
   v=v'
end
 
endfunction
 
