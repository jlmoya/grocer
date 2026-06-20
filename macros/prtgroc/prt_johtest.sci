function []=prt_johtest(res,typeboot,out)
 
// PURPOSE: prints the results of a test on some parameters of
// a Johansen estimation
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a testing regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
select nargin
 
case 1 then
   typeboot='fast double'
   out=%io(2)
 
case 2 then
   out=%io(2)
 
end
 
write(out,' ')
if res('meth') ~= 'johansen' then
   error('prt_johtest apply only to johansen result tlists')
end
 
write(out,'johansen '+res('test type')+' test')
 
select res('test type')
 
case 'common beta' then
   write(out,' ')
   write(out,'H matrix:')
   mat2prt=string(res('H'))
   printmat(mat2prt,out)
 
case 'known beta' then
   write(out,' ')
   write(out,'known b coefficient:')
   mat2prt=string(res('b'))
   printmat(mat2prt,out)
 
case 'partial restrictions on beta' then
   write(out,' ')
   write(out,'matrix of restrictions:')
   mat2prt=string(res('H1'))
   printmat(mat2prt,out)
 
case 'inclusion in the cointegration relation' then
   write(out,' ')
   if res('nb variables tested') == 1 then
      write(out,'variable tested:')
   else
      write(out,'variables tested:')
   end
   printmat(res('variables tested'),out)
 
case 'long run weak exogeneity' then
   write(out,' ')
   if res('nb variables tested') == 1 then
      write(out,'variable tested:')
   else
      write(out,'variables tested:')
   end
   printmat(res('variables tested'),out)
 
case 'some ec vectors imposed' then
   write(out,' ')
   write(out,'matrix of restricted error correction vectors')
   printmat(string(res('imposed ec vectors')),out)
 
end
 
write(out,' ')
if typeboot == 'fast double' then
   pvalue=res('fast double bootstrap test pvalue')
else
   pvalue=res('bootstrap test pvalue')
end
mat2prt=['statistic value' 'p-value' ; string([res('test stat') pvalue])]
printmat(mat2prt,out)
 
write(out,' ')
write(out,'NOTE: p-value results from the '+typeboot+' bootstrap method with '+string(res('test nb of draws'))+' draws')
 
endfunction
