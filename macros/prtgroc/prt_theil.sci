function []=prt_theil(res,out)
 
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
if meth ~= 'Theil-Goldberger' then
   error('arg 1 is not a results tlist relevant to prt_ols')
end
 
prt_meth_n_endo(res,out)
prtuniv_block1(res,out)
prtuniv_R2(res,meth,nvar,out)
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,'DW(0) ='+string(res('dw')))
write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')))
write(out,[' '])
mat2print=['Prior Mean' 'Std Deviation';...
           string(res('pmean')) string(res('pstd'))]
printmat(mat2print,out)
write(out,[' '])
 
prtuniv_coeffs(res,out)
 
printsep(out)
 
res_fields=res(1)
if or(res(1) == 'name_test') then
   write(out,' ')
   write(out,'tests results:')
   write(out,'**************')
   m=['test value' 'p-value']
   m= [m ; string(res('spec_test'))]
   m2prt=[res('name_test') m]
   printmat(m2prt,out)
   write(out,' ')
   printsep(out)
end
 
endfunction
