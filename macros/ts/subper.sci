function ts=subper(ts,varargin)
 
// PURPOSE: take a timeseries over a subperiod
// ------------------------------------------------------------
// INPUT:
// * ts = a timeseries or a tsmat
// * varargin =
//   - a string
//   - a (1 x 2) vector of dates strings
//   - or 2 dates strings, representing the begining and the
//     end of the subperiod
// ------------------------------------------------------------
// OUTPUT:
// ts = the time series or tsmat over the subperiod
// ------------------------------------------------------------
// Copyright: Eric Dubois/ Emmanuel Michaux 2002-2008
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
 
if nargin ~= 1 then
   dateout=[]
   vecout=[]
   s=series(ts)
   dat=datets(ts)
   fq=ts('freq')
   debts=dat(1)
   endts=dat(size(dat,1))
   date2=debts
 
   if size(varargin(1),1) == 1 then
      date1=date2num(varargin(1))
      if date1 < debts | endts < date1 then
         error(varargin(1)+' is not in the range of the series')
      end
      if nargin == 2 then
         date2=date1
      else
         date2=date2num(varargin(2))
         if date1 > date2 then
            error('dates are not in increasing order')
         end
         if date2 < debts | endts < date2 then
            error(varargin(2)+' is not in the range of the series')
         end
      end
      dateout=[dateout ; dat(1+date1-debts:1+date2-debts)]
      vecout=[vecout ; s(1+date1-debts:1+date2-debts,:)]
 
   else
      x=varargin(1)
      if size(x,1) ~= 2 then
         error('number of dates is not equal to 2 in subper')
      end
      date1=date2num(x(1,1))
      if date1 < debts | endts < date1 then
         error(varargin(1)+' is not in the range of the series')
      end
      if date1 < date2 then
         error('dates are not in increasing order')
      end
      date2=date2num(x(2,1))
      if date1 > date2 then
         error('dates are not in increasing order')
      end
      if date2 < debts | endts < date2 then
         error(varargin(2)+' is not in the range of the series')
      end
      dateout=[dateout ; dat(1+date1-debts:1+date2-debts)]
      vecout=[vecout ; s(1+date1-debts:1+date2-debts,:)]
   end
   ts('series')=vecout
   ts('dates')=dateout
end
 
endfunction
