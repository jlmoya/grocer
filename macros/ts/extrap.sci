function tsout=extrap(varargin)
 
// PURPOSE: extrapolate the first time series by the growth
// rate of the following ones over the future of each preceding
// time series
// ------------------------------------------------------------
// INPUT:
// * ts1,...,tsn time series
// ------------------------------------------------------------
// OUTPUT:
// * tsout = a time series
// ------------------------------------------------------------
// NOTE: can probably be made more efficient
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
nargin=length(varargin)
for i=1:nargin
   if typeof(varargin(i)) ~= 'ts' then
      error("arg number "+string(j)+" is not a timeseries")
   end
end
 
tsout=varargin(1)
dateout=datets(tsout)
serieout=series(tsout)
begdate0=dateout(1)
enddate0=dateout(size(dateout,1))
fq=freqts(varargin(1))
 
for i=2:nargin
   tsi=varargin(i)
   fqi=tsi('freq')
   // test that the frequencies are the same taking into account
   // the possibility that some frequencies can be written as a
   //  number or as a 1x2 vector [fq, 1]
   if cumprod(fq) ~= cumprod(fqi) | fq(1) ~= fqi(1) then
      error('timeseries have not the same frequency')
   end
   datei=datets(tsi)
   seriei=series(tsi)
   nout=size(dateout,1)
   ni=size(datei,1)
   if datei(1) > dateout(nout) | datei(ni) <= dateout(nout) then
      error('time series are not overlapping in extrap')
   else
      indi0=dateout(nout)-datei(1)+1
      dateout=[dateout ; datei(indi0+1:ni) ]
      serieout=[serieout ; seriei(indi0+1:ni)/seriei(indi0)*serieout(nout)]
   end
end
tsout('dates')=dateout
tsout('series')=serieout
tsout(5)=' '
 
endfunction
