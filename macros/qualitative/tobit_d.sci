function [r]=tobit_d()
// PURPOSE: An example using tobit()
//                           prt()
//  Tobit (censored) regression
//---------------------------------------------------
// USAGE: tobit_d
//---------------------------------------------------
 
// generate uncensored data
// generate uncensored data
 
 
 
xr = grand(200,5,'nor',0,1);
bet = ones(5,1);
yr = xr*bet+rand(200,1,'n');
// now censor the data
for i = 1:200
  if yr(i,1)<0 then
    yr(i,1) = 0;
  end
end
 
// an example which provide only the results without
// printing them
r = tobit('yr','xr','noprint');
 
// an example with y and x between quotes: the endogenous
// variable is printed as y and the exogenous ones as
// x_1,x_2,x_3,x_4,x_5
// options hess and maxit are also given
// reults are not kept
tobit('yr','xr','hess=dfp','maxit=1000');
 
endfunction
