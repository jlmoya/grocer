function [f,f_pvalue,r2]=archz0(results,p,np)
 
// PURPOSE: computes a test for ARCH(p)
// ------------------------------------------------------------
// REFERENCES:
// * Engle, Robert (1982),"Autoregressive Conditional
//   Heteroskedasticity with Estimates of  the Variance of
//   United Kingdom Inflation", Econometrica, vol. 50,
//   pp. 987-1007
// * Ljung, G.M. & G.E.P. Box (1978), "On a Measure of Lack
//   of Fit in Time Series Models", Biometrika, vol. 65, no. 2,
//   pp. 297-303
// * McLeod, A.I. & W.K. Li (1983), "Diagnostic Checking ARMA
//   Time Series Models Using Squared-Residual Autocorrelations
//   ", Journal of Time Series Analysis, vol. 4, no. 4,
//   pp. 269-273
// ------------------------------------------------------------
// INPUT:
// * results = results tlist from a first stage estimation
// * p = # of lag of squared residuals in the second stage
//       estimation
// * np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUPTUT:
// rarch= a typed list with :
//   . rarch('meth') = 'arch'
//   . rarch('r1st') = results of the first step
//      regression (allows the "traceability" of the results)
//   . rarch('chistat') = the value of the chi2 statistics
//   . rarch('chi_pvalue') = the corresponding p-value
//   . rarch('chi_df') = the corresponding degrees of freedom
//   . rarch('fstat') = the value of the Fisher statistics
//   . rarch('pfstat') = the corresponding p-value
//   . rarch('dfnum') = degrees of freedom of the numerator
//   . rarch('dfden') = degrees of freedom of the denominator
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// automatic()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2005
// http://grocer.toolbox.free.fr/grocer.html
// adapted -very freely !- from:
// Kit Baum
// Dept of Economics
// Boston College
// Chestnut Hill MA 02467 USA
// baum@bc.edu
 
res2 = results('resid').^2;
nobs=results('nobs')
// intialisation of lx2 to be -a little- more efficient
lx2 = ones(nobs-p,p+1)
// feed lx2 with the lags of the squared residuals
for i=1:p
   lx2(:,i+1)=res2(p-i+1:nobs-i)
end
 
res2=res2(p+1:nobs)
u=res2-lx2*ols0(res2,lx2)
sigu=u'*u
df0=nobs-p
r2=1-sigu/((res2-mean0(res2))'*(res2-mean0(res2)))
 
 
// when calculating the degrees of freedom, the program takes
// into account the fact that the p first residuals are
// suppressed
f=(df0-p)/p*r2/(1-r2)
f_pvalue=1-cdff("PQ",f,p,df0-p)
 
endfunction
