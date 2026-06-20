function def_dailyform(y,m,d,grocer_dailysep)
 
// PURPOSE: create the data base for the format of daily dates
// ------------------------------------------------------------
// INPUT:
// * y = place of the year in the dates
// * m = place of the month in the dates
// * d = day of the year in the dates
// * grocer_dailysep = separator between the day, month and
//   year
// ------------------------------------------------------------
// OUTPUT:
// nothing: data are saved into the file
// SCI\param\dailyform.dat
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005-2007
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
grocer_dailypart=[y ; m ; d]
vers=getversion("scilab")(1)
if vers >= 5.4 then
   save(GROCERDIR+'\param\dailyform.dat','grocer_dailypart','grocer_dailysep')
else
   save(GROCERDIR+'\param\dailyform.dat','grocer_dailypart','grocer_dailysep')
end
 
endfunction
