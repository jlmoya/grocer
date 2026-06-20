function []=pltuniv(res,options,varargin)
 
// PURPOSE: plots the results of least-squares regression
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * options = 'res', 'fitted', or 'all' according to the
//   results that the user wants to graph (default: all)
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
 
win=1
resid=%f
fitted=%f
if nargin == 1 then
   resid=%t
   fitted=%t
else
   select options
   case 'res'
      resid=%t
   case 'fitted'
      fitted=%t
   case 'all'
      resid=%t
      fitted=%t
   else
      error('invalid option in pltuniv')
   end
end
 
nargin=length(varargin)
for i=nargin:-1:1
    argi=varargin(i)
    if typeof(argi) == 'string' then
       if part(strsubst(argi,' ',''),1:4) == 'win=' then
          execstr(argi)
          varargin(i)=[]
       end
    end
end
namex=res('namex')
nobs=res('nobs')
residual=res('resid')
y0=[res('y') res('yhat')]
namexp=namex(1)
for i=2:size(namex,1)
   namexp=namexp+', '+namex(i)
end
 
// if there are ts in the regression, set the values of the x
// axis:
if res('prests') then
 
   dropna=res('dropna')
   bo=res('bounds')
 
   if dropna then
   // estimation have been performed with the option dropna,
   // so drop na from the bounds
       dat1=date2num(bo(1))
       [datn,fq]=date2num_fq(bo($))
       xscale0=num2date([dat1:datn],fq)
       xscale0=xscale0(res('nonna'))
       residp=residual
       y=y0
   else
      [mat,xscale0]=data2graph([y0 residual],bo)
      residp=mat(:,3)
      y=mat(:,1:2)
   end
else
   residp=residual
   y=y0
   xscale0 = [1:nobs]
end
 
if resid then
   tit='residuals of the '+res('meth')+' regression of '...
        +res('namey')+' on '+namexp
   pltseries0(residp,0,tit,string(xscale0),win,'x0(1)=0','styleg=4','bars=1','color=5')
end
 
if fitted then
// open a new window:
   tit='observed and fitted values of the '+res('meth')+' regression of '...
        +res('namey')+' on '+namexp
   pltseries0(y,[],tit,string(xscale0),win+1,'leg=[observed;fitted]','styleg=4',varargin(:))
end
 
endfunction
