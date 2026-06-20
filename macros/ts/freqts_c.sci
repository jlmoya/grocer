function f=freqts_c(ts)
 
// PURPOSE: return the frequency of a time series
// ------------------------------------------------------------
// INPUT:
// ts = a time series
// ------------------------------------------------------------
// OUTPUT:
// f = the frequency of the timeseries in complex form
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
 
if typeof(ts) ~= 'ts' then
   error('entry should be a ts, not a '+typeof(ts))
end
f=ts('freq')
if size(f,'*') == 1 then
   f=f(1)+%i
else
   f=f(1)+%i*f(2)
end
 
endfunction
 
