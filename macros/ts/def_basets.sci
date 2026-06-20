function def_basets(grocer_basefqnum,grocer_basefqlit)
 
// PURPOSE: create the data base of the frequencies and their
// literal representation
// ------------------------------------------------------------
// INPUT:
// * grocer_basefqnum = a (nr x nc) matrix of frequencies
//    --> if nc == 1 then all frequencies are at most annual
//        (monthly, quarterly, weekly, ... as well as annual)
//    --> if nc == 2 then frequencies can be less than annual
//        in that case each row has a 1 in the first or second
//        cell:
//        - a 1 in the first cell means that the frequency is
//        less than annual (decades, centuries,...) and the
//        second cell is the frequency (10 for decades, 100 for
//        centuries,...)
//        - a 1 in the second cell means that the frequency is
//        more than annual (monthly, quarterly, weekly, ... as
//        well as annual) and the first cell is the frequency
//        (12 for monthly, 4 for quarterly, ... 1 for annual)
// * grocer_basefqlit = a string matrix associating a symbol to
//   the daily and weekly ts, and then to each frequency in
//   grocer_basefqnum
// ------------------------------------------------------------
// OUTPUT:
// nothing: data are saved into the file
// SCI\macros\grocer\db\basets.dat
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005-2007
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nr,nc]=size(grocer_basefqnum)
if nr ==1 | nr ==2 & nr < nc then
   grocer_basefqnum=grocer_basefqnum'
end
 
if nc ==1 then
   grocer_basefqnum=[grocer_basefqnum ones(nr,1)]
end
grocer_basefqnum=[ 365 1 ; 52 1 ; grocer_basefqnum ]
 
grocer_basefqlit=[grocer_basefqlit(:)]
vers=getversion("scilab")(1)
if vers >= 5.4 then
   save(GROCERDIR+'\macros\grocer\param\basets.dat','grocer_basefqnum','grocer_basefqlit')
else
   save(GROCERDIR+'\macros\grocer\param\basets.dat',grocer_basefqnum,grocer_basefqlit)
end
 
endfunction
