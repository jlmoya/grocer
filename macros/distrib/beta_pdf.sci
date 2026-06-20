function [pdf]=beta_pdf(x,a,b)
 
// PURPOSE: pdf of the beta(a,b) distribution
// ------------------------------------------------------------
// INPUT:
// * x = vector of components
// * a = beta distribution parameter, a = scalar or vector of
// the same size than x
// * b = beta distribution parameter  b = scalar or vector of
// the same size than x
//--------------------------------------------------------------
// OUTPUT: pdf at each element of x of the beta(a,b)
// distribution
// ------------------------------------------------------------
// NOTE: mean[(beta(a,b)] = a/(a+b),
// variance = ab/((a+b)*(a+b)*(a+b+1))
//--------------------------------------------------------------
// Copyright: by Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin~=3 then
  error('Wrong # of arguments to beta_pdf');
end
 
if or(or(a<=0|b<=0)) then
  error('Parameter a or b is nonpositive');
end
 
pdf = (x.^(a-1) .* ((1-x).^(b-1)) ./ beta(a,b)).*(x>=0|x<=1)
 
endfunction
