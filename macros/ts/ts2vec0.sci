function vecout=ts2vec0(ts,b)
 
// PURPOSE: transforms the values of a timeseries into the
// vector of its value
// ------------------------------------------------------------
// INPUT:
// * ts = a time series (between quotes or not)
// * b = a (1 x 2*n) vector of numerical representaion of dates
// ------------------------------------------------------------
// OUTPUT:
// * vecout = (N x 1) vector
// ------------------------------------------------------------
// NOTES:
// * used by ols(), automatic()
// * the list of error checks could be extended...
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2008
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
 
vecout=[]
dat=ts('dates')
fq=ts('freq')
s=ts('series')
debts=dat(1)
[dnum,dat_fq]=date2num_fq(b(1))
 
if cumprod(fq) ~= cumprod(dat_fq) | fq(1) ~= dat_fq(1) then
   error('frequency of time series are not the same as for the bounds')
end
 
if debts > b(1) then
   error('series start after the starting date of the bounds')
end
 
if dat($) < b($) then
   error('series ends before the end date of the bounds')
end
for i=1:size(b,1)/2
   vecout=[vecout ; s(1+b(2*i-1)-debts:1+b(2*i)-debts,:)]
end
 
endfunction
