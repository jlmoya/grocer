function s=%ts_maxi(ts)
 
// PURPOSE: returns the maximum of a ts
// ------------------------------------------------------------
// INPUT:
// * ts = a time series
// ------------------------------------------------------------
// OUTPUT:
// * s = a real number: the maximum of the series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
s=max(ts('series'))
 
endfunction
