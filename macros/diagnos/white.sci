function [resulwhite]=white(resulols,np)
 
// PURPOSE: White heteroskedasticity test
// ------------------------------------------------------------
// REFERENCES: White, H. (1980) "A heteroskedastic-consistent
// covariance matrix estimator and a direct test for
// heteroskedasticity", Econometrica, 48, 817–838.
// ------------------------------------------------------------
// INPUT:
// * resulols = results tlist from a first stage estimation
// returns a tlist
// * np = 'noprint' if the user does not want to display the
// results (optional argument!)
// ------------------------------------------------------------
// OUPTUT:
// resulwhite = a results tlist with:
// - resulwhite('meth')   = 'white'
// - resultwhite('resul1st') = results tlist of the first stage
//   regression
// - resulwhite('f') = Breush-Pagan LM-statistic (Fisher form)
// - resulwhite('p') = p-value of the test
// - resulwhite('dfnum') = degrees of freedom of the numerator
// - resulwhite('dfden') = degrees of freedom of the denominator
// - resulwhite('f_pvalue') = p-value of the test
// - resulwhite('chistat') = p-value of the test
// - resulwhite('f_chistat') = p-value of the test
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   prt=%t
else
   if np == 'noprint' then
      prt=%f
   else
      error('argument 2 in archz should be ''noprint''')
   end
end
 
[f,f_pvalue,nvar2,r2]=white0(resulols)
 
nobs=resulols('nobs')
chistat=nobs*r2
pchi=1-cdfchi("PQ",chistat,nvar2-1)
dfn=nvar2-1
dfd=nobs-resulols('nvar')-nvar2
 
resulwhite=tlist(['results';'meth';'resul1st';'f';...
'dfnum';'dfden';'f_pvalue';'chistat';'chi_pvalue';'chi_df'],...
'white','resulols',f,dfn,dfd,f_pvalue,chistat,pchi,nvar2-1)
 
if prt then
   prtchi(resulwhite)
   prtfish(resulwhite)
end
endfunction
