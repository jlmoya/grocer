function grocer_vecout=ts2vec(grocer_ts,varargin)
 
// PURPOSE: transforms the values of a timeseries into the
// vector of its value
// ------------------------------------------------------------
// INPUT:
// * ts = a time series (between quotes or not)
// * varargin =
//   - an even number of date strings corresponding to the
//   bounds over which the values are taken
//   - a (1 x 2*n) vector of date strings corresponding to the
//   bounds over which the values are taken
//   (optional : if not provided, the function operates over
//   the whole time range of the series)
// ------------------------------------------------------------
// OUTPUT:
// * vecout = (N x 1) vector
// ------------------------------------------------------------
// NOTES:
// * used by ols(), automatic()
// * the list of error checks could be extended...
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_nargout,grocer_nargin] = argn(0)
 
grocer_err=' '
if typeof(grocer_ts) == 'string' then
   grocer_err=' '+grocer_ts+' '
   execstr('grocer_ts='+grocer_ts)
end
 
type1=typeof(grocer_ts)
if type1 ~= 'ts' then
   error('series'+grocer_err+'has bad type ('+type1+' instead of ts)')
end
 
grocer_s=series(grocer_ts)
if grocer_nargin == 1 then
// the user has provided no bounds
   if or(isnan(grocer_s)) then
      error('series'+grocer_err+'+contains Nan in the range you have specified')
   else
      grocer_vecout=grocer_s
   end
else
   grocer_vecout=[]
   grocer_dat=grocer_ts('dates')
   grocer_fq=grocer_ts('freq')
   grocer_debts=grocer_dat(1)
   grocer_endts=grocer_dat(size(grocer_dat,1))
   grocer_date2=grocer_debts
   if size(varargin(1),'*') == 1 then
   // the first argument is a string, not a vector
      if modulo(grocer_nargin,2) == 0 then
         error('number of dates is not even')
      end
      for grocer_i=1:(grocer_nargin-1)/2
         grocer_date1=date2num(varargin(2*grocer_i-1))
         if grocer_date1 < grocer_debts | ...
         grocer_endts < grocer_date1 then
            error(num2date(grocer_date1,grocer_fq)+' is not in the range of ts '+grocer_err)
         end
         if grocer_date1 < grocer_date2 then
            error('dates are not in increasing order')
         end
         grocer_date2=date2num(varargin(2*grocer_i))
         if grocer_date2 < grocer_date1 then
            error('dates are not in increasing order')
         end
         if grocer_date2 < grocer_debts | ...
         grocer_endts < grocer_date2 then
            error(num2date(grocer_date2,grocer_fq)+' is not in the range of series '+grocer_err)
         end
         grocer_vecout=[grocer_vecout ; grocer_s(1+...
         grocer_date1-grocer_debts:1+grocer_date2-grocer_debts)]
      end
   else
      grocer_x=vec2col(varargin(1))
      if grocer_nargin > 2 then
         error('if the bounds are given in a matrix, then you cannot give more than two arguments to ts2vec')
      end
      if modulo(size(grocer_x,1),2) ~= 0 then
         error('number of dates is not even')
      end
      for grocer_i=1:size(grocer_x,1)/2
         grocer_date1=date2num(grocer_x(2*grocer_i-1,1))
         if grocer_date1 < grocer_debts | ...
         grocer_endts < grocer_date1 then
            error(num2date(grocer_date1,grocer_fq)+' is not in the range of the series')
         end
         if grocer_date1 < grocer_date2 then
            error('dates are not in increasing order')
         end
         grocer_date2=date2num(grocer_x(2*grocer_i,1))
         if grocer_date2 < grocer_date1 then
            error('dates are not in increasing order')
         end
         if grocer_date2 < grocer_debts | ...
         grocer_endts < grocer_date2 then
            error(num2date(grocer_date2,grocer_fq)+' is not in the range of the series')
         end
         grocer_vecout=[grocer_vecout ; grocer_s(1+grocer_date1-...
         grocer_debts:1+grocer_date2-grocer_debts)]
      end
   end
end
endfunction
