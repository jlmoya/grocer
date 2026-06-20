function [year, month, day, hour, minute, second,dinweek, dinyear] = explodt(dt)
 
// PURPOSE: mimics gauss function explodt: explode DT scalar
// format into its components
// ------------------------------------------------------------
// INPUT:
// * dt = (N x 1) vector, DT scalar format
// ------------------------------------------------------------
// OUTPUT:
// * year = (N x 1) vector, year
// * month = (N x 1) vector, month
// * day = (N x 1) vector, day
// * hour = (N x 1) vector, hour
// * minute = (N x 1) vector, minute
// * second = (N x 1) vector, second
// * dinweek = (N x 1) vector, days of week
// * dinweek = (N x 1) vector, days since Jan 1 of current year
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
year=floor(dt/1E10)
dt=dt-year*1E10
month=floor(dt/1E8)
dt=dt-month*1e8
day=floor(dt/1E6)
dt=dt-day*1E6
hour=floor(dt/10000)
dt=dt-hour*10000
minute=floor(dt/100)
second=dt-minute*100
 
m0 = floor((14 - month)/12);
y = year + 4800 - m0;
m = month + 12*m0 - 3;
 
d1 = day + floor((153*m + 2)/5) ...
        + y*365 + floor(y/4) - floor(y/100) + floor(y/400)+2
 
dtv=[year month day hour minute second modulo(d1, 7) datenum(year,month,day)-datenum(year,1,1)]
 
 
endfunction
