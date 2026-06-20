function [v,p]=test_varspec0(r)
 
// PURPOSE: provide the vectors of 3 statistics of
// specification tests (the Doornik and Hansen
// normality test, the Breusch-Pagan autocorrelation test,
// the heteroscedasticity test) and their p-values
// ------------------------------------------------------------
// INPUT:
// * r = a results tlist from a regression
// ------------------------------------------------------------
// OUTPUT:
// * v = (3 x 1) vector of statistics of specification tests
// * p = (3 x 1) vector of p-values of specification tests
// ------------------------------------------------------------
// NOTES:
// used by automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
 
 
p=ones(3,1)
v=ones(3,1)
[dh,pdh]=doornhans0(r)
v(1)=dh
p(1)=pdh
[f,pf]=arlm0_multi(r,1:4)
v(2)=f
p(2)=pf
[f,pf]=hetero_sq0_multi(r)
v(3)=f
p(3)=pf
 
endfunction
