function []=prt_multilogit(res,out)
 
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
if meth ~= 'multilogit'  then
   error('arg 1 is not a ''multilogit'' results tlist')
end
 
prt_meth_n_endo(res,out)
prtuniv_block1(res,out)
prtquali_R2(res,out)
write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')))
 
ncat=res('ncat')
bet=res('beta')
tstat=res('tstat')
pvalue=res('pvalue')
mat2print=['variable' 'coeff' 't-statistic' 'p value' ; ' ' ' ' ' ' ' ']
for j=1:ncat
   mat2print=[mat2print ; 'category # '+string(j) , ' ' , ' ' , ' '...
         ; '------------' , ' ' , ' ' , ' ' ...
         ; res('namex') , string([bet(:,j) , tstat(:,j) , pvalue(:,j)])...
         ; ' ' , ' ' , ' ' , ' ']
end
printmat(mat2print,out)
 
printsep(out)
 
 
endfunction
