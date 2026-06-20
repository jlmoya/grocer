function res=Chang_IV_d()
 
global GROCERDIR;
 
load(GROCERDIR+'/data/gdpan_oecd.dat')
listvar=dblist(GROCERDIR+'/data/gdpan_oecd.dat')
data=log(explone(listvar))
 
bounds()
res = Chang_IV('log('+listvar+')','pmax=4','t_order=0')
 
 
endfunction
