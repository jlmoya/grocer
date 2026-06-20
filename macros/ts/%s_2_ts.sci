function ts=%s_2_ts(s,ts)
 
// PURPOSE: returns the ts equal to 1 over the dates where s
// > ts and 0 over the other ones
// ------------------------------------------------------------
// INPUT:
// * ts = a time series
// * s = a real number
// ------------------------------------------------------------
// OUTPUT:
// * ts = the (0,1) resulting time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
ts('series')=bool2s(s>ts('series'))
ts(5)=''
 
endfunction
