function []=pltseries_d()
 
 
// an example using pltts
 
t=reshape(exp([1:100]/50),'1a')
// the most simple
pltts('t')
// the same except for the window #
pltts('t','window=2','title=t','bounds=[''1a'';''100a'']')
// with different options
pltts('t','window=3','title=my ts','bounds=[''1a'';''40a'']')
endfunction
