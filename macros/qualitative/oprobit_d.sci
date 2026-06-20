function res =oprobit_d()
 
global GROCERDIR;
 
load(GROCERDIR+'\data\gunther.dat')
 
res=oprobit('rrating',['asset' 'equ' 'growth' 'loa' 'metro' 'prl'])
 
endfunction
