function []=prt_olsarma(res,out)
 
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
if and(meth ~= ['ols with arma errors']) then
   error('arg 1 is not a results tlist relevant to prt_olsaram')
end
 
write(out,meth+' estimation results for endogenous: '+res('namey'))
nchars=length(meth+' estimation results for endogenous: '+res('namey'))
stars=strcat(emptystr(1,nchars)+'*')
write(out,stars)
write(out,' ')
 
prtuniv_block1(res,out)
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,'DW(0) ='+string(res('dw')))
write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')))
 
prtuniv_coeffs(res,out)
write(out,' ' )
write(out,'------------------------------------')
write(out,'ARMA coefficients for the residuals:')
write(out,' ' )
mat2print=['variable' 'coeff' 't-statistic' 'p value']
if ~isempty(res('AR')) then
   mat2print=[mat2print ; 'AR('+string([1:size(res('AR'),1)]')+')',...
             string([res('AR') res('tAR') res('pvalues AR')])]
end
if ~isempty(res('MA')) then
   mat2print=[mat2print ; 'MA('+string([1:size(res('MA'),1)]')+')',...
             string([res('MA') res('tMA') res('pvalues MA')])]
end
printmat(mat2print,out)
 
printsep(out)
 
endfunction
