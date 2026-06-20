function []=prtdisag(res,out)
 
// PURPOSE: prints the results of least-squares regression on
// the file out
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
// ols(), olsc(), ridge(), automatic()
// ------------------------------------------------------------
// Copyright: E. Michaux 2005
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
meth=res('meth')
namex=res('namex')
namex = ['cte' ; namex] // add constant name
 
// determine type of disagregation
if res('ta') == -1 then
  ta = 'sum'
elseif res('ta') == 0 then
  ta = 'average'
else
  ta = string(res('ta'))+' interpolation'
end
 
// determine frequency conversation
if res('s') == 4 then
  s = 'annual to quarterly'
elseif res('s') == 12 then
  s = 'annual to monthly'
elseif res('s') == 3 then
  s = 'quarterly to monthly'
end
 
write(out,' ')
write(out,meth+' estimation results for dependent variable: '+res('namey'))
if res('prests') then
   ch='interpolation period: '
   boundsvar=res('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
   write(out,ch)
end
write(out,'number of low-frequency observations: '+string(res('nobs_lf')))
if exists('s','local') then
   write(out,'frequency conversion: '+s)
end
write(out,'number of high-frequency observation: '+string(res('nobs_hf')))
write(out,'number of extrapolations: '+string(res('pred')))
write(out,'number of indicators (incl. constant): '+string(res('p')))
write(out,'type of disaggregation: '+ta)
if res('meth') == 'Chow-Lin' | res('meth') == 'Litterman'
  write(out,'estimation method: '+res('typemin'))
else
  write(out,'estimation method: ols')
end
write(out,'log-likelihood = '+string(res('llike')))
write(out,'AIC = '+string(res('aic'))+'      BIC = '+string(res('bic')))
 
if res('meth') == 'Chow-Lin' | res('meth') == 'Litterman' then
  write(out,'innovationnal parameter (rho): '+string(res('rho')))
end
 
write(out,[' '])
mat2print=['variable' 'coeff' 't-statistic' 'p-value']
for i=1:res('p')
   mat2print=[mat2print ; namex(i) ...
   string(res('beta')(i)) string(res('tstat')(i)) ...
   string(res('pvalue')(i))]
end
printmat(mat2print,out)
 
printsep(out)
 
endfunction
