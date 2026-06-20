function []=prt_cadf(res,out)
 
// PURPOSE: prints the results of a cadf regression on
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
 
write(out,' ')
write(out,'cadf RESULTS ESTIMATION')
write(out,' ')
write(out,'-----------------------------------------------------')
write(out,'RESULTS FROM THE FIRST STAGE COINTEGRATING REGRESSION')
write(out,'-----------------------------------------------------')
write(out,' ')
prtuniv(res('cointrel'))
res('pvalue') = string(res('pvalue'))
res('pvalue')(1) = '(*)'
r1=res('cointrel')
namexc=r1('namex')
namexp=namexc(1)
for i=2:size(namexc,2)
   namexp=namexp+', '+namexc(i)
end
write(out,' ')
write(out,'-----------------------------------------------------------------------------')
write(out,'RESULTS FROM THE cadf SECOND STAGE REGRESSION ON RESIDUALS OF THE FIRST STAGE')
write(out,'-----------------------------------------------------------------------------')
write(out,' ')
 
prt_ols(res,out)
 
endfunction
