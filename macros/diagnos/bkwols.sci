function [condindex]=bkwols(x,warn)
 
// PURPOSE: computes BKW COND index of a x matrix (with variables
// studentized to achieve invariance with respect to their scale)
// ------------------------------------------------------------
// REFERENCES: Belsley, Kuh, Welsch, 1980 Regression
// Diagnostics
// ------------------------------------------------------------
// INPUT:
// x = independent variables matrix (nobs x nvar)
// ------------------------------------------------------------
// OUTPUT:
// condindex = the COND index
// ------------------------------------------------------------
// NOTES:
// * used by ols2(), ols2a(), olsc()
// * see also bkw(),dfbeta(), rdiag(), diagnose()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002/Emmanuel Michaux 2005
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatia-econometrics.com
 
[nargout,nargin]=argn(0)
nc=search_cte(x)
 
x(:,nc)=[]
 
[nobs,nx]=size(x)
 
if nx ~= 0 then
   stx = ones(nobs,1) .*. ((nobs-1)^0.5)*st_dev(x,1)
   // scale x data
   x = x ./ stx
 
   [u,d,v] = svd(x,'e');
   lamda = diag(d(1:nx,1:nx));
   lamda2 = lamda .* lamda;
   v = v .* v;
 
   phi = zeros(nx,nx);
   if or(lamda2 == 0) then
      condindex=%inf
   else
      condindex=round(lamda(1)/lamda($))
   end
   if lamda($) < %eps & nargin == 1 then
      warning('matrix of exogenous variables is extremely ill-conditioned')
      write(%io(2),'it could be useful to check if: ','(a)')
      write(%io(2),'- a variable is not constantly 0 over the estimation period','(a)')
      write(%io(2),'- a variable has not be repeated twice','(a)')
      write(%io(2),' ','(a)')
   end
 
else
   condindex = 1
 
end
 
 
endfunction
