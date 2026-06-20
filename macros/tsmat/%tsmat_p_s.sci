function [tsmat]=%tsmat_p_s(tsmat,const)
 
// PURPOSE: operates the exponentiation of a tsmat;
// the overloading capability of scilab allows then one to
// write ts2^p to do the exponentiation
// ------------------------------------------------------------
// INPUT:
// * ts = a tlist of type tsmat
// * const = a real constant
// ------------------------------------------------------------
// OUTPUT:
// * tsmat = the exponentiated tsmat
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
tsmat('series')=tsmat('series').^const
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat('names')='var'+string([1:size(tsmat('series'),2)]')
 
case 'trace' then
   tsmat('names') = tsmat('names')+' ^ '+string(const)
 
end
 
 
if or(tsmat(1) == 'comments') then
   tsmat('comments')=emptystr(size(tsmat('names'),1),1)
end
 
endfunction
