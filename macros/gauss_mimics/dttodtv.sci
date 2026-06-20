function dtv = dttodtv(dt)
 
// PURPOSE: mimics gauss function dttodtv: Converts DT scalar
// format to DTV vector format
// ------------------------------------------------------------
// INPUT:
// * dt = (N x 1) vector, DT scalar format
// ------------------------------------------------------------
// OUTPUT:
// dtv = (N x 8) matrix, DTV vector format:
//       [year month day hour minute second "day of week" ...
//        "Days since Jan 1 of current year"]
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
[year, month, day, hour, minute, second, dinweek, dinyear] = explodt(dt)
dtv = [year, month, day, hour, minute, second, dinweek, dinyear]
 
endfunction
