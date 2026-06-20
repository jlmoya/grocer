function [AR,corrv_ar]=transf_roots(AR)
 
// PURPOSE: reverses roots lower than 1 in a L polynom and
// calculates the correction to apply to the variance of
// residuals
// ------------------------------------------------------------
// INPUT:
// * AR = a (k x 1) vector of coefficients of a polynom
//    1+AR(L)
// ------------------------------------------------------------
// OUTPUT:
// * AR = the (k x 1) vector of transforms coefficients such as
//   all roots of (1+AR(L)) are greater than 1
// * corrv_ar = the coefficient that lust be used to correct
//   the variance of residuals
// ------------------------------------------------------------
// Copyright Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
if isempty(AR) then
   corrv_ar=1
else
   p=poly([1 ; vec2col(AR)],"x","coeff")
   r=roots(p)
   f=find(abs(r)<1)
   r(f) = 1 ./ r(f)
   pn=poly(r,"x")
   ARN=real(coeff(pn))
   ARN=ARN(2:$)/ARN(1)
   AR(AR ~= 0)=ARN(AR ~= 0)
   corrv_ar=1/prod(abs(r(f)))^2
end
 
endfunction
 
