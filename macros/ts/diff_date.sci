function num=diff_date(lastdate,firstdate)
 
// PURPOSE: Computes the number of observations between 2 dates
// ------------------------------------------------------------
// INPUT:
// * lastdate = last date
// * firstdate = first date
// ------------------------------------------------------------
// OUTPUT:
// * num = the number of observations between the 2 dates
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
num=date2num(lastdate)-date2num(firstdate)
 
endfunction
