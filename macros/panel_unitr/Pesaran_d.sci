function res = Pesaran_d()
 
global GROCERDIR;
 
// load the database
load(GROCERDIR+'/data/gdpan_oecd.dat')
// retrieve the names of all variables in database
listvar=dblist(GROCERDIR+'/data/gdpan_oecd.dat')
bounds()
res = Pesaran('log('+listvar+')','pmax=4','t_order=0')
 
endfunction
