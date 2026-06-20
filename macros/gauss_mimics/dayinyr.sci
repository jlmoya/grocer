function daynum = dayinyr(dt)
 
// PURPOSE: mimic Gauss function daynum: returns day number
// in the year of a given date
// ------------------------------------------------------------
// INPUT:
// * dt = (3 x 1) or (4 x 1) vector, date to check. The date
//   should be in the form returned by date.
// ------------------------------------------------------------
// OUTPUT:
// * daynum = scalar, the day number of that date in that year
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
daynum=datenum(dt(1),dt(2),dt(3))-datenum(dt(1),1,1)+1
 
endfunction
