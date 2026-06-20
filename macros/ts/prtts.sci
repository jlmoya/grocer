function prtts(varargin)
 
// PURPOSE: prints time series
// ------------------------------------------------------------
// INPUT:
//   - timeseries or names of timeseries (between quotes)
//   - the string 'names=name1,name2,...,namen if the user wants
//   to give other names that the ones of the series (should
//   not be entered as first argument
// OUPTUT:
// * nothing
// ------------------------------------------------------------
// NOTES:
// * time series are printed four by four; if they are supplied
// between quotes, then they are printed under their name; if
// not, they are printed under the name 'series i'; if there
// are NA's, a NA is printed
// * provided that the final object is a ts, formulas are
// authorized in any input argument
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_namets=['dates']
grocer_nargin=length(varargin)
if typeof(varargin(1)) == 'string' then
   grocer_ts=evstr(varargin(1))
   grocer_namets=[grocer_namets , varargin(1)]
else
   grocer_ts=varargin(1)
   grocer_namets=[grocer_namets , 'series 1']
end
 
if typeof(grocer_ts) ~= 'ts' then
   error('entry number 1 is not a timeseries')
end
 
grocer_listts=list(grocer_ts)
grocer_fq=grocer_ts('freq')
grocer_dat1=grocer_ts('dates')
grocer_begdat=grocer_dat1(1)
grocer_enddat=grocer_dat1(size(grocer_dat1,1))
 
for grocer_i=2:grocer_nargin
   grocer_argnames=%f
   if typeof(varargin(grocer_i)) == 'string' then
      if part(varargin(grocer_i),1:5) == 'names' then
         grocer_names=str2vec(varargin(grocer_i))
         grocer_argnames=%t
      else
         grocer_ts=evstr(varargin(grocer_i))
         grocer_namets=[grocer_namets varargin(grocer_i)]
      end
   else
      grocer_ts=varargin(grocer_i)
      grocer_namets=[grocer_namets , 'series '+string(grocer_i)]
   end
   if ~grocer_argnames then
      if typeof(grocer_ts) ~= 'ts' then
         error('entry number '+string(grocer_i)+' is not a timeseries')
      end
      grocer_fqi=grocer_ts('freq')
      if cumprod(grocer_fqi) ~= cumprod(grocer_fq) | grocer_fqi(1) ~= grocer_fq(1) then
         error('timeseries have not the same frequency')
      end
      grocer_listts($+1)=grocer_ts
      grocer_dat1=grocer_ts('dates')
      grocer_begdat=min(grocer_begdat,grocer_dat1(1))
      grocer_enddat=max(grocer_enddat,grocer_dat1(size(grocer_dat1,1)))
   end
end
 
if exists('grocer_names','local') then
   grocer_namets=['dates' grocer_names']
   grocer_nargin=grocer_nargin-1
end
 
nbtab=floor((grocer_nargin+3)/4)
tab=1
while tab <= nbtab then
   nbseries=min(4,grocer_nargin-4*(tab-1))
   ts2print=emptystr(grocer_enddat-grocer_begdat+2,nbseries+1)
   ts2print(1,:)=[grocer_namets(1) grocer_namets(4*tab-2:4*tab+nbseries-3)]
   ts2print(2:grocer_enddat-grocer_begdat+2,1)=num2date([grocer_begdat:grocer_enddat]',grocer_fq)
   for i=1:nbseries
      ts=grocer_listts(i+4*(tab-1))
      s=string(series(ts))
      s(isnan(series(ts)))='Nan'
      d=ts('dates')
      ts2print(d(1)-grocer_begdat+2:d(1)-grocer_begdat+1+size(d,1),i+1)=s
   end
   printmat(ts2print,%io(2))
   printsep(%io(2))
   tab=tab+1
end
 
endfunction
 
