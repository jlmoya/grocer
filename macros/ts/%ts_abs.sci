function ts=%ts_abs(ts)
 
// PURPOSE: define the absolute value of a time series;
// the overloading capability of scilab allows then one to write
// log(ts) to take the exponential of time series ts
// ------------------------------------------------------------
// INPUT:
// * ts= a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = the log of the original time series
// ------------------------------------------------------------
// NOTES: the function does not authorize negative values
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
// for the sake of speed, fill the timeseries ts1 with the values
// of the product
ts('series')=abs(ts('series'))
ts(5)=''
 
endfunction
