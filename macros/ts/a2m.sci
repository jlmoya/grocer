function tso=a2m(tsi)
 
// PURPOSE: expand an annual series into a monthly one, by
// duplicating 12 times the annual values
// ------------------------------------------------------------
// INPUT:
// * tsi = an annual time series
// ------------------------------------------------------------
// OUPTUT:
// * tso = a monthly time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
 
if or(tsi('freq') ~= 1)  then
   error('input is not an annual ts')
end
ser0=tsi('series')
dat0=tsi('dates')
tso=tsi
tso('freq')=12
tso('dates')=[dat0(1)*12+1:dat0($)*12+12]'
tso('series')=ser0 .*. ones(12,1)
 
endfunction
