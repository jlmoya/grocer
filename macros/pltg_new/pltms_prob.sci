function []=pltms_prob(res,typ_prob,nmax)
 
// PURPOSE: plots the states probabilities from a Markov
// Swiching (ms) regression
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a ms regression
// * typ_prob = 'smoothed' or 'filtered'
// * nmax = maximum numbers of graphs per window (if not
//   provided, then the numbers ofgraphs per window is equal to
//   the number of states
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
nb_states=res('nb_states')
execstr('probas=res('''+typ_prob+' probs'')')
if nargin == 2 then
   nmax=nb_states
end
 
if nmax > nb_states then
   nmax=nb_states
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
for i=1:ceil(nb_states/nmax)
   scf()
   k=0
   for j=n0:n1
      k=k+1
      y=probas(:,j)
      tit=typ_prob+' probabilities in regime '+string(j)
 
      xsetech([0 (k-1)/nmax 1 1/nmax],[0,0,T,1])
      pltseries0(y,0,tit,string(xscale0),-1,'miny1=0','maxy1=1')
   end
   n0=n0+nmax
   n1=min(n1+nmax,nb_states)
end
 
endfunction
