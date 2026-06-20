function ts=%ts_ceil(ts)
 
// PURPOSE: define the rounded up values of a time series;
// the overloading capability of scilab allows then one to
// write ceil(ts) to take the rounded up values  of time series
// ts
// ------------------------------------------------------------
// INPUT:
// * ts= a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = a time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
s=ts('series')
 
// for the sake of speed, fill the timeseries ts with the
// rounded values
ts('series')=ceil(s)
ts(5)=''
 
endfunction
