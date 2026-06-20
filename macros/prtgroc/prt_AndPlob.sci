function prt_AndPlob(res,output)
 
// PURPOSE: prints the results of Andrews and Andrews and
// Ploberger stability tests on file output
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
r1= res('res 1')
rall=res('res all')
write(out,' ')
write(out,'*************************************************')
write(out,'Andrews and Andrews and Ploberger stability tests')
write(out,'*************************************************')
write(out,' ')
 
if r1('prests') then
   break_point=r1('bounds')($)
else
   break_point=string(res('break point'))
end
 
write(out,'break point: '+break_point)
write(out,'percentage of the sample: '+string(res('break point')/rall('nobs')*100))
 
mat2prt=[' ' 'Test' 'Andrews' 'Boostrap' 'Hetero-Corrected' ;...
         ' ' 'Statistic' 'p-value' 'p-value' 'p-value' ; ...
         'SupF' string([res('SupF') res('SupF pvalues')']) ;...
         'ExpF' string([res('ExpF') res('ExpF pvalues')']) ;...
         'AveF' string([res('AveF') res('AveF pvalues')']) ]
printmat(mat2prt,out)
 
write(out,' ')
write(out,'****************************************')
write(out,'Estimation results over the first period')
write(out,'****************************************')
write(out,' ')
prtuniv(r1,out)
 
write(out,' ')
write(out,'****************************************')
write(out,'Estimation results over the second period')
write(out,'****************************************')
write(out,' ')
 
prtuniv(res('res 2'),out)
 
endfunction
