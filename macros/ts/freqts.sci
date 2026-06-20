function f=freqts(ts)
 
// PURPOSE: return the frequency of a time series
// ------------------------------------------------------------
// INPUT:
// ts = a time series
// ------------------------------------------------------------
// OUTPUT:
// f = the frequency of the timeseries
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
f=ts('freq')
if size(f,'*') == 1 then
   f=[f 1]
end
 
endfunction
