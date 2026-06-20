function [ts]=reshape(mat,datin,varargin)
 
// PURPOSE: create a time series from a vector of values and a
// beginning date
// ------------------------------------------------------------
// INPUT:
// * mat = a (1 x nobs) or (nobs x 1) vector
// * datin = a date string
// * varargin = - 'w' if the time series is weekly (optional)
//             - a string: a comment added to describe the ts
// ------------------------------------------------------------
// OUTPUT:
// * ts = the corresponding time series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
 
[nr,nc]=size(mat)
comment=' '
 
if (nr-1)*(nc-1) then
// both nr ~= 1 and nc ~= 1: this is a tsmat
   nargin=length(varargin)
   names='series'+string(1:nc)
   for i=nargin:-1:1
      if varargin(i) ~= 'w' then
         names=varargin(i)
         varargin(i)= null()
      end
   end
   [datfirst,fq]=date2num_fq(datin,varargin(:))
   dat=datfirst+[0:(nr-1)]*fq(2)	
   ts=tlist(['tsmat';'freq';'dates';'series';'names'],fq,dat',mat,names(:))
 
else
 
   mat=mat(:)
   nargin=length(varargin)
   for i=nargin:-1:1
      if varargin(i) ~= 'w' then
         comment=varargin(i)
         varargin(i)=null()
      end
   end
   [datfirst,fq]=date2num_fq(datin,varargin(:))
   n=max(nr,nc)
   dat=datfirst+[0:(n-1)]*fq(2)	
   ts=tlist(['ts';'freq';'dates';'series';'comment'],fq,dat',mat,comment)
 
end
 
endfunction
