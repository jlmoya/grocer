function []=prt_iv(res,out)
 
// PURPOSE: prints the results of an iv, twosls, threesls
// regression on the file out
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
if and(meth ~= ['iv' 'twosls' 'threesls']) then
   error('arg 1 is not a results tlist relevant to prt_ols')
end
 
write(out,meth+' estimation results for endogenous: '+res('namey'))
nchars=length(meth+' estimation results for endogenous: '+res('namey'))
stars=strcat(emptystr(1,nchars)+'*')
write(out,stars)
write(out,' ')
 
prtiv_endninst(res,out)
prtuniv_block1(res,out)
prtuniv_R2(res,meth,nvar,out)
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'DW(0) ='+string(res('dw')))
write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')))
 
prtuniv_coeffs(res,out)
 
printsep(out)
 
endfunction
