function ts=growthr(ts,lag_gr)
 
// PURPOSE: Computes ts(t)/ts(t-lag_gr)-1
// ------------------------------------------------------------
// INPUT:
// * ts =  a timeseries or a tsmat
// * lag_gr = an integer (optional, set to 1 if not provided)
// ------------------------------------------------------------
// OUTPUT:
// * ts = the growthr of the time series
// ------------------------------------------------------------
// NOTE: if a value for ts is 0, then the corresponding value
// is set to 'NA'
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002/ Emmnauel Michaux 2005
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   lag_gr=1
end
s=ts('series')
nobs=size(s,1)
sl=s(1:nobs-lag_gr,:)
 
tseqz=find(sl==0)
if tseqz ~= [] then
   warning('in growthr, some value of the orignial ts is 0, corresponding value in the output ts has been set to Nan')
// now, replace by 1 zero values in the nobs-nlag_gr first values
// of s to avoid generating a division by zero error
   sl(tseqz)=1
end
 
tseqz2 = isnan(sl)
if or(tseqz2 ~= 'T') then
// now, replace by 1 zero values in the nobs-nlag_gr first values
// of s to avoid generating a division by zero error
   sl(tseqz2)=1
end
 
sout=s(1+lag_gr:nobs,:)./sl-1
// set to %nan the 0 values in original sl
sout(tseqz)=%nan
sout(tseqz2)=%nan
 
ts('dates')=ts('dates')(1+lag_gr:nobs)
ts('series')=sout
 
if (typeof(ts)=='tsmat') then
   load(GROCERDIR+'/param/tsmat_names.dat')
   select tsmat_names
 
   case 'reset' then
      ts('names')='var'+string([1:size(tsmat('series'),2)]')
 
   case 'trace' then
      ts('names')='growthr('+ts('names')+')'
 
   end
 
   else
      ts(5)=' '
 
   end
endfunction
