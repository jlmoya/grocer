function ts=%ts_sin(ts)
 
// PURPOSE: define the sin of a time series;
// the overloading capability of scilab allows then one to write
// sin(ts) to take the sin of time series ts
// ------------------------------------------------------------
// INPUT:
// * ts= a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = a time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
ts('series')=sin(ts('series'))
ts(5)=''
 
endfunction
