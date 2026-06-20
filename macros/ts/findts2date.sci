function d=findts2date(ts)
 
// PURPOSE: find date where a condition is true
// ------------------------------------------------------------
// INPUT:
// * ts = a timeseries calcualted as a condition
// ------------------------------------------------------------
// OUTPUT:
// * d = a date
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2008
// http://grocer.toolbox.free.fr/grocer.html
 
s=find(ts('series') == 1)
dat=ts('dates')
d=num2date(dat(s),ts('freq'))
 
endfunction
