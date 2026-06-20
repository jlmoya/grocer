function [ts]=%s_a_ts(const,ts)
 
// PURPOSE: operates the addition of a number and a timeseries;
// the overloading capability of scilab allows then one to write
// const+ts to do the addition
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
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
// for the sake of speed, fill the timeseries ts1 with the values
// of the product
ts('series')=ts('series')+const
ts(5)=''
 
endfunction
