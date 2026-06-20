function [lresult]=lad_d()
 
// PURPOSE: An example using lad(),
// least-absolute deviations estimation
//---------------------------------------------------
 
 
 
b = ones(5,1);
//
xmat = grand(100,4,'nor',0,1);
//
exo = [ones(100,1),xmat];
evec = rand(100,1,'n').^4;
// create leptokurtic errors
//
endo = exo*b+evec;
//
//
// do ols regression
 
rols = ols('endo','exo');
// do the doornik-hansen normality test to check the
// non-nomrality of residuals
doornhans(rols)
 
// do lad regression
 
lresult = lad('endo','exo');
endfunction
