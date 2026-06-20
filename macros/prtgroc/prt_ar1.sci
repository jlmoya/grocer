function []=prt_ar1(res,out)
 
// PURPOSE: prints the results of an olsar1 or olsc regression
// on the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list from an olsar1 or olsc
//   regression
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
if and(meth ~= ['Cochrane-Orcutt'  'ar(1) maximum likelihood']) then
   error('arg 1 is not a results tlist relevant to prt_ar1')
end
 
write(out,meth+' estimation results for endogenous: '+res('namey'))
nchars=length(meth+' estimation results for endogenous: '+res('namey'))
stars=strcat(emptystr(1,nchars)+'*')
write(out,stars)
write(out,' ')
 
prtuniv_block1(res,out)
prtuniv_R2(res,meth,nvar,out)
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'DW(0) ='+string(res('dw')))
write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')))
 
prtuniv_coeffs(res,out)
 
printsep(out)
write(out,' ')
mat2print=['rho' string(res('rho')); 't-stat' string(res('trho'))]
printmat(mat2print,%io(2))
write(out,' ')
write(out,'note the all statistics are calculated from the quasi-differentiated model')
write(out,'because they are generally (t-stats, R2, overall F-test in particular) meaningless for the original model')
 
printsep(out)
 
endfunction
 
 
