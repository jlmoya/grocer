function [rdoornhans]=doornhans(res,np)
 
// PURPOSE : "omnibus" normality test
// ------------------------------------------------------------
// references : J. Doornik and H. Hansen (1994) : "A practical
// test for univariate and multivariate normality", Discussion
// Paper, Nuffield College
// ------------------------------------------------------------
// INPUT:
// * res = a result tlist
// * np= the string 'noprint' if the user doesn't want to
//     print the results of the test
// ------------------------------------------------------------
// OUTPUT:
// rdoornhans= a typed list with :
//   . rdoornhans('meth') = 'doornhans'
//   . rdoornhans('r1st') = results of the first step
//      regression (allows the "tracability" of the results)
//   . rdoornhans('chistat') = the value of the chi2 statistics
//   . rdoornhans('chi_pvalue') = the corresponding p-value
//   . rdoornhans('chi_df') = the corresponding degrees of
//     freedom
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the rdoornhans of the test
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   prt=%t
else
   if np == 'noprint' then
      prt=%f
   else
      error('argument 2 in doornhans should be ''noprint''')
   end
end
 
[dh,pn]=doornhans0(res)
 
rdoornhans=tlist(['results';'meth';'r1st';'chistat';'chi_df';'chi_pvalue'],...
'doornhans',res,dh,2,pn)
 
if prt then
   prtchi(rdoornhans)
end
endfunction
