function d = dayofweek(a)
 
// PURPOSE: mimic Gauss function dayofweek: returns day of week
// ------------------------------------------------------------
// INPUT:
// * a = (N x 1) vector, dates in DT format
// ------------------------------------------------------------
// OUTPUT:
// * a = (N x 1) vector integers indicating day of week of each
//   date:
//        1: Sunday
//        2: Monday
//        3: Tuesday
//        4: Wednesday
//        5: Thursday
//        6: Friday
//        7: Saturday
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
year=floor(a/1E10)
a=a-year*1E10
month=floor(a/1E8)
a=a-month*1e8
day=floor(a/1E6)
 
m0 = floor((14 - month)/12);
y = year + 4800 - m0;
m = month + 12*m0 - 3;
 
d1 = day + floor((153*m + 2)/5) ...
        + y*365 + floor(y/4) - floor(y/100) + floor(y/400)+2
 
d = 1+ modulo(d1, 7);
 
endfunction
