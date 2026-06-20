function [y] = countwts(x,v,w)
 
// PURPOSE: mimic Gauss function countwts: counts the numbers of
// elements of a vector that fall into specified ranges,
// weighted by a vector of weights
// ------------------------------------------------------------
// INPUT:
// * x = (N x 1) vector containing the numbers to be counted
// * v = (P x 1) vector containing breakpoints specifying the
//   ranges within which counts are to be made. The vector v
//   MUST be sorted in ascending order
// * w = (N x 1) vector, containing weights
// ------------------------------------------------------------
// OUTPUT:
// * y = (N x K) vector, the counts of the elements of x that
//   fall into the regions, weighted by w:
//   x <= v[1],
//   v[1] < x <= v[2],
//        .
//        .
//        .
//   v[p ? 1] < x <= v[p]
// ------------------------------------------------------------
// NOTES:
// * The first category can be a missing value if you need to
// count missings directly.
// * Also %inf or -%inf are allowed as breakpoints. The missing
// value must be the first breakpoint if it is included as a
// breakpoint and infinities must be in the proper location
// depending on their sign.
// * - %inf must be in the [2,1] element of the breakpoint
// vector if there is a missing value as a category as well,
// else it has to be in the [1,1] element.
// * If +%inf is included, it must be the last element of the
// breakpoint vector.
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
if size(x,2) ~= 1 then
   error('first arg is not a (N x 1) vector')
end
 
if size(v,2) ~= 1 then
   error('2nd arg is not a (N x 1) vector')
end
 
if size(w,2) ~= 1 then
   error('3rd arg is not a (N x 1) vector')
end
 
if ~isreal(v) | ~isreal(x )| ~isreal(w) then
    error('Procedure counts cannot be implemented for complex inputs')
end
 
y = v
if isnan(v(1)) then
    y(1)=size(find(isnan(x)),2)*w(1);
 
elseif v(1) == -%inf
    y(1)=size(find(isinf(x)),2)*w(1);
 
else
    y(1)=size(find(x<v(1)),2)*w(1);
 
end
 
n=size(v,1)
vp=(0*x+1) .*. v'
xp=x .*. ones(1,n)
aux=(xp-vp)
z=sum((aux<=0).*(w .*. ones(1,n)),'r')'
y(2:$)=z(2:$)-z(1:$-1)
 
endfunction
