function [y,res]=bfl(nameY,ta,d,s)
 
// PURPOSE: Temporal disaggregation using the Boot-Feibes-Lisman method
// -----------------------------------------------------------------------
// INPUT:
// * nameY = a ts or a Nx1 vector of low frequency data or a string
// representing the name of a vector or a ts
// * ta = type of disaggregation
//   - ta=-1 ---> sum (flow)
//   - ta=0 ---> average (index)
//   - ta=i ---> i th element (stock) ---> interpolation
// * d = objective function to be minimized: volatility of ...
//   - d=0 ---> levels
//   - d=1 ---> first differences
//   - d=2 ---> second differences
// * s = number of high frequency data points for each low frequency data point
//   - s= 4 ---> annual to quarterly
//   - s=12 ---> annual to monthly
//   - s= 3 ---> quarterly to monthly
// -----------------------------------------------------------------------
// OUTPUT:
// * y = High frequency estimate
// * res = a results tlist with:
//   - res('meth')         = 'Boot-Feibes-Lisman'
//   - res('nobs_lf')      = Number of low frequency data
//   - res('aggreg_mode')  = Type of disaggregation
//   - res('s')            = Frequency conversion
//   - res('diff')         = Degree of differencing
//   - res('y_lf')         = Low frequency data
//   - res('y')            = High frequency estimate
//   - res('namey')        = name of the low frequency data
// -----------------------------------------------------------------------
// REFERENCE: Boot, J.C.G., Feibes, W. y Lisman, J.H.C. (1967)
// """"Further methods of derivation of quarterly figures from annual data"""",
// Applied Statistics, vol. 16, n. 1, p. 65-75.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from a Matlab program written
// by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
[Y,nameY,grocer_prests,grocer_boundsvarb]=explone(nameY,[],'endogenous')
 
[y,res]=bfl1(Y,ta,d,s)
 
res(1)($+1)='namey'
res($+1)=nameY
 
if grocer_prests then
   datnew=datelf2hf0(grocer_boundsvarb(1),s,1)
   y=reshape(y,datnew)
   res('y')=y
end
 
endfunction
