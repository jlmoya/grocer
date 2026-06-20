function []=prt_panel(res,out)
 
// PURPOSE: prints the results of an ols, white, lad,
// Newey-West''s HAC', 'olst', 'ridge' regression on
// the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list from an olsmod regression
// * out = the symbolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
meth=res('meth')
nvar=res('nvar')
 
write(out,' ')
if and(meth ~= ['panel pooled'; 'panel with fixed effects';'between']) then
   error('arg 1 is not a pooled, fixed effect or between results panel')
end
 
[panhac,panmbb]=prt_meth_panel(res,out)
 
write(out,'number of observations: '+string(res('nobs')))
write(out,'number of variables: '+string(nvar))
 
if panmbb then
   write(out,'R2 = '+string(res('rsqr'))+'  adjusted R2 ='+string(res('rbar')))
   write(out,' ')
else
   prtuniv_R2(res,meth,nvar,out)
end
 
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')))
 
if panmbb then
   write(out,' ')
   namex=res('namex')
   bet=res('beta')
   ci=res('ci')
   nci=size(ci,1)
   mat2print=['variable' 'coeff' 'symetric lower-bound' 'symetric upper-bound']
   for i=1:nci
      mat2print=[mat2print ; namex(i) string(bet(i)) string(ci(i,1:2)) ]
   end
   for i=(nci+1):nvar
      mat2print=[mat2print ; namex(i) , string(bet(i)) , 'NA' , 'NA']
   end
   printmat(mat2print,out)
else
   prtuniv_coeffs(res,out)
end
 
printsep(out)
 
endfunction
