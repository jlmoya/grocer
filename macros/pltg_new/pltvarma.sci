function []=pltvarma(res,varargin)
 
// PURPOSE: plots the residuals of an ARMA estimation
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a varma regression
// * varargin = options that can be:
//   - 'stud' if the user wants to graph standardized residuals
//   - 'onegraph' if the user wants to plot one residual per
//     graphic window (if there are several endogenous
//     variables)
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
global GROCERDIR ;
 
[nargout,nargin]=argn(0)
stud=%f
onegraph=%t
 
// load the parameters that determines the fonts
load(GROCERDIR+'/param/param_g.dat')
 
nvar=res('nendo')
nobs=res('nobs')
prests=res('prests')
 
nargin=length(varargin)
for i=1:nargin
   if part(varargin(i),1:4) == 'stud' then
      stud=%t
   elseif part(varargin(i),1:8) == 'onegraph' then
      execstr('onegraph='+part(varargin(i),strindex(varargin(i),'=')+1:length(varargin(i))))
   else
      error('not an available option: '+varargin(i))
   end
end
 
if stud
   resid=res('std resid')
   titl0='standardized varma residuals for variable '
else
   resid=res('resid')
   titl0='varma residuals for variable '
end
 
// if there are ts in the regression, set the values of the x
// axis:
if prests then
   bo=res('bounds')
   deb=1
   nobsi=diff_date(bo(2),bo(1))+1
   fin=deb+nobsi-1
   d1=date2num(bo(1))
   fq=date2fq(bo(1))
   xscale0=num2date([d1:d1+nobsi-1],fq)
else
   xscale0 = string([1:nobs])
end
 
if onegraph then
   nrows = ceil(sqrt(nvar))
   ncols = ceil(nvar/nrows)
   ref_nbinter=ref_nbinter/ncols
   scf()
   for i=1:nvar
      subplot(nrows,ncols,i)	
      plot2d([1:nobs],resid(:,i),style=1,axesflag=0)
      [y0,scale]=drawy(resid(:,i),font_axis,0,1,'l',%f)
      drawx(xscale0,1,ref_nbinter,font_axis,0,0)
  	   titl=titl0+res('namey')(i)
  	   xtitle(titl)
      f_title=max(1,5-floor(length(titl)*ncols/thresh))
 
      a = gca() ; // get the current axis
      tit = a.title ; // get the handle of the title
      tit.text = titl  // set the title
      tit.font_size = f_title ; // change the font_size
   end
end
 
for i=1:nvar
 
   resacf=acf1(resid(:,i),floor(nobs/4),0.05)
   resacf(1)($+1)='namey'
   resacf(1)($+1)='prests'
   resacf($+1)='residual of endogenous '+res('namey')(i)
   resacf($+1)=prests
   if prests then
      resacf(1)($+1)='bounds'
      resacf($+1)=bo
   end
   pltacf(resacf,'styleg=7')
 
   resacf=pacf1(resid(:,i),floor(nobs/4),0.05)
   resacf(1)($+1)='namey'
   resacf(1)($+1)='prests'
   resacf($+1)='residual of endogenous '+res('namey')(i)
   resacf($+1)=prests
   if prests then
      resacf(1)($+1)='bounds'
      resacf($+1)=bo
   end
   pltacf(resacf,'styleg=7')
 
end
 
endfunction
