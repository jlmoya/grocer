function [r]=fac_kalman_d()
 
global GROCERDIR;
 
 
load(GROCERDIR+'/data/BusinessSurvey.dat');
bounds('1976m3','1997m3')
 
[r]=fac_kalman(['pp';'fp';'gob';'fob';'in';'gpp'],string([0.9;0]),'0',list('0.1','0.1','0.1','0.1','0.1','0.1'))
 
endfunction
 
