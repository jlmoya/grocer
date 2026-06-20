function [results]=becm_d()
// PURPOSE: An example of using bvar to estimate a
//           vector autoregressive model,taken from
 
 
 
global GROCERDIR;
 
load(GROCERDIR+'/data/datajpl.dat') // load Le Sage matlab data
 
nlag = 2;  // number of lags in var-model
tight = 0.1;
decay = 1.0;
weight = 0.5; // symmetric weights
// now the example given in Le Sage book (chap 5 p.128-129)
results = becm(nlag,tight,weight,decay,...
'endo=[illinos;indiana;kentucky;michigan;ohio;pennsyvlania;tennesse;westvirginia','exo_st=const');
 
// this is an example of using 1st-order contiguity
// of the states as weights as in LeSage and Pan (1995)
// `Using Spatial Contiguity as Bayesian Prior Information
// in Regional Forecasting Models'' International Regional
// Science Review, Volume 18, no. 1, pp. 33-53, 1995.
 
w = [1.0  1.0  1.0  0.1  0.1  0.1  0.1  0.1
     1.0  1.0  1.0  1.0  1.0  0.1  0.1  0.1
     1.0  1.0  1.0  0.1  1.0  0.1  1.0  1.0
     0.1  1.0  0.1  1.0  1.0  0.1  0.1  0.1
     0.1  1.0  1.0  1.0  1.0  1.0  0.1  1.0
     0.1  0.1  0.1  0.1  1.0  1.0  0.1  1.0
     0.1  0.1  1.0  0.1  0.1  0.1  1.0  0.1
     0.1  0.1  1.0  0.1  1.0  1.0  0.1  1.0];
 
// estimate the model
nlag = 2;  // number of lags in var-model
tight = 0.1;
decay = 0.1;
weight = 0.5; // symmetric weights
 
//results = bvar(y,nlag,tight,w,decay);
endfunction
