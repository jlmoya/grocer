function [pdf]=fdis_pdf(x,a,b)
 
// PURPOSE: returns pdf at x of the F(a,b) distribution
// ------------------------------------------------------------
// INPUT:
// * x = a vector
// * a = numerator dof
// * b = denominator dof
// ------------------------------------------------------------
// OUTPUT:
// * a vector of pdf at each element of x of the F(a,b)
// distribution
// ------------------------------------------------------------
//       Copyright (c) Anders Holtsberg
// translated to scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin~=3 then
  error('Wrong # of arguments to fdis_pdf');
end
 
c = b ./ a;
xx = x ./ (x+c);
 
pdf = beta_pdf(xx,a/2,b/2);
pdf = pdf ./ ((x+c).^2)*c;
 
endfunction
