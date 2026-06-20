function [f]=chis_pdf(x,a)
 
// PURPOSE: returns the pdf at x of the chisquared(n)
// distribution
// ------------------------------------------------------------
// INPUT:
// * x = a (nxm) matrix
// * n = a scalar or a (nxm) matrix
// ------------------------------------------------------------
// OUTPUT:
// a matrix of pdf at each element of x from chisq(n) or
// chisq(same elemnt of n) distribution
// ------------------------------------------------------------
// NOTE: chis_pdf(x,n) = gamm_pdf(x/2,n/2)/2
// ------------------------------------------------------------
// Copyright (c) Anders Holtsberg
// translated to scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin~=2 then
  error('Wrong # of arguments to chis_pdf');
end
 
if or(a<=0) then
  error('chis_pdf: dof is wrong');
end
 
f = gamm_pdf(x/2,a*.5)/2;
endfunction
