function [resulres]=reset(resul1,power,np)
 
// PURPOSE: Ramsay (1969) linearity test
// ------------------------------------------------------------
// REFERENCES: Ramsay (1969) :"Tests for specification errors
// in classical linear least-squares regression analysis",
// Journal of the Royal Statistical Society, Series B, n°2,
// 350-371
// ------------------------------------------------------------
// INPUT:
// * resul1 = results tlist from a first stage estimation
// * power = degree of non linearity
// * np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUPTUT:
// resulres = results tlist with:
//  . resulres('meth') = 'reset'
//  . resulres('resul1st') = resul1
//  . resulres('f') = fstat
//  . resulres('p') = p
//  . resulres('df') = df
//  . resulres('f_pvalue')=f_pvalue
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2004
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 2 then
   prt=%t
else
   if np == 'noprint' then
      prt=%f
   else
      error('argument 3 in reset should be ''noprint''')
   end
end
 
[fstat,f_pvalue]=reset0(resul1,power)
 
df=resul1('nobs')-resul1('nvar')-power+1
 
resulres=tlist(['results';'meth';'r1st';'f';'f_pvalue';'dfnum';'dfden']...
,'reset',resul1,fstat,f_pvalue,power-1,df)
 
if prt then
   prtfish(resulres)
end
 
endfunction
