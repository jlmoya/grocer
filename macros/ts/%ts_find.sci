function [s,d]=%ts_find(ts)
 
// PURPOSE: find values in a ts
// ------------------------------------------------------------
// INPUT:
// * ts = a timeseries
// ------------------------------------------------------------
// OUTPUT:
// * s = indexes of the series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2008
// http://grocer.toolbox.free.fr/grocer.html
 
s=find(ts('series') == 1)
d=num2date(ts('dates')(s),ts('freq'))
d=d'
 
endfunction
