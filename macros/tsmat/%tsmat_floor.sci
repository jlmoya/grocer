function tsmat=%tsmat_floor(tsmat)
 
// PURPOSE: define the floor of a tsmat;
// the overloading capability of scilab allows then one to write
// floor(tsmat) to take the floor of tsmat
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
 
tsmat('series')=floor(tsmat('series'))
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat('names')='var'+string([1:size(tsmat('series'),2)]')
 
case 'trace' then
   tsmat('names') = 'floor('+tsmat('names')+')'
 
end
 
 
 
if or(tsmat(1) == 'comments') then
   tsmat('comments')=emptystr(size(tsmat('names'),1),1)
end
 
endfunction
