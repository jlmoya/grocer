function [ts]=%ts_m_s(ts,const)
 
// PURPOSE: operates the product of a timeseries by a constant;
// the overloading capability of scilab allows then one to
// write ts*const to do the product
// ------------------------------------------------------------
// INPUT:
// * ts = a time series
// * const = a real constant
// ------------------------------------------------------------
// OUTPUT:
// * ts = the product of the constant by a timeseries
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
// for the sake of speed, fill the timeseries ts with the
// values of the product
ts('series')=ts('series')*const
ts(5)=''
 
endfunction
