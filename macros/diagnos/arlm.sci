function [resular]=arlm(resul1,p,np)
 
// PURPOSE: Lagrange multiplier autocorrelation test
// ------------------------------------------------------------
// REFERENCES:
// ------------------------------------------------------------
// INPUT:
// * resul1 = results tlist from a first stage estimation
// * p = # of lag of residuals in the second stage estimation
// * np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUPTUT:
// resular = results tlist with:
//  . resular('meth') = 'archtest'
//  . resular('resul1st') = resul1
//  . resular('f') = fstat
//  . resular('p') = p
//  . resular('df') = df
//  . resular('f_pvalue')=f_pvalue
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 2 then
   prt=%t
else
   if np == 'noprint' then
      prt=%f
   else
      error('argument 3 in aragan should be ''noprint''')
   end
end
 
[fstat,f_pvalue,r2]=arlm0(resul1,p)
 
df=resul1('nobs')-resul1('nvar')-p
chistat=df*r2
chi2_pvalue=1-cdfchi("PQ",chistat,p)
 
resular=tlist(['results';'meth';'r1st';'chistat';...
'chi_pvalue';'chi_df';'f';'f_pvalue';'dfnum';'dfden']...
,'arlm',resul1,chistat,chi2_pvalue,p,fstat,f_pvalue,p,df)
 
if prt then
   prtchi(resular)
   prtfish(resular)
end
 
endfunction
