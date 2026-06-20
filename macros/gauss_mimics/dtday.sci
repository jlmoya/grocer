function dt = dtday(year,month,day)
 
// PURPOSE: mimics gauss function dtday: creates a matrix in
// DT scalar format containing only the year, month and day.
// Time of day information is zeroed out.
// ------------------------------------------------------------
// INPUT:
// * year = (N x k) matrix of years
// * month = (N x k) matrix of months, 1-12
// * day = (N x k) matrix of days, 1-31
// ------------------------------------------------------------
// OUTPUT:
// dt = (N x k) DT scalar format dates
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[year,month,day]=resize(year,month,day)
dt=year*1e10+month*1E8+day*1e6
 
endfunction
