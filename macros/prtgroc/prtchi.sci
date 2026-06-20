function []=prtchi(res,out)
 
// PURPOSE: prints the results of a Chi2 test
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
   write(out,'ARCH test:')
case 'doornhans' then
   write(%io(2),'Doornik and Hansen normality test:')
case 'jbnorm' then
   write(%io(2),'Jarque and Bera normality test:')
case 'predfail' then
   write(%io(2),'predictive failure test:')
case 'white' then
   write(out,'White heteroscedasticity test:')
case 'arlm' then
   write(out,'Lagrange multiplier 1-'+string(res('chi_df'))+' autocorrelation test:')
case 'waldchi' then
   write(out,'Wald Chi-squared test of linear restrictions: ')
   write(out,'  with constraints of the type: Rb=r')
   write(out,' ')
   write(out,'  R =')
   printmat(string(res('R')),out)
   write(out,' ')
   write(out,'  r =')
   printmat(string(res('r')),out)
   write(out,' ')
end
 
write(out,'Chi-squared('+string(res('chi_df'))+')='+string(res('chistat')))
write(out,'(p -value                  = '+string(res('chi_pvalue'))+')')
write(out,' ')
endfunction
