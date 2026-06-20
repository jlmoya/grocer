function [yt]=transdif(y,lambda,d,ds,s)
 
// Differences and performs the Box-Cox transformation for a series set.
// ------------------------------------------------------------
// INPUT:
// * y = (nxk) data matrix.
// * lambda = a scalar, parameter of the Box-Cox transformation
// * d = a scalar, the number of regular differences (1-B)^d
// * ds = (Sx1) matrix containing the number of seasonal differences
// * s      > (rx1) matrix containing the seasonal periods.
// ------------------------------------------------------------
// OUTPUT:
// * yt =(n-d-sum(ds*s))xk matrix of transformed data.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin==1 then
  yt = y;
  return
end
if nargin<5 then
  s = 1;
  if nargin<4 then
    ds = 0;
    ds_t = ds;
    if nargin<3 then
      d = 0;
    end
  end
end
s = fix(s(:));
ds = fix(ds(:));
 
if or(ds>0) then
  if or(s<1)|or(ds<=0) then
    error('Inconsistent input arguments');
  end
  ds_t = sum(ds .* s);
else
  ds = 0;
  ds_t = ds;
  s = 1;
end
 
[n,m] = size(y);
if n<(d+ds_t+1) then
  error('Should be more than 1 observation');
end
yt = zeros(n-d-ds_t,m);
 
rpol = 1;
spol = 1;
if d then
  regpol = [1,-1];
  for j = 1:d
    rpol = convol(regpol,rpol);
  end
end
if ds then
  for j = 1:size(ds,1)
    seaspol = [1,zeros(1,s(j)-1),-1];
    for k = 1:ds(j)
      spol = convol(seaspol,spol);
    end
  end
end
difp = convol(rpol,spol);
 
if lambda~=1 then
  miny = min(y,'r');
  ndx = miny<=0;
  if or(ndx) then
    y(:,ndx) = y(:,ndx)+ones(n,1)*abs(miny(ndx))+0.00001;
  end
  if lambda==0 then
    yt1 = log(y);
  else
    yt1 = (y.^lambda-1)/lambda;
  end
else
  yt1 = y;
end
 
if d+ds_t then
  diford = matrix(find(difp~=0),1,-1);
  for i = 1:m
    [yl,ys] = lagser(yt1(:,i),diford-1);
    yt(:,i) = yl*difp(diford)';
  end
else
  yt = yt1;
end
 
endfunction
 
