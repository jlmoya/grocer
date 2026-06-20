function tsmat=%tsmat_sqrt(tsmat)
 
// PURPOSE: computes the square root a tsmat;
// the overloading capability of scilab allows then one to write
// sqrt(tsmat) to take the sqrt of a tsmat
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
 
s=tsmat('series')
negval=find(s<0 | isnan(s))
if negval ~=[] then
   write(%io(2),' ','(a)')
   warning('taking the square root of negative values; the results is set to Nan')
   write(%io(2),' ','(a)')
   s(negval)=1
end
 
// for the sake of speed, fill the timeseries ts with the values
// of the square root
sout=sqrt(s)
sout(negval)=%nan
tsmat('series')=sout
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat('names')='var'+string([1:size(tsmat('series'),2)]')
 
case 'trace' then
   tsmat('names') = 'sqrt('+tsmat('names')+')'
 
end
 
 
 
if or(tsmat(1) == 'comments') then
   tsmat('comments')=emptystr(size(tsmat('names'),1),1)
end
 
endfunction
