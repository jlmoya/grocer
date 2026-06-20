function [rres]=ridge_d()
// PURPOSE: An example using ridge(), bkw()
//                           prt_reg(),
//                           rtrace(),
// ridge regression, collinearity diagnostics
// and ridge trace
//---------------------------------------------------
// USAGE: ridge_d
//---------------------------------------------------
//
//

bounds()
// generate collinear data set
n = 100;
k = 3;
exo = rand(n,k,'n');
exo(:,1) = ones(n,1);
exo(:,3) = exo(:,2)+rand(n,1,'n')*.05;
 
bet = ones(k,1);
 
endo = exo*bet+rand(n,1,'n');
 
bkw(exo);
 
res = ols('endo','exo');
 
rres = ridge('endo','exo');
 
nvar = rres('nvar');
theta0 = rres('theta');
//
//rtrace(y,x,2*theta0,50,vnames);
endfunction
