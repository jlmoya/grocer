function [ts]=%s_s_ts(const,ts)
 
// PURPOSE: operates the substraction between a number and a
// timeseries;
// the overloading capability of scilab allows then one to
// write const-ts to do the substraction
// ------------------------------------------------------------
// INPUT:
// *  const = a real
// * ts = a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = a time series
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
// for the sake of speed, fill the timeseries ts1 with the values
// of the product
ts('series')=const-ts('series')
ts(5)=''
 
endfunction
