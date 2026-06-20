function ts=%ts_cumsum(ts)
 
// PURPOSE: computes the cumulative sum of a time series
// from the first value non NA until the following NA value or
// the end of the series
// ------------------------------------------------------------
// INPUT:
// * ts = a timeseries
// ------------------------------------------------------------
// OUTPUT:
// * ts = the time series, cumulative sum, over the period
// from the first value non NA until the following NA value or
// the end of the series, of the original timeseries
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2008
// http://grocer.toolbox.free.fr/grocer.html
 
s=ts('series')
 
indnonna=find(~isnan(s))
if indnonna == [] then
 
   warning('input series has only NA values')
 
else
 
   firstnonna=indnonna(1)
   s(firstnonna:size(s,1))=cumsum(s(firstnonna:size(s,1)))
 
end
 
ts('series')=s
ts(5)=''
 
endfunction
