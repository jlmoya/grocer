function prt_deming(res,out)
 
 
// PURPOSE: prints the results of a deming regression on
// the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list from a deming regression
// * out = the symbolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin < 2 then
   out=%io(2)
end
 
meth=res('meth')
bhat=string(res('bhat'))
tstat=string(res('tstat'))
conf=string(res(13))
 
write(out,' ')
prt_meth_n_endo(res,out)
write(out,'with ratio of variance errors (y on x): '+string(res('errors variance ratio')))
write(out,' ')
mat2print=['variable' 'coeff' 't-statistic' res(1)(13);...
           'const' , bhat(1) , tstat(1) , '['+conf(1,1)+','+conf(1,2)+']';...
           res('namex') , bhat(2) , tstat(2),  '['+conf(2,1)+','+conf(2,2)+']']
 
printmat(mat2print,out)
 
endfunction
