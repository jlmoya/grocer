function [ts1]=%ts_d_ts(ts1,ts2)
 
// PURPOSE: operates the division of 2 timeseries;
// the overloading capability of scilab allows then one to write
// ts1/ts2 to do the division
// ------------------------------------------------------------
// INPUT:
// * ts1 = a time series
// * ts2 = a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts1 = the division of the 2 time series
// ------------------------------------------------------------
// NOTES: for 0 values in ts2, the result is set to Nan and a
// warning message is sent
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
f1=ts1('freq')
f2=ts2('freq')
// test that the frequencies are the same taking into account
// the possibility that some frequencies can be written as a
//  number or as a 1x2 vector [fq, 1]
if cumprod(f1) ~= cumprod(f2) | f1(1) ~= f2(1) then
   error('timeseries have not the same frequency')
end
 
d1=ts1('dates')
d2=ts2('dates')
s1=ts1('series')
s2=ts2('series')
 
d1f=d1(1)
d1l=d1(size(d1,1))
d2f=d2(1)
d2l=d2(size(d2,1))
 
// determines the commun time span of the 2 series
datfirst=max(d1f,d2f)
datlast=min(d1l,d2l)
 
s1=s1(datfirst-d1f+1:datlast-d1f+1)
s2=s2(datfirst-d2f+1:datlast-d2f+1)
s=%nan*s1
 
ts1('dates')=[datfirst:datlast]'
s2calc=(~isnan(s2) & s2 ~=0)
// to avoid division by zero, values NA or null in ts2 are ignored
s(s2calc)=s1(s2calc) ./ s2(s2calc)
 
// for the sake of speed, fill the timeseries ts1 with the
// values of the division
ts1('series')=s
ts1(5)=''
 
endfunction
