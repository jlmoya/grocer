function [f,f_pvalue,nvar2,r2]=white0(r,np)
 
// PURPOSE: provides the value of the White test
// and its significance level
// ------------------------------------------------------------
// INPUT:
// * r = results tlist from a first stage estimation
// * np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUPTUT:
// * f = value of the Xi² hetero F test
// * f_pvalue = its p-value
// * nvar2 = # of exogenous variables of the Breusch and Pagan
//           second stage regression
// * r2 = R² of the auxilliary regression
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
nvar=r('nvar')
nobs=r('nobs')
xd=ones(nobs,1)
x=r('x')
for i=1:nvar
   if bkwols([xd x(:,i).^2]) < 1E6 then
      xd=[xd x(:,i).^2]
   end
   for j=1:i-1
      if bkwols([xd x(:,i).*x(:,j)]) < 1E6 then
         xd=[xd x(:,i).*x(:,j)]
      end
   end
end
[f,f_pvalue,nvar2,r2]=bpagan0(r('resid').^2,xd,nvar)
 
 
endfunction
