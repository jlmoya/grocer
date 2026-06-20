function ts=delda(varargin)
 
// PURPOSE: Compute x(t)-x(t-n) for a timeseries or a tsmat x
// while ignoring na values
// ------------------------------------------------------------
// INPUT:
// * first argument = the oder of differenciation (optional,
// set to 1 if not provided, can be >0, =0 or <0)
// * last argument (which can be the first !) = a time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = the diferenciated time series
//      or the the diferenciated tsmat
// ------------------------------------------------------------
// NOTES: equivalent, but a little bit quicker than
// x-lagts(n,x)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
nargin=length(varargin)
ts=varargin(nargin)
dat=ts('dates')
s=ts('series')
nonna=~isnan(s)
 
findnonna=find(nonna(:,1)) // assume that NA's are placed identicaly in each row
snonna=matrix(s(nonna),size(findnonna,'*'),size(nonna,2))
findnonna=matrix(find(nonna),size(findnonna,'*'),size(nonna,2))
 
if nargin == 1 then
   l=1
else
   l=varargin(1)
end
 
n=size(snonna,1)
l1=max(1,l+1)
l0=max(1,-l+1)
ln=n-max(0,-l)
ln1=n-max(0,l)
 
s=s*%nan
s(findnonna(l1:ln,:))=vec(snonna(l1:ln,:)-snonna(l0:ln1,:))
ts('series')=s
 
   if (typeof(ts)=='tsmat') then
      load(GROCERDIR+'/param/tsmat_names.dat')
      select tsmat_names
 
      case 'reset' then
         ts('names')='var'+string([1:size(tsmat('series'),2)]')
 
      case 'trace' then
         ts('names')='diff('+string(l)+','+ts('names')+')'
 
      end
 
   else
      ts(5)=' '
 
   end
 
endfunction
