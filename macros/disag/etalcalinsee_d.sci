function [yhf,retal]=etalcalinsee_d()

global GROCERDIR
bounds()
load(GROCERDIR+'\data\EtalCalInsee.dat');

[yhf,retal] = etalcalinsee('consameu','cammeu','bench=''consmmeu''','s=12','alpha=0.15') ; 

endfunction
