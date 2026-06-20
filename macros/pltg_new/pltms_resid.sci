function []=pltms_resid(res,nmax,type_resid)
 
// PURPOSE: plots the states probabilities from a Markov
// Swiching (ms) regression
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a ms regression
// * nmax = maximum numbers of graphs per window (if not
//   provided, then the numbers of graphs per window is equal
//   to the number of endogenous variables)
// * type_resid = the type of residuals, smoothed or filtered,
//   that are plotted (if not provided, then smoothed)
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006-2011
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
nendo=res('nendo')
namey=res('namey')
if nargin == 1 then
   nmax=nendo
   type_resid='smoothed'
elseif nargin == 2 then
   if isempty(nmax) then
      nmax=nendo
   end
   type_resid='smoothed'
end
resid=res(stripblanks(type_resid)+' resid')
 
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
      y=resid(:,j)
      tit=type_resid+' residuals for endogenous '+namey(j)
      [scale,ymin,ymax]=yscale(y,%f)
      xsetech([0 (k-1)/nmax 1 1/nmax],[0,ymin,T,ymax])
      pltseries0(y,0,tit,string(xscale0),-1,'bars=1','color=5')
   end
   n0=n0+nmax
   n1=min(n1+nmax,nendo)
end
 
endfunction
