function dt = dttime(hour,minute,second)
 
// PURPOSE: mimic gauss function dttime: Creates a matrix in
// DT scalar format containing only the hour, minute and
// second. The date information is zeroed out
// ------------------------------------------------------------
// INPUT:
// * hour = (N x k) matrix of hours, 0-23
// * minute = (N x k) matrix of minutes, 0-59
// * second = (N x k) matrix of seconds, 0-59
// ------------------------------------------------------------
// OUTPUT:
// dt = (N x k) DT scalar format dates
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
[hour,minute,second]=resize(hour,minute,second)
dt=hour*1e4+minute*100+second
 
endfunction
