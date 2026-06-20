function [tsmat]=%s_r_tsmat(const,tsmat)
 
// PURPOSE: operates the division of a constant by each
// elements of a tsmat;
// the overloading capability of scilab allows then one to
// write const/tsmat to do the product
// ------------------------------------------------------------
// INPUT:
// * tsmat= a tlist of type tsmat
// * const = a real constant
// ------------------------------------------------------------
// OUTPUT:
// * tsmat= a tlist of type tsmat,
//      product of the constant by a timeseries
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux 2008
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
s=tsmat('series')
 
for i=1:size(s,2)
  scalc=(~isnan(s(:,i)) & s(:,i) ~=0)
  tsmat('series')(scalc,i)=const*ones(size(s,1)-size(scalc,1)) ./ s(scalc,i)
// for the sake of speed, fill the timeseries ts with the
// values of the product
end
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat('names')='var'+string([1:size(tsmat('series'),2)]')
 
case 'trace' then
   tsmat('names') = string(const)+'/'+tsmat('names')
end
 
 
if or(tsmat(1) == 'comments') then
   tsmat('comments')=emptystr(size(tsmat('names'),1),1)
end
 
endfunction
