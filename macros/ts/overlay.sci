function tsout=overlay(varargin)
 
// PURPOSE: The same as the portable troll function overlay
// Creates a timeseries by overlaying several timeseries
// ------------------------------------------------------------
// INPUT:
// * ts1,...,tsn time series
// ------------------------------------------------------------
// OUTPUT:
// * tsout = a timeseries whose periodicity is the periodicity
// of the first argument (other series with another periodicity
// are ignored) and  whose date range runs from the earliest
// startdate of any of the input series to the latest enddate
// of any of the series. For each date in the output series,
// OVERLAY searches the argument list from left to right
// looking for a non-NA value in the corresponding position of
// an input series, or an input argument which is a non-NA
// constant. The first such value found is placed in the output
// series in that position. If none is found, then an NA is
// placed in the output series.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
nargin=length(varargin)
for i=1:nargin
   if typeof(varargin(i)) ~= 'ts' then
      error("arg number "+string(i)+" is not a timeseries")
   end
end
 
tsout=varargin(1)
dateout=datets(tsout)
serieout=series(tsout)
begdate0=dateout(1)
enddate0=dateout(size(dateout,1))
fq=freqts(varargin(1))
 
for i=2:nargin
   fq2=freqts(varargin(i))
   if fq2 == fq then
      s=series(varargin(i))
      d=datets(varargin(i))
      begdate1=d(1)
      enddate1=d(size(d,1))
      begcom=max(begdate0,begdate1)
      endcom=min(enddate0,enddate1)
      if begcom <= endcom then
// series have a commun time span; replace Nan values in the
// original series by values of the new series
         s0com=serieout(begcom-begdate0+1:endcom-begdate0+1)
         scom=s(begcom-begdate1+1:endcom-begdate1+1)
         s0com(find(isnan(s0com)))=scom(find(isnan(s0com)))
         serieout=[serieout(1:begcom-begdate0);s(1:begcom-begdate1);s0com;...
                   serieout(endcom-begdate0+2:enddate0-begdate0+1);...
                   s(endcom-begdate1+2:enddate1-begdate1+1)]
      else
      // series have no commun date
         if endcom == enddate0 then
      // the new series begins after the end of the old ones
            serieout=[serieout;ones(begcom-endcom-1,1)*%nan;s]
         else
      // the new series ends before the beginning of the old ones
            serieout=[s;ones(begcom-endcom-1,1)*%nan;serieout]
         end
      end
   begdate0=min(begdate0,begdate1)
   enddate0=max(enddate0,enddate1)
   dateout=[begdate0:enddate0]'
   else
      warning("in overlay, series number "+string(i)+" has been ignored because of a bad frequency")
   end
end
tsout('series')=serieout
tsout('dates')=dateout
 
endfunction
