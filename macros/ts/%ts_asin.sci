function ts=%ts_asin(ts)
 
// PURPOSE: define the sine inverse of a time series;
// the overloading capability of scilab allows then one to write
// acos(ts) to take the sine inverse of time series ts
// ------------------------------------------------------------
// INPUT:
// * ts= a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = a time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
ts('series')=asin(ts('series'))
ts(5)=''
 
endfunction
