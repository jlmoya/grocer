function [ts]=%ts_s_s(ts,const)
 
// PURPOSE: operates the substraction between a timeseries and
// a number;
// the overloading capability of scilab allows then one to
// write ts-const to do the substraction
// ------------------------------------------------------------
// INPUT:
// * ts = a time series
// * const = a real constant
// ------------------------------------------------------------
// OUTPUT:
// * ts = the substraction between the timeseries and the
// constant
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
// for the sake of speed, fill the timeseries ts1 with the
// values of the product
ts('series')=ts('series')-const
ts(5)=''
 
endfunction
