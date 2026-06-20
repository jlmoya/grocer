function ts=%ts_sign(ts)
 
// PURPOSE: define the sign of a time series;
// the overloading capability of scilab allows then one to
// write sign(ts) to take the sign of time series ts
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
 
y=sign(s)
y(isnan(s))=%nan
ts('series')=y
ts(5)=''
 
endfunction
