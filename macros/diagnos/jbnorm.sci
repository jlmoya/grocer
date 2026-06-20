function [rjbnorm]=jbnorm(grocer_res,varargin)
 
// PURPOSE : Jarque and Bera normality test
// ------------------------------------------------------------
// references : Jarque, C. M., and Bera, A. K. (1980). '
// Efficient tests for normality, homoscedasticity and serial
// independence of regression residuals', Economics Letters, 6,
// 255–259.
// ------------------------------------------------------------
// INPUT:
// * grocer_res = a result tlist or a variable which can be a
//   vector or a ts between quotes or not
// * varargin = optional arguments that can be:
//   - 'noprint' if the user does not want to print the results
//  - 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUTPUT:
// rjbnorm= a typed list with :
//   . rjbnorm('meth') = 'jbnorm'
//   . rjbnorm('r1st') = results of the first step
//      regression (allows the "traceability" of the results)
//   . rjbnorm('chistat') = the value of the chi2 statistics
//   . rjbnorm('chi_pvalue') = the corresponding p-value
//   . rjbnorm('chi_df') = the corresponding degrees of
//     freedom
//   . rjbnorm('skewness') = the skewness of the residuals
//   . rjbnorm('kurtosis') = the kurtosis of the residuals
//   . rjbnorm('dropna') = a boolean indicating if NAs have
//     been droped(if the first input was a ts)
//   . rjbnorm('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the test
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_dropna,grocer_prt]=vararg2dropnaprt(varargin(:))
 
if typeof(grocer_res) == 'results' then
 
   [jb,pn,s,k]=jbnorm0(grocer_res)
   rjbnorm=tlist(['results';'meth';'r1st';'chistat';'chi_df';'chi_pvalue';'skewness';'kurtosis'],...
   'jbnorm',grocer_res,jb,2,pn,s,k)
 
else
 
   [y,namey,prests,boundsvarb,nonna]=explone(grocer_res,[],'endogenous',%t,grocer_dropna)
   [jb,pn,s,k]=jbnorm_var1(y)
   rjbnorm=tlist(['results';'y';'meth';'chistat';'chi_df';'chi_pvalue';'skewness';'kurtosis';'dropna'],...
   'jbnorm',y,jb,2,pn,s,k,grocer_dropna)
   if grocer_dropna then
      rjbnorm(1)($+1)='nonna'
      rjbnorm('nonna')=nonna
   end
 
 
end
 
if grocer_prt then
   prtchi(rjbnorm)
end
 
endfunction
