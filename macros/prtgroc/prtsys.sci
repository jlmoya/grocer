function []=prtsys(res,out)
 
// PURPOSE: prints the results of system regression (sur, 2sls,
// 3sls) on the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// sur()
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
neqs=res('neqs')
 
write(out,' ')
write(out,res('meth')+' estimation results')
write(out,' ')
write(out,'correlation matrix of residuals')
write(out,' ')
mat2prt=['eq' string(1:neqs) ;...
         string([1:neqs]') string(res('corr'))]
for i=3:neqs+1
    for j=2:i-1
       mat2prt(i,j)=' '
    end
end
printmat(mat2prt,out)
write(out,' ')
 
prests=res('prests')
 
neqs=res('neqs')
nobs=res('nobs') .* ones(neqs,1)
for i=1:neqs
   write(out,'results for equation # '+string(i)+':')
   write(out,res('eqs')(i))
   write(out,' ')
   if prests then
      chb='estimation period: '
      boundsvar=res('bounds')
      if typeof(boundsvar) == 'list' then
         boundsvar=boundsvar(i)
      end
      for j=1:size(boundsvar,1)/2
         chb=chb+boundsvar(2*j-1)+'-'+boundsvar(2*j)+'  '
      end
      write(out,chb)
   end
   write(out,'number of observations: '+string(nobs(i)))
   write(out,'number of variables: '+string(res('ncoef')(i)))
   write(out,'standard error of the regression: '+string(res('ser')(i)))
   write(out,'sum of squared residuals: '+string(res('sigu')(i)))
   write(out,'DW(0) ='+string(res('dw')(i)))
   write(out,[' '])
   mat2print=['variable' 'coeff' 't-statistic' 'p value']
   for j=1:size(res('coefs')(i),1)
      k=res('coefs')(i)(j)
      mat2print=[mat2print ; res('namecoef')(k) string(res('beta')(k)) ...
                string(res('tstat')(k)) string(res('pvalue')(k))]
   end
   printmat(mat2print,out)
   printsep(out)
end
endfunction
