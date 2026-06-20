function ts=%ts_log(ts)
 
// PURPOSE: define the logarithm of a time series;
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
 
s=series(ts)
s0=find(s<=0)
s(s0)=1
s1=isnan(s)
s(s1)=1
serieout=log(s)
serieout(s0)=%nan
serieout(s1)=%nan
 
// for the sake of speed, fill the timeseries ts1 with the values
// of the product
ts('series')=serieout
ts(5)=''
 
endfunction
