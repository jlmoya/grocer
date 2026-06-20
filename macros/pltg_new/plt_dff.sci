function []=plt_dff(res)
 
// PURPOSE: plots the dffits, studentized residuals and
// hat-matrix diagonal
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of function dfbeta
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2015
// http://grocer.toolbox.free.fr/grocer.html
 
nobs=res('nobs')
 
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
 
 
pltseries0(res('dffits'),0,'dffits',xscale0,[])
pltseries0(res('stud'),0,'studentized residuals',xscale0,[])
pltseries0(res('hatdi'),[],'hat-matrix diagonals',xscale0,[])
 
//pltseries0(y,y0,title,xscale0,wind,varargin)
endfunction
