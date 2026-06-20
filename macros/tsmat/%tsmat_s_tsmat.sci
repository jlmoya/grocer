function [tsmat1]=%tsmat_s_tsmat(tsmat1,tsmat2)
 
// PURPOSE: operates the substraction of 2 tsmat ; the
// overloading capability of scilab allows then one to write
// tsmat1-tsmat2 to do the substraction
// ------------------------------------------------------------
// INPUT:
// *  2 tlist of type tsmat, tsmat1 and tsmat2
// ------------------------------------------------------------
// OUTPUT:
// * tsmat1 = a tlist of type tsmat
// ------------------------------------------------------------
// NOTES:
// ------------------------------------------------------------
// Copyright: Eric Dubois 2008
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
f1=tsmat1('freq')
f2=tsmat2('freq')
// test that the frequencies are the same taking into account
// the possibility that some frequencies can be written as a
//  number or as a 1x2 vector [fq, 1]
if cumprod(f1) ~= cumprod(f2) | f1(1) ~= f2(1) then
   error('timeseries have not the same frequency')
end
 
d1=tsmat1('dates')
d2=tsmat2('dates')
s1=tsmat1('series')
s2=tsmat2('series')
 
if (size(s1,2)~=size(s2,2)) then
  error('tsmat have not the same number of columns')
end
 
d1f=d1(1)
d2f=d2(1)
datfirst=max(d1f,d2f)
datlast=min(d1(size(d1,1)),d2(size(d2,1)))
 
tsmat1('dates')=[datfirst:datlast]'
tsmat1('series')=s1(datfirst-d1f+1:datlast-d1f+1,:)-s2(datfirst-d2f+1:datlast-d2f+1,:)
 
load(GROCERDIR+'/param/tsmat_names.dat')
select tsmat_names
 
case 'reset' then
   tsmat1('names')='var'+string([1:size(tsmat1('series'),2)]')
 
case 'trace' then
   tsmat1('names') = tsmat1('names')+' - '+tsmat2('names')
 
end
 
 
 
if or(tsmat1(1) == 'comments') then
   tsmat1('comments')=emptystr(size(tsmat1('names'),1),1)
end
 
endfunction
