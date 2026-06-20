function []=pltfac_kalm(res,varargin)
 
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
 
// load the parameters that determines the fonts
load(GROCERDIR+'/param/param_g.dat')
 
nvar=res('ny')
nobs=res('nobs')
 
nargin=length(varargin)
for i=1:nargin
   if part(varargin(i),1:4) == 'stud' then
      stud=%t
   else
      error('not an available option: '+varargin(i))
   end
end
 
if stud
   resid=res('stud fac')
   titl0='estimated standardized dynamic factor'
else
   resid=res('fac')
   titl0='estimated dynamic factor'
end
 
scf()
if size(resid,2) ==1 then
   if res('prests') then
      boundsres=res('bounds')
      dn=date2num_m(boundsres)
      dscale=[]
      for i=1:size(dn,1)/2
         dscale=[dscale dn(2*i-1):dn(2*i)]
      end
      xscaleres=num2date(dscale,date2fq(boundsres(1)))
   else
      xscaleres=string(1:size(resid,1))
   end
   pltseries0(resid,0,titl0,xscaleres,-1)
 
else
   titl0=titl0+'s'
   if res('prests') then
      boundsres=res('bounds')
      dn=date2num_m(boundsres)
      dscale=[]
      for i=1:size(dn,1)/2
         dscale=[dscale dn(2*i-1):dn(2*i)]
      end
      xscaleres=num2date(dscale,date2fq(boundsres(1)))
   else
      xscaleres=string(1:size(resid,1))
   end
   pltseries0(resid,0,titl0,xscaleres,-1,'leg='+joinstr('factor # ',string(1:size(resid,2)),';'))
end
 
endfunction
