function [fstat,f_pvalue,dfnum,dfden]=predfailin0(res,n1,np)
 
// PURPOSE: Chow "predictive failure" test
// ------------------------------------------------------------
// INPUT:
// * resulols = a results tlist from a first stage estimation
// * n1 = # of observations of the sub-period
// ------------------------------------------------------------
// OUPTUT:
// * fstat = value of the test statistic
// * f_pvalue = its p-value
// * dfnum = # dof of the numerator
// * dfden = # dof of the denominator
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
x=res('x')
y=res('y')
nobs=res('nobs')
nvar=res('nvar')
 
x1=x(1:n1,:)
y1=y(1:n1)
 
//treats the case of dummies
ii=find(sum(abs(x1),'r')==0)
x1(:,ii)=[]
 
resid1=y1-x1*ols0(y1,x1)
ssr1=resid1'*resid1
 
dfnum=nobs-n1
dfden=n1-nvar
 
fstat=(res('sigu')-ssr1)/ssr1*dfden/dfnum
if fstat <=0 then
   f_pvalue=1
else	
   f_pvalue=1-cdff("PQ",fstat,dfnum,dfden)
end
 
endfunction
