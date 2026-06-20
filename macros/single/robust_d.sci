function [bsave]=robust_d()
// PURPOSE: An example using robust(),
//                           prt_reg(),
//                           plt_reg(),
// Iteratively re-weighted least-squares robust regression
//---------------------------------------------------
// USAGE: robust_d
//---------------------------------------------------
 
// generate data with 2 outliers
 
 
 
exo = rand(100,3,'n');
 
exo(:,1) = ones(100,1);
bet = ones(3,1);
evec = rand(100,1,'n');
 
endo = exo*bet + evec;
 
// put in 2 outliers
endo(75,1) = 10.0;
endo(90,1) = -10.0;
 
// get weighting parameter from OLS
// (of course you're free to do differently)
reso = ols('endo','exo');
sige = reso('sige');
 
// set up storage for bhat results
bsave = zeros(3,6);
bsave(:,1) = ones(3,1);
 
// loop over all methods producing estimates
 
wparm = 2*sqrt(sige); // set weight to 2 sigma
 
wfunc = 'huber'
res = robust(wfunc,wparm,'endo','exo');
bsave(:,2) = res('beta');
wfunc = 'ramsay'
res = robust(wfunc,wparm,'endo','exo');
bsave(:,3) = res('beta');
wfunc = 'andrew'
res = robust(wfunc,wparm,'endo','exo');
bsave(:,4) = res('beta');
wfunc = 'tukey'
res = robust(wfunc,wparm,'endo','exo');
bsave(:,5) = res('beta');
 
bsave(:,6) = reso('beta')
 
mat2print=['true beta' 'Huber  t' 'Ramsay' 'Andrews' 'Tukey' 'OLS';...
             string(bsave)]

printmat(mat2print,%io(2))

endfunction
