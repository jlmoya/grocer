function ts=%ts_exp(ts)
 
// PURPOSE: define the exponential of a time series;
// the overloading capability of scilab allows then one to write
// exp(ts) to take the exponential of time series ts
// ------------------------------------------------------------
// INPUT:
// * ts= a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = a time series
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
ts('series')=exp(ts('series'))
ts(5)=''
 
endfunction
