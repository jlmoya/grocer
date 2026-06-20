function ts=%ts_sqrt(ts)
 
// PURPOSE: define the square root of a time series;
// the overloading capability of scilab allows then one to
// write sqrt(ts) to take the exponential of time series ts
// ------------------------------------------------------------
// INPUT:
// * ts= a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = a time series
// ------------------------------------------------------------
// NOTES: if there are negative values, then the corresponding
// value is set to Nan
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
s=ts('series')
negval=find(s<0 | isnan(s))
if negval ~=[] then
   write(%io(2),' ','(a)')
   warning('taking the square root of negative values; the results is set to Nan')
   write(%io(2),' ','(a)')
   s(negval)=1
end
 
// for the sake of speed, fill the timeseries ts with the values
// of the square root
sout=sqrt(s)
sout(negval)=%nan
ts('series')=sout
ts(5)=''
 
endfunction
