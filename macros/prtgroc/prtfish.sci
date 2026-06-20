function []=prtfish(res,out)
 
// PURPOSE: prints the results of a Fisher test
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a testing regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// chowtest
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
write(out,' ')
select res('meth')
case 'archtest' then
   write(out,'ARCH test: ')
case 'arlm' then
   write(out,'Lagrange multiplier 1-'+string(res('chi_df'))+...
   ' autocorrelation test:')
case 'bpagan' then
   write(out,'Breusch and Pagan heteroscedasticity test:')
case 'chowtest' then
   write(out,'Chow test for a cut at obs: '+res('cut'))
case 'reset' then
   write(out,' power '+string(res('dfnum')+1)+' non linearity RESET test:')
case 'predfailin' then
   write(out,'Chow predictive failure test for a cut at obs: '+res('cut'))
case 'waldf' then
   write(out,'Fisher test:')
case 'white' then
   write(out,'White heteroscedasticity test:')
end
 
write(out,'F('+string(res('dfnum'))+','+string(res('dfden'))...
+')='+string(res('f')))
write(out,'(p -value                  = '+string(res('f_pvalue'))+')')
write(out,' ')
endfunction
