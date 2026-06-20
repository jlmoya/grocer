function vecout=indexcat(vecin,val)
 
// PURPOSE: mimic gauss function indexcat: Rreturns the indices
// of the elements of a vector which fall into a specified
// category
// ------------------------------------------------------------
// INPUT:
// * vecin = a (N x 1) vector
// * val = a scalar or (2 x 1) vector.
//   If scalar, the function returns the indices of all elements
//   of x equal to v.
//   If (2 x 1), then the function returns the indices of all
//   elements of x that fall into the range:
//   v[1] < x <= v[2]
//   If v is scalar, it can contain a single missing to specify
//   the missing value as the category.
// ------------------------------------------------------------
// OUTPUT:
// * vecout = a (L x 1) vector, containing the indices of the
//   elements of x which fall into the category defined by v.
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
if size(vecin,2) ~= 1 then
   error('input # 1 should be a column vector')
end
 
select size(val,'*')
 
case 1 then
   vecout=find(vecin == val)
 
case 2 then
   vecout=find(vecin > val(1) & vecin <= val(2))
 
else
   error('size of input to 2 ('+string(size(val,'*'))+') is too big')
end
vecout=vecout'
 
endfunction
 
