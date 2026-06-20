function pltdma_expnbvar(res)
 
// PURPOSE: plots the number of expected variables over time
// ------------------------------------------------------------
// INPUT:
// * res = the results typed tlist from a DMA estimation
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are plotted on a news graphing window
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
 
expnbvar=res('exp # of models')
 
scf()
if res('prests') then
   boundsres=res('bounds')
   dn=date2num_m(boundsres)
   dscale=[]
   for i=1:size(dn,1)/2
      dscale=[dscale dn(2*i-1):dn(2*i)]
   end
   xscaleres=num2date(dscale,date2fq(boundsres(1)))
else
   xscaleres=string(1:size(res('y'),1))
end
pltseries0(expnbvar,[],'expected number of predictors',xscaleres,-1)
 
endfunction
