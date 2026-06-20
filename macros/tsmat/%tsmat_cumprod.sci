function tsmat=%tsmat_cumprod(tsmat)
 
// PURPOSE: computes the cumulative sum of a tsmat
// from the first value non NA until the following NA value or
// the end of the series
// The overloading capability of scilab allows then one to write
// cumprod(tsmat) to take the cumulative product of tsmat
// ------------------------------------------------------------
// INPUT:
// * tsmat= a tlist of type tsmat
// ------------------------------------------------------------
// OUTPUT:
// * tsmat= a tlist of type tsmat
// ------------------------------------------------------------
// Copyright: Eric Dubois & Emmanuel Michaux (2008)
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
s=tsmat('series')
names=tsmat('names')
[n,k]=size(s)
for i=1:k
   indnonna=find(~isnan(s(:,i)))
   if indnonna == [] then
      warning('input series '+names(i)+' has only NA values')
   else
      firstnonna=indnonna(1)
      s(firstnonna:size(s,1),i)=cumprod(s(firstnonna:size(s,1),i))
   end
end
 
tsmat('series')=s
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat('names')='var'+string([1:size(tsmat('series'),2)]')
 
case 'trace' then
   tsmat('names') = 'cumprod('+tsmat('names')+')'
 
end
 
 
 
if or(tsmat(1) == 'comments') then
   tsmat('comments')=emptystr(size(tsmat('names'),1),1)
end
 
endfunction
