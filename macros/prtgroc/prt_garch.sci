function []=prt_garch(res,out)
 
// PURPOSE: prints the results of a garch regression on
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
if meth ~= 'garch' then
   error('arg 1 is not a garch results tlist')
end
 
prt_meth_n_endo(res,out)
prtuniv_block1(res,out)
prtuniv_R2(res,meth,nvar,out)
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,'DW(0) ='+string(res('dw')))
write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')))
write(out,'log likelihood: '+string(res('like')))
write(out,[' '])
 
prtuniv_coeffs(res,out)
 
printsep(out)
 
 
endfunction
