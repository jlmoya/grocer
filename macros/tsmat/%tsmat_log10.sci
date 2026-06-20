function tsmat=%tsmat_log10(tsmat)
 
// PURPOSE: define the logarithm of a tsmat;
// the overloading capability of scilab allows then one to write
// log(tsmat) to take the exponential of a tsmat
// ------------------------------------------------------------
// INPUT:
// * tsmat= a tlist of type tsmat
// ------------------------------------------------------------
// OUTPUT:
// * tsmat= a tlist of type tsmat
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2008-2010
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
s=series(tsmat)
s0=find(s<=0)
s(s0)=1
s1=isnan(s)
s(s1)=1
serieout=log10(s)
serieout(s0)=%nan
serieout(s1)=%nan
 
tsmat('series')=serieout
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat('names')='var'+string([1:size(tsmat('series'),2)]')
 
case 'trace' then
   tsmat('names') = 'log10('+tsmat('names')+')'
 
end
 
 
if or(tsmat(1) == 'comments') then
   tsmat('comments')=emptystr(size(tsmat('names'),1),1)
end
 
endfunction
