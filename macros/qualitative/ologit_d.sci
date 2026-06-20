function res=ologit_d()
 
global GROCERDIR;
 
load(GROCERDIR+'\data\gunther.dat')
 
res=ologit('rrating',['asset' 'equ' 'growth' 'loa' 'metro' 'prl'])
 
endfunction
