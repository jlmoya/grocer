function []=plt_dfb(res)
 
// PURPOSE: plots the dfbetas coefficients of an ols regression
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of function dfbeta
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2015
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
// load the parameters that determines the fonts
load(GROCERDIR+'/param/param_g.dat')
 
nvar=res('nvar')
nobs=res('nobs')
dfbet=res('dfbeta')
 
// if there are ts in the regression, set the values of the x
// axis:
if res('prests') then
   bounds=res('bounds')
   for i=1:size(bounds,1)/2
      d1=date2num(bounds(i*2-1))
      xscale0=string(num2date([d1:d1+diff_date(bounds(2*i),...
              bounds(2*i-1))]',date2fq(bounds(i*2-1))))
   end
else
   xscale0 = string([1:nobs]')
end
 
nrows = ceil(sqrt(nvar))
ncols = ceil(nvar/nrows)
ref_nbinter=ref_nbinter/ncols
 
scf()
for i=1:nvar
   subplot(nrows,ncols,i)	
   plot2d([1:nobs],dfbet(:,i),style=1,axesflag=0)
   [y0,scale]=drawy(dfbet(:,i),font_axis,0,1,'l',%f)
   drawx(xscale0,1,ref_nbinter,font_axis,y0,0)
  	xtitle('dfbetas for variable '+res('namex')(i))
end
endfunction
