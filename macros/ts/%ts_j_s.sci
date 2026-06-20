function ts=%ts_j_s(ts,const)
 
// PURPOSE: operates the exponentiation of a timeseries;
// the overloading capability of scilab allows then one to
// write ts .^ p to do the exponentiation
// ------------------------------------------------------------
// INPUT:
// * ts = a time series
// * const = a real constant
// ------------------------------------------------------------
// OUTPUT:
// * ts = the exponentiated time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
ts('series')=ts('series').^const
ts(5)=''
 
endfunction
