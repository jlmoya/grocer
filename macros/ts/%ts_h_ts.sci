function ts1=%ts_h_ts(ts1,ts2)
 
// PURPOSE: if ts1 and ts2 are 2 time series built from a test
// (such as ts1 == 2 or ts2 > 5), then build the ts: ts1 & ts2
// ------------------------------------------------------------
// INPUT:
// * ts1 = a time series
// * ts2 = a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts1 = the ts equal to 1 when both conditions are met,
//   0 if not
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2008
// http://grocer.toolbox.free.fr/grocer.html
 
ts1=ts1*ts2
ts1(5)=''
 
endfunction
