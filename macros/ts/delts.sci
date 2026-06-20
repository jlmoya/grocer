function tsout=delts(varargin)
 
// PURPOSE: Compute x(t)-x(t-n) for a timeseries x
// ------------------------------------------------------------
// INPUT:
// * first argument = the oder of differenciation (optional,
// set to 1 if not provided, can be >0, =0 or <0)
// * last argument (which can be the first !) = a time series
//    or a tsmat
// ------------------------------------------------------------
// OUTPUT:
// * tsout = the diferenciated time series or the
//    diferenciated tsmat
// ------------------------------------------------------------
// NOTES: equivalent, but a little bit quicker than
// x-lagtsmat(n,x)
// ------------------------------------------------------------
// Copyright: Eric Dubois & Emmanuel Michaux 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
nargin=length(varargin)
 
if nargin == 1 then
   tsout=varargin(1)
   s=tsout('series')
   dat=tsout('dates')
   n=size(s,1)
   tsout('series')=s(2:n,:)-s(1:n-1,:)
   tsout('dates')=dat(2:n,:)
 
   if typeof(tsout)=='tsmat' then
      load(GROCERDIR+'/param/tsmat_names.dat')
      select tsmat_names
 
      case 'reset' then
         tsout('names')='var'+string([1:size(tsout('series'),2)]')
 
      case 'trace' then
         tsout('names')='diff('+tsout('names')+')'
 
      end
 
   else
      tsout(5)=' '
 
   end
 
else
   tsout=varargin(2)
   s=tsout('series')
   dat=tsout('dates')
   n=size(s,1)
   l=varargin(1)
   tsout('series')=s(max(1,l+1):n-max(0,-l),:)...
                   -s(max(1,-l+1):n-max(0,l),:)
   tsout('dates')=dat(max(1,l+1):n-max(0,-l))
 
   if typeof(tsout)=='tsmat' then
      load(GROCERDIR+'/param/tsmat_names.dat')
      select tsmat_names
 
      case 'reset' then
         tsout('names')='var'+string([1:size(tsmat('series'),2)]')
 
      case 'trace' then
         tsout('names')='diff('+string(varargin(2))+','+tsout('names')+')'
 
      end
 
   else
      tsout(5)=' '
 
   end
 
end
 
endfunction
 
