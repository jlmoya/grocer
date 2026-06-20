function [ts1]=%ts_g_ts(ts1,ts2)
 
// PURPOSE: if ts1 and ts2 are 2 time series built from a test
// (such as ts1 == 2 or ts2 > 5), then build the ts: ts1 | ts2
// ------------------------------------------------------------
// INPUT:
// * ts1 = a time series
// * ts2 = a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts1 = the ts equal to 1 when one of the condition is met,
//   0 if not
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2008
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
dataux=[datfirst:datlast]'
 
// for the sake of speed, fill the timeseries ts1 with the
// values of the sum
ts1('dates')=[datfirst:datlast]'
ts1('series')=s1(datfirst-d1f+1:datlast-d1f+1)+...
              s2(datfirst-d2f+1:datlast-d2f+1).*(1-s1(datfirst-d1f+1:datlast-d1f+1))
 
ts1(5)=''
 
endfunction
