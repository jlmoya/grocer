function [ts]=%s_d_ts(const,ts)
 
// PURPOSE: operates the division of a constant by a timeseries;
// the overloading capability of Scilab allows then one to
// write const/ts to do the product
// ------------------------------------------------------------
// INPUT:
// * const = a real constant
// * ts = a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = the product of the constant by a timeseries
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
// for the sake of speed, fill the timeseries ts with the
// values of the product
ts('series')=const ./ ts('series')
ts(5)=''
 
endfunction
