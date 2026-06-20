function [ts]=%s_r_ts(const,ts)
 
// PURPOSE: operates the division of a number by a timeseries;
// the overloading capability of scilab allows then one to write
// const/ts to do the division
// ------------------------------------------------------------
// INPUT:
// * const = a real constant
// * ts = a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = the division of the number by the timeseries
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
s=ts('series')
s0= (s == 0)
s(~s0)=const ./ s(~s0)
s(s0)=%nan
ts('series')=s
ts(5)=''
 
endfunction
