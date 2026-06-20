function data=exp10(data)
 
// PURPOSE: define the inverse function of log10
// ------------------------------------------------------------
// INPUT:
// * data = a constant vector or a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = a time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
select typeof(data)
case 'ts' then
   data('series')=exp(data('series')*log(10))
case 'constant' then
   data=exp(data*log(10))
else
   error('not implemented for a '+typeof(data))
end
 
endfunction
