function [yl,ys]=lag(y,ll,val)
 
// PURPOSE: Generates lags and leads from a data matrix.
// ------------------------------------------------------------
// INPUT:
// * y = (nxm) matrix
// * ll= a (nx1) or (1xn) vector of lags (>0 lags, <0 leads)
// ------------------------------------------------------------
// OUTPUT:
// * yl = (n-ml)x(mxl) lagged and/or lead series,
//   where ml=maxlag+abs(maxlead).
// * ys = (n-ml)x(m) original series with the last ml
// observations supressed.
// ------------------------------------------------------------
// Copyright (c) Jaime Terceiro, 1997
// Eric Dubois 2003 for the scilab tanslation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
select nargin
case 1 then
   ll=1
   val=0
case 2 then
   val=0
end
 
[n,m] = size(y);
ll = gsort(fix(ll(:)),'g','i');
nl = size(ll,1);
if or(size(y,1)<=0) then
  error('Should be more than 1 observation');
end
if max(abs(ll))>=n then
  error('Invalid number of lags ');
end
if ll==[] then
  yl = [];
  ys = [];
  return
end
 
yl = val*zeros(n,m*nl);
for i = 1:nl
  l = abs(ll(i));
  ncol = (i-1)*m+1:i*m;
  if ll(i)>=0 then
    // LAG
    yl(l+1:n,ncol) = y(1:n-l,:);
  else
    // LEAD
    yl(1:n-l,ncol) = y(l+1:n,:);
  end
end
 
// Get only valid rows for ys and yl
if nargout==2 then
  minl = min(ll);
  maxl = max(ll);
  if minl>=0 then
    okr = maxl+1:n;
  elseif maxl<=0 then
    okr = 1:n-abs(minl);
  else
    okr = abs(maxl)+1:n+minl;
  end
  yl = yl(okr,:);
  ys = y(okr,:);
end
 
endfunction
 
