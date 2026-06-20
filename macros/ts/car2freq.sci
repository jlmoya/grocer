function f=car2freq(car)
 
// PURPOSE: transforms a character into the corresponding
// frequency
// ------------------------------------------------------------
// INPUT:
// car = a character
// ------------------------------------------------------------
// OUTPUT:
// f = an integer
// ------------------------------------------------------------
// NOTES: very basic !
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
load(GROCERDIR+'\param\basets.dat')
 
i=find(grocer_basefqlit == car)
f=grocer_basefqnum(i,:)
 
endfunction
