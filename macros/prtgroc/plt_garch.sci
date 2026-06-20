function plt_garch(res)
 
// PURPOSE: plots the variance of a garch estimation
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a garch regression
// * typ_prob = 'smoothed' or 'filtered'
// * nmax = maximum numbers of graphs per window (if not
//   provided, then the numbers ofgraphs per window is equal to
//   the number of states
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
 
sigt=res('sigt')
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
   xscale0 =string([1:T])
end
 
scf()
 
pltseries0(sigt,0,'estimated variance of residuals',xscale0,-1)
 
endfunction
