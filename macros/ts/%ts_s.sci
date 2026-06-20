function ts=%ts_s(ts)
 
// PURPOSE: define the expressions +ts (function needed by
// Scilab 6.0.2 version
// ------------------------------------------------------------
// INPUT:
// * ts = a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = minus the original time series
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
ts('series')=-ts('series')
 
endfunction
