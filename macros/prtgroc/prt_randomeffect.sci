function []=prt_randomeffect(res,out)
 
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
if meth ~= 'panel with random effects' then
   error('arg 1 is not a panel random effect results')
end
 
prt_meth_panel(res,out)
 
write(out,'number of observations: '+string(res('nobs')))
write(out,'number of variables: '+string(nvar))
 
prtuniv_R2(res,meth,nvar,out)
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')))
 
prtuniv_coeffs(res,out)
write(out,' ')
write(out,'**************')
write(out,'random effects')
write(out,' ')
m2prt=['individual' 'estimated effect' ; res('namex')(nvar+1:$) string(res('random effects'))]
printmat(m2prt,out)
 
printsep(out)
 
 
endfunction
