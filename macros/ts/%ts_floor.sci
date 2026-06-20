function ts=%ts_floor(ts)
 
// PURPOSE: define the floor of a time series;
// the overloading capability of scilab allows then one to
// write floor(ts) to take the floor of time series ts
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
ts('series')=floor(s)
ts(5)=''
 
endfunction
