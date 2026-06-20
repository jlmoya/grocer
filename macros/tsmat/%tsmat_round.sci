function tsmat=%tsmat_round(tsmat)
 
// PURPOSE: define the rounded value to the nearets integer of a tsmat;
// the overloading capability of scilab allows then one to write
// round(tsmat) to take the rounded value of a tsmat
// ------------------------------------------------------------
// INPUT:
// * tsmat= a tlist of type tsmat
// ------------------------------------------------------------
// OUTPUT:
// * tsmat= a tlist of type tsmat
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois & Emmanuel Michaux (2008)
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
tsmat('series')=round(tsmat('series'))
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat('names')='var'+string([1:size(tsmat('series'),2)]')
 
case 'trace' then
   tsmat('names') = 'round('+tsmat('names')+')'
 
end
 
 
endfunction
