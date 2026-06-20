function [tsmat]=%s_m_tsmat(const,tsmat)
 
// PURPOSE: operates the product of a tsmat by a constant;
// the overloading capability of scilab allows then one to
// write tsmat*const to do the product
// ------------------------------------------------------------
// INPUT:
// * tsmat= a tlist of type tsmat
// * const = a real constant
// ------------------------------------------------------------
// OUTPUT:
// * tsmat= a tlist of type tsmat,
//      product of the constant by a timeseries
// ------------------------------------------------------------
// Copyright: Eric Dubois 2008
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
// for the sake of speed, fill the timeseries ts with the
// values of the product
tsmat('series')=tsmat('series')*const
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat('names')='var'+string([1:size(tsmat('series'),2)]')
 
case 'trace' then
   tsmat('names')=string(const)+'*'+tsmat('names')
end
 
 
if or(tsmat(1) == 'comments') then
   tsmat('comments')=emptystr(size(tsmat('names'),1),1)
end
 
endfunction
