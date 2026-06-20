function [rf]=varf_d()
 
global GROCERDIR;
 
// examples using varf()
// data taken from James Le Sage
 
load(GROCERDIR+'/data/datajpl.dat')
illinos=reshape(illinos,'1982m1')
indiana=reshape(indiana,'1982m1')
kentucky=reshape(kentucky,'1982m1')
michigan=reshape(michigan,'1982m1')
ohio=reshape(ohio,'1982m1')
pennsyvlania=reshape(pennsyvlania,'1982m1')
tennesse=reshape(tennesse,'1982m1')
westvirginia=reshape(westvirginia,'1982m1')
bounds('1982m7','1994m12')
varjls=VAR(2,'endo=illinos;indiana;kentucky;michigan;ohio;pennsyvlania;tennesse;westvirginia','noprint')

rf=varf(varjls,'1995m12')
ecmjls=ecm(2,'endo=[illinos;indiana;kentucky;michigan;ohio;pennsyvlania;tennesse;westvirginia]','exo_st=const','noprint')
rf=varf('ecmjls',[-1,12])

endfunction
