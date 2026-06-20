function res = Moon_Perron_d()
 
global GROCERDIR;
 
// load the database
load(GROCERDIR+'/data/gdpan_oecd.dat')
// retrieve the names of all variables in database
listvar=dblist(GROCERDIR+'/data/gdpan_oecd.dat')
bounds()
res = Moon_Perron('log('+listvar+')','kmax=5','t_order=0','kernel=qs','bandwidth=n','criteria=BIC3')
 
endfunction
