function val=%ts_sum(ts)
 
// PURPOSE: takes the sum of a timeseries values
// ------------------------------------------------------------
// INPUT:
// * ts = a time series
// ------------------------------------------------------------
// OUTPUT:
// * val = a real value
// ------------------------------------------------------------
// NOTES: time series must not contain NA values
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
val=sum(ts('series'))
 
endfunction
