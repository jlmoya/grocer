function ts=lagts(varargin)
 
// PURPOSE: Computes x(t-n) for a timeseries x(t)
// ------------------------------------------------------------
// INPUT:
// * first argument = the oder of differenciation (optional,
//    set to 1 if not provided)
// * last argument (which can be the first !) = a time series
//    or a tsmat
// ------------------------------------------------------------
// OUTPUT:
// * ts = the lagged time series or a lagged tsmat
// ------------------------------------------------------------
// Copyright: Eric Dubois & Emmanuel Michaux 2008-2009
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
nargin=length(varargin)
ts=varargin(nargin)
if nargin == 1 then
   ts('dates')=ts('dates')+1
 
   if (typeof(ts)=='tsmat') then
      load(GROCERDIR+'/param/tsmat_names.dat')
      select tsmat_names
 
      case 'reset' then
         ts('names')='var'+string([1:size(tsmat('series'),2)]')
 
      case 'trace' then
         ts('names')='lag('+ts('names')+')'
 
      end
   else
      ts(5)=' '
 
   end
 
else
   ts('dates')=ts('dates')+varargin(1)
 
   if (typeof(ts)=='tsmat') then
      load(GROCERDIR+'/param/tsmat_names.dat')
      select tsmat_names
 
      case 'reset' then
         ts('names')='var'+string([1:size(ts('series'),2)]')
 
      case 'trace' then
         ts('names')='lag('+string(varargin(1))+','+ts('names')+')'
 
      end
 
   else
      ts(5)=' '
 
   end
end
 
endfunction
