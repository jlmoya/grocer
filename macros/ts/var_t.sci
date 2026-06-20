function [ts]=var_t(varargin)
 
// PURPOSE: compute the timeseries whose values are, for each
// date, the variance at this date of the values of n time
// series
// ------------------------------------------------------------
// INPUT:
// * ts1,...,tsn time series
// ------------------------------------------------------------
// OUTPUT:
// * ts = the time series whose values are, for each date the
// variance at this date of the values of the n time series
// ------------------------------------------------------------
// NOTES: doubtful usefulness, but exists !
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
nargin=length(varargin)
 
m=ones(d1l-d1f+1,nargin)
 
dl=ones(nargin,1)
du=ones(nargin,1)
for i=2:nargin
   d=varargin(i)('dates')
   dl(i)=d(1)
   du(i)=d(size(d,1))
end
dlm=max(dl)
dlu=min(du)
 
for i=1:nargin
   s=varargin(i)('series')
   d2=varargin(i)('dates')
   d2f=d2(1)
   d2l=d2(size(d2,1))
   m(:,i)=s(d1f-d2f+1:d1l-d2f+1)
end
 
vecout=ones(dlu-dlm+1,1)
mdm=ones(1,nargin)
for i=1:d1l-d1f+1
   maux=m(i,:)
   mdm=maux-mean0(maux)
   vecout(i)=sum(mdm .^2/(nargin-1))
end
 
ts=tlist(['ts';'freq';'dates';'series'],...
         f1,[dlmf:d1l]',vecout,'')
 
endfunction
