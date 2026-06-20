function [f,f_pvalue,nvar2,r2]=hetero_sq0(r,np)
 
// PURPOSE: provides the value of the Xi² hetero test
// and its significance level
// ------------------------------------------------------------
// INPUT:
// * r = results tlist from a first stage estimation
// * np = unused argument put for compatibility with other
// testing functions
// ------------------------------------------------------------
// OUPTUT:
// * f = value of the Xi² hetero F test
// * f_pvalue = its p-value
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
nvar=r('nvar')
nobs=r('nobs')
u2=r('resid').^2
xd=ones(nobs,1)
x=r('x')
for i=1:nvar
   xd=[xd x(:,i)]
   nx=size(xd,2)
   [u,d,v] = svd(xd,'e');
   lamda = diag(d(1:nx,1:nx));
 
   if (lamda($)/lamda(1))^2 < 1E-6 then
      xd(:,$)=[]
   end
 
   xd=[xd x(:,i).^2]
   nx=size(xd,2)
   [u,d,v] = svd(xd,'e');
   lamda = diag(d(1:nx,1:nx));
 
   if (lamda($)/lamda(1))^2 < 1E-6 then
      xd(:,$)=[]
   end
 
end
nvar2=size(xd,2)
if nobs-nvar-nvar2 > 0 then
   [f,f_pvalue,nvar2,r2]=bpagan0(u2,xd,nvar)
else
   f=0
   f_pvalue=1
end
endfunction
