function []=pltms_yyhat(res,nmax,type_yhat)
 
// PURPOSE: plots the original and adjusted endogenous
// variables from a Markov Swiching (ms) regression
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a ms regression
// * nmax = maximum numbers of graphs per window (if not
//   provided, then the numbers of graphs per window is equal
//   to the number of endogenous variables)
// * type_yhat = the type of yhat, smoothed or filtered,
//   that are plotted (if not provided, then smoothed)
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006-2011
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
nendo=res('nendo')
y=res('y')
yhat=res('yhat')
namey=res('namey')
if nargin == 1 then
   nmax=nendo
elseif nargin == 2 then
   if isempty(nmax) then
      nmax=nendo
   end
   type_yhat='smoothed'
end
 
if nmax > nendo then
   nmax=nendo
end
 
vers=convstr(getversion())
shortvers=part(vers,1:10)
if vers == 'scilab-3.0' then
   nmax=1
end
 
T=res('nobs')
 
// if there are ts in the regression, set the values of the x
// axis:
if res('prests') then
   bo=res('bounds')
   xscale0=[]
   nobsi=diff_date(bo(2),bo(1))+1
   d1=date2num(bo(1))
   fq=date2fq(bo(1))
   xscale0=num2date([d1:d1+nobsi-1],fq)
else
   xscale0 = [1:T]
end
 
n0=1
n1=nmax
for i=1:ceil(nendo/nmax)
   scf()
   k=0
   for j=n0:n1
      k=k+1
      yn=[y(:,j) yhat(:,j)]
      tit='endogenous '+namey(j)+': observed and fitted'
      [scale,ymin,ymax]=yscale(yn,%f)
      xsetech([0 (k-1)/nmax 1 1/nmax],[0,ymin,T,ymax])
      pltseries0(yn,0,tit,string(xscale0),-1,'thickn=[1 2]','leg=[observed;fitted]','styleg=7')
   end
   n0=n0+nmax
   n1=min(n1+nmax,nendo)
end
 
endfunction
