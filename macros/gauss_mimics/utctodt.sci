function dt = utctodt(utc)
 
// PURPOSE: mimics gauss function utctodt: Converts UTC scalar
// format to DT scalar format
// ------------------------------------------------------------
// INPUT:
// * utc = a (N x 1) vector, in UTC scalar format (that is the
//  number of seconds since January 1, 1970
// ------------------------------------------------------------
// OUTPUT:
// * dt = a (N x 1) vector, DT scalar format
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
dt0=getdate(utc)
dt=dt0(1)*1E10+dt0(2)*1E8+dt0(6)*1E6+dt0(7)*1e4+dt0(8)*1e2+dt0(9)
 
endfunction
