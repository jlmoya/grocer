function []=olst_d()
 
// PURPOSE: An example using olst(),
// ols with t-distributed errors estimation
 
 
 
b = ones(5,1);
xmat = rand(100,4,'n');
exo = [ones(100,1),xmat];
 
// generate t-distributed errors
evec = tdis_rnd(100,2)*.5;
endo = exo*b+evec;
 
// do ols regression
result = ols('endo','exo');
 
// do robust t-distributed errors regression
lresult = olst('endo','exo','maxit=1000','crit=.0001');
endfunction
