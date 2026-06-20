function bool=%ts_or(ts)
 
// PURPOSE: define and for a ts
// ------------------------------------------------------------
// INPUT:
// * ts= a time series
// ------------------------------------------------------------
// OUTPUT:
// * bool = a boolean
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
bool=or(ts('series'))
 
endfunction
