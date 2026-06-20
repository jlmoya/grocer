function []=prt_nls(res,out)
 
// PURPOSE: prints the results of an olsmod regression on
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
if meth ~= 'nls' then
   error('arg 1 is not a results tlist relevant to prt_nls')
end
 
write(out,meth+' estimation results for equation:')
write(out,res('namey'))
nchars=max(length(meth+' estimation results for equation:'),length(res('namey')))
stars=strcat(emptystr(1,nchars)+'*')
write(out,stars)
write(out,' ')
 
prtuniv_block1(res,out)
prtuniv_R2(res,meth,nvar,out)
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'DW(0) ='+string(res('dw')))
 
prtuniv_coeffs(res,out)
 
printsep(out)
 
endfunction
