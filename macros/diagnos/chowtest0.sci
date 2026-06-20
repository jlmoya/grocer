function [fstat,f_pvalue,dfnum,dfden]=chowtest0(resulols,n1,np)
 
// PURPOSE: provides the classical Chow test without printing
// its results, nor storing them in a tlist (see Chowtest())
// ------------------------------------------------------------
// INPUT:
// * resulols = a results tlist from a first stage estimation
// * n1 = # of observations of the first sub-period
// * np = unused argument put for compatibility with other
//   testing functions
// ------------------------------------------------------------
// OUPTUT:
// * fstat = value of the test statistic
// * f_pvalue = its p-value
// * dfnum = # dof of the numerator
// * dfden = # dof of the denominator
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// chowtest(), automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
x=resulols('x')
y=resulols('y')
ssr0=resulols('sigu')
nobs=resulols('nobs')
nvar=resulols('nvar')
nvar1=nvar
nvar2=nvar
dl0=nobs-nvar
 
x1=x(1:n1,:)
//treats the case of dummies
for i=nvar:-1:1
   if x1(:,i) == zeros(n1,1) then
      x1(:,i)=null()
      nvar1=nvar1-1
   end
end
 
if n1 > nvar1 then
   dl1=n1-nvar1
   y1=y(1:n1)
   resid1=y1-x1*ols0(y1,x1)
   ssr1=resid1'*resid1
else
   dl1=0
   ssr1=0
end
 
x2=x(n1+1:nobs,:)
//treats the case of dummies
for i=nvar:-1:1
   if x2(:,i) == zeros(nobs-nvar,1) then
      x2(:,i)=null()
      nvar2=nvar2-1
   end
end
 
if nobs-nvar2-n1 > 0 then
   dl2=nobs-nvar2-n1
   y2=y(n1+1:nobs,:)
   resid2=y2-x2*ols0(y2,x2)
   ssr2=resid2'*resid2
else
   dl2=0
   ssr2=0
end
 
dfnum=dl0-dl1-dl2
dfden=dl1+dl2
 
fstat=(ssr0/(ssr1+ssr2)-1)*dfden/dfnum
f_pvalue=1-cdff("PQ",fstat,dfnum,dfden)
 
endfunction
