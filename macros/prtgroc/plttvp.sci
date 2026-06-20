function []=plttvp(res)
 
// PURPOSE: plots the coefficients of a time-varying regression
// ------------------------------------------------------------
// INPUT:
// res = the results typed list of a univariate regression
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are plotted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
betas=res('betas')
// if there are ts in the regression, set the values of the x
// axis:
if res('prests') then
   bo=res('bounds')
   for i=1:size(bo,1)/2
      d1=date2num(bo(i*2-1))
      xscale0=num2date([d1:d1+diff_date(bo(2*i),...
              bo(2*i-1))],date2fq(bo(i*2-1)))
   end
else
   xscale0 = [1:res('nobs')]
end
 
 
for i=1:res('nvar')
   vari=betas(:,i)
   t='time varying coefficient for '+res('namex')(i)
   pltseries0(vari,[],t,string(xscale0),i)
end
endfunction
