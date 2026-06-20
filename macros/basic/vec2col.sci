function [v]=vec2col(v)
 
// PURPOSE: transform a vector in its column form
// ------------------------------------------------------------
// INPUT:
// v = (n x 1) or (1 x n) vector
// ------------------------------------------------------------
// OUTPUT:
// v = v if v is a column vector
//   = v' if v is a row vector
// ------------------------------------------------------------
 
if size(v,1) == 1 then
   v=v'
end
 
endfunction
 
