function prtclwest(res,out)
 
// PURPOSE: prints the results of the Clark-West
// statistics
// ------------------------------------------------------------
// INPUT:
// * res = a results tlist
// * out = the file where the results are printed
// ------------------------------------------------------------
// out: nothing, only prints results
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
write(out,' ')
if res('meth') == 'Clark-West - martingal difference' then
  write(out,'	Clark-West test of martingal difference hypothesis')
else
  write(out,'	Clark-West predictive accuracy test')
end
 
if res('overlap') ~= 0 then
  write(out,' ')
  write(out,'Overlapping model with h = '+string(res('overlap')))
end
write(out,'')
 
if res('meth') == 'Clark-West - martingal difference' then
  write(out,'Random walk series: '+res('namey'))
  write(out,'Series of forecasts: '+res('namex'))
else
  write(out,'Forecasted serie: '+res('namey'))
  write(out,'Benchmark forecasts: '+res('namex')(1))
  write(out,'Competiting forecasts: '+res('namex')(2))
end
 
if res('prests') then
   ch='Forecasting period: '
   boundsvar=res('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
   write(out,ch)
end
write(out,' ')
 
mat2print = ['MSE-adj.','CW-Stat.','p-value';string(res('mse-adj')) string(res('stat')) string(res('pvalue'))]
printmat(mat2print,out)
printsep(out)
endfunction
