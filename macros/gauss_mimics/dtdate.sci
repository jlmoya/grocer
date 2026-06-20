function dt = dtdate(year,month,day,hour,minute,second)
 
// PURPOSE: mimic gauss function dtdate: creates a matrix in
// DT scalar format
// ------------------------------------------------------------
// INPUT:
// * year = (N x k) matrix of years
// * month = (N x k) matrix of months, 1-12
// * day = (N x k) matrix of days, 1-31
// * hour = (N x k) matrix of hours, 0-23
// * minute = (N x k) matrix of minutes, 0-59
// * second = (N x k) matrix of seconds, 0-59
// ------------------------------------------------------------
// OUTPUT:
// dt = (N x k) DT scalar format dates
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[year,month,day,hour,minute,second]=resize(year,month,day,hour,minute,second)
dt=year*1e10+month*1E8+day*1e6+hour*1e4+minute*100+second
 
endfunction
