function retal = agregx(retal,c,sratio)
 
// PURPOSE: function that transforms the high frequency
// matrix of exogenous variables into their low frequency
// aggregates
// ------------------------------------------------------------
// INPUT:
// * retal = an Insee's disaggregation result tlist
// * c = aggregation matrix
// * sratio = ratio of high frequency to low frequency
// ------------------------------------------------------------
// OUTPUT:
// * retal = an Insee's disaggregation result tlist
// ------------------------------------------------------------
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
n = retal('nobs')
hx_aug = retal('hf x')
N = size(hx,1)
 
if retal('trend') == 0 then
// model without constant
 
    lx = c*hx
 
elseif retal('trend') == 1 then
// Model in first difference with constant
   th=sratio*(sratio+1)/2+sratio^2*[1:n+1]
   tl=sratio+1:N+sratio
 
   lx = [c*hx th(:)]
   hx_aug = [hx_aug tl(:)]
 
else
// Model with an AR(1) on residuals with constant
 
    lx = [c*hx ones(n,1)]
    hx_aug = [hx_aug ones(N,1)/sratio ]
    // divide by s to obtain the high frequency constant
 
end
 
retal(1)($+1) = 'aug lf x'
retal(1)($+1) = 'aug hf x'
 
retal('aug lf x') = lx
retal('aug hf x') = hx_aug
 
endfunction
