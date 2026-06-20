function tsmat=%tsmat_n_s(tsmat,s)
 
// PURPOSE: returns the ts equal to 1 over the dates where
// tsmat ~= s and 0 over the other ones
// ------------------------------------------------------------
// INPUT:
// * tsmat = a tlist of type tsmat
// * s = a real number
// ------------------------------------------------------------
// OUTPUT:
// * tsmat = the (0,1) resulting tsmat
// ------------------------------------------------------------
// Copyright: Eric Dubois & Emmanuel Michaux 2008
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
tsmat('series')=bool2s(tsmat('series') ~= s)
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat('names')='var'+string([1:size(tsmat('series'),2)]')
 
case 'trace' then
   tsmat('names') = tsmat('names')+' ~= '+string(s)
 
end
 
 
if or(tsmat(1) == 'comments') then
   tsmat('comments')=emptystr(size(tsmat('names'),1),1)
end
 
endfunction
