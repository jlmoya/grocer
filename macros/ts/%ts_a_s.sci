function [ts]=%ts_a_s(ts,const)
 
// PURPOSE: operates the addition of a timeseries and a
// constant; the overloading capability of scilab allows then
// to write ts+const to do the addition
// ------------------------------------------------------------
// INPUT:
// * ts = a time series
// * const = a real constant
// ------------------------------------------------------------
// OUTPUT:
// * ts = the product of the timeseries by the constant
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
// for the sake of speed, fill the timeseries ts with the
// values of the product
ts('series')=ts('series')+const
ts(5)=''
 
endfunction
