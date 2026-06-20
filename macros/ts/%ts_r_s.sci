function [ts]=%ts_r_s(ts,const)
 
// PURPOSE: operates the division of a timeseries by a number;
// the overloading capability of scilab allows then one to write
// ts/const to do the addition
// ------------------------------------------------------------
// INPUT:
// * ts = a time series
// *  const = a real
// ------------------------------------------------------------
// OUTPUT:
// * ts = the division of the timeseries by the number
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
if const == 0 then
   error('dividing a timeseries by 0')
end
// for the sake of speed, fill the timeseries ts with the
// values of the division
ts('series')=ts('series')/const
ts(5)=''
 
endfunction
