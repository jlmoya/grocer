function []=pltms_quali(res,indic)
 
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
 
if nargin == 1 then
   indic='filtered'
end
 
T=res('nobs')
 
// if there are ts in the regression, set the values of the x
// axis:
if res('prests') then
   boundsres=res('bounds')
   dn=date2num_m(boundsres)
   dscale=[]
   for i=1:size(dn,1)/2
      dscale=[dscale dn(2*i-1):dn(2*i)]
   end
   xscale0=num2date(dscale,date2fq(boundsres(1)))
else
   xscale0 = string([1:T])
end
 
scf()
execstr('y=res('''+indic+' indicator'')')
tit='turning point filtered indicator'
pltseries0(y,0,tit,xscale0,-1)
 
endfunction
