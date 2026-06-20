function []=prt_quali(res,out)
 
// PURPOSE: prints the results of a probit, logit, ordered
// logit or pobit
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
if and(meth ~= ['logit' ; 'probit'; 'ordered logit'; 'ordered probit'])  then
   error('arg 1 is not a results tlist relevant to prt_quali')
end
 
prt_meth_n_endo(res,out)
prtuniv_block1(res,out)
prtquali_R2(res,out)
write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')))
 
prtuniv_coeffs(res,out)
 
printsep(out)
 
 
endfunction
