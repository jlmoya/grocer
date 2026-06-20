function prt_des_stat(r,out)
 
// PURPOSE: prints results from function des_stat
// ------------------------------------------------------------
// INPUT:
// * r= a results tlist from function des_stat
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   out=%io(2)
end
 
mat2print=['series:' r('namey')]
if r('prests') then
   b=r('bounds')
   stringb=string(b(1))+'-'+string(b(2))
   for i=2:size(b,1)/2
      stringb=stringb+' ;'+string(b(2*i-1))+'-'+string(b(2*i))
   end
   mat2print=[mat2print ; 'sample:' stringb ; 'nobs:' string(size(r('y'),1))]
else
   mat2print=[mat2print ; 'nobs:' string(size(r('y'),1))]
end
 
stats=[string([r('mean');r('median');r('miny');r('maxy');r('stdevy');r('skew');r('kurt')]) ; ' ' ; string([r('jbstat');r('jbprob')])]
names=['mean' ; 'median' ; 'minimum' ; 'maximum' ; 'st. dev.';'skweness';'kurtosis'; ' ' ;'Jarque-Bera' ;'p-value']
mat2print=[mat2print ; ' ' ' ' ; names stats]
 
write(out,' ')
printmat(mat2print,out)
write(out,' ')
 
endfunction
 
 
