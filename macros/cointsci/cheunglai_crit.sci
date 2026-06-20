function [crit]=cheunglai_crit(nobs,p,l)
 
// PURPOSE: return critical values for the Zt statistic used
// in adf() as tabulated by Cheung and Lai
// ------------------------------------------------------------
// REFERENCES: Cheung and Lai (1995), "Lag order and critical
// values of the Augmented Dickey-Fuller test",
// Journal of Business & Economic Statistics, Vol 13, n°3.
// ------------------------------------------------------------
// INPUT:
// * nobs = # of observations
// * p = order of time polynomial in the null-hypothesis
//   . p = -1, no deterministic part
//   . p =  0, for constant term
//   . p =  1, for constant plus time-trend
// * l = number of lags
// ------------------------------------------------------------
// OUTPUT:
// crit = a (3 x 1) vector of critical values:
//                 [10% 5% 1%] quintiles
// ------------------------------------------------------------
// Copyright  Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
tab=[
-1.609 -1.931 -2.564 -2.566 -2.857 -3.43 -3.122 -3.406 -3.958
-.285 -1.289 -2.906 -1.319 -2.675 -4.959 -2.850 -4.06 -7.448
-4.09 -5.719 -29.773 -15.086 -23.558 -72.303 -15.813 -40.552 -104.947
.321 .38 .599 .667 .748 .842 .907 1.021 1.327
-.525 -.722 -1.58 -.65 -1.077 -2.09 -.804 -1.501 -3.753
]
 
crit=[1 1/nobs 1/nobs^2 (l/nobs) (l/nobs)^2 ]*tab(:,(p+1)*3+[1:3])
 
endfunction
