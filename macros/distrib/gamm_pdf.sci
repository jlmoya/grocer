function [f]=gamm_pdf(x,a)
 
// PURPOSE: returns the pdf at x of the gamma(a) distribution
// ------------------------------------------------------------
// INPUT:
// * x = variable matrix (nxm)
// * a = a scalar or a (mxn) variable matrix
// ------------------------------------------------------------
// OUTPUT:
// a vector of pdf at each element of x of the gamma(a) or of
// the gamma(corresponding element in a) distribution
// ------------------------------------------------------------
// Copyright (c) Anders Holtsberg/Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin~=2 then
  error('Wrong # of arguments to gamm_cdf');
end
 
if or(a<=0) then
  error('gamm_pdf: parameter a is wrong');
end
 
f = x.^(a-1) .* exp(-x) ./ gamma(a);
f = 0*f.*(x<0)+f.*(x>=0)
endfunction
