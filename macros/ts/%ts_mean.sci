function m=%ts_mean(ts)
 
// PURPOSE: define the mean of a time series;
// the overloading capability of scilab allows then one to write
// mean(ts) to take the mean of time series ts
// ------------------------------------------------------------
// INPUT:
// * ts= a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = a time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
x=ts('series')
m=sum(x)/size(x,1)
 
endfunction
