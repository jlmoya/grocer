function t=isleapyear(y)
 
// PURPOSE: determines if a year is a leap one
// ------------------------------------------------------------
// INPUT:
// * y = a scalar, a year
// ------------------------------------------------------------
// OUTPUT:
// * t = a booelan indicating if the year is leap
// ------------------------------------------------------------
// Copyright: Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
t=modulo(y,400) == 0 | (modulo(y,4) == 0 & modulo(y,100) ~= 0)
 
endfunction
