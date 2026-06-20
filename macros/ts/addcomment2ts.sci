function [ts]=addcomment2ts(ts,comment)
 
// PURPOSE: add a comment (descritpion) filed to a ts
// ------------------------------------------------------------
// INPUT:
// * ts = a ts
// * comment = a string
// ------------------------------------------------------------
// OUTPUT:
// * ts = the corresponding time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2008
// http://grocer.toolbox.free.fr/grocer.html
 
if typeof(ts) ~= 'ts' then
   error('first arg should be a ts')
end
 
if and(ts(1) ~= 'comment') then
   ts(1)($+1) = 'comment'
end
 
ts('comment') = comment
 
endfunction
