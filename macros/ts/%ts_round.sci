function ts=%ts_round(ts)
 
// PURPOSE: define the rounded down values of a time series;
// the overloading capability of scilab allows then one to
// write round(ts) to take the rounded down values of time
// series ts
// ------------------------------------------------------------
// INPUT:
// * ts= a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = a time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
s=ts('series')
 
// for the sake of speed, fill the timeseries ts with the
// rounded values
ts('series')=round(s)
ts(5)=''
 
endfunction
