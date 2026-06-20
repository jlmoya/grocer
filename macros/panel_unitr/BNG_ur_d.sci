function res=BNG_ur_d()
 
global GROCERDIR;
 
load(GROCERDIR+'/data/gdpan_oecd.dat')
listvar=dblist(GROCERDIR+'/data/gdpan_oecd.dat')
data=log(explone(listvar))
 
pmax=4;
bounds()
res=BNG_ur('log('+listvar+')','pmax=4','kmax=5','t_order=0','criteria=IC2')
 
 
endfunction
