function [ts1]=%ts_s_ts(ts1,ts2)
 
// PURPOSE: operates the substraction of 2 timeseries ; the
// overloading capability of scilab allows then one to write
// ts1-ts2 to do the substraction
// ------------------------------------------------------------
// INPUT:
// *  2 time series ts1 and ts2
// OUTPUT:
// * ts1 = a timeseries
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
d2f=d2(1)
datfirst=max(d1f,d2f)
datlast=min(d1(size(d1,1)),d2(size(d2,1)))
 
ts1('dates')=[datfirst:datlast]'
ts1('series')=s1(datfirst-d1f+1:datlast-d1f+1)-s2(datfirst-d2f+1:datlast-d2f+1)
ts1(5)=''
 
endfunction
