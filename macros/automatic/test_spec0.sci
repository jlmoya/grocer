function [v,p]=test_spec0(r)
 
// PURPOSE: provide the vectors of 5 statistics of
// specification tests (2 Chow tests, the Doornik and Hansen
// normality test, the Breusch-Pagan autocorrelation test,
// the heteroscedasticity test) and their p-values
// ------------------------------------------------------------
// INPUT:
// * r = a results tlist from a regression
// ------------------------------------------------------------
// OUTPUT:
// * v = (5x1) vector of statistics of specification tests
// * p = (5x1) vector of p-values of specification tests
// ------------------------------------------------------------
// NOTES:
// used by automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
p=ones(5,1)
v=ones(5,1)
[f,pf]=predfailin0(r,round(0.5*r('nobs')))
v(1)=f
p(1)=pf
[f,pf]=predfailin0(r,round(0.9*r('nobs')))
v(2)=f
p(2)=pf
[dh,pdh]=doornhans0(r)
v(3)=dh
p(3)=pdh
[fstat,f_pvalue]=arlm0(r,4)
v(4)=fstat
p(4)=f_pvalue
[f,psq]=hetero_sq0_a(r)
v(5)=f
p(5)=psq
 
endfunction
