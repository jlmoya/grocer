function []=prtcdtest(res,out)
 
// PURPOSE: Print the results of cross-sectional dependence tests
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a testing regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
//  nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux (2012)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
write(out,' ')
write(out,'Test of cross-sectional dependence:')
write(out,res('meth')+' statistic = '+string(res('stat')))
write(out,'(p-value = '+string(res('pvalue'))+')')
write(out,' ')
endfunction
