function [rarch]=archz(results,p,np)
 
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
//      regression (allows the "tracability" of the results)
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
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted -very freely !- from:
// Kit Baum
// Dept of Economics
// Boston College
// Chestnut Hill MA 02467 USA
// baum@bc.edu
 
[nargout,nargin]=argn(0)
if nargin == 2 then
   prt=%t
else
   if np == 'noprint' then
      prt=%f
   else
      error('argument 3 in archz should be ''noprint''')
   end
end
 
[f,f_pvalue,r2]=archz0(results,p)
 
df0=results('nobs')-p
chistat = (df0-p)*r2;
 
// when calculating the degrees of freedom, the program takes
// into account the fact that the p first residuals are
// suppressed
pchistat = 1-cdfchi("PQ",chistat,p)
 
rarch=tlist(['results';'meth';'r1st';'chistat';...
'chi_pvalue';'chi_df';'f';'f_pvalue';'dfnum';'dfden'],'archtest',results,chistat,...
pchistat,p,f,f_pvalue,p,df0-p)
 
if prt then
   prtchi(rarch)
   prtfish(rarch)
end
 
// end of function
endfunction
