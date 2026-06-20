function []=ers_d()
 
global GROCERDIR;
 
load(GROCERDIR+'/data/bdhenderic.dat') ;
bounds('1964q1','1989q2')
ers('ly',1,4)
bounds('1964q2','1989q2')
ers('delts(ly)',0,4)
 
endfunction
