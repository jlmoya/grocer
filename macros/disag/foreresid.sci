function retal = foreresid(retal)
 
// PURPOSE: with Insee's disaggregation forecast the low
// frequency residuals over the years where the low frequency
// variable is not available
// ------------------------------------------------------------
// INPUT:
// * retal = an Insee's disaggregation result tlist
// ------------------------------------------------------------
// OUTPUT:
// * retal = an Insee's disaggregation result tlist
// ------------------------------------------------------------
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
n = size(retal('hf x'),1)
N = size(retal('lf x'),1)
u = retal('lf resid')
rho = retal('rho')
 
// recherche du nombre de prévisions à faire
 
nprev=ceil((n-retal('freq ratio')*N+1)/retal('freq ratio'))
 
// forecasting residuals
if nprev then
   u_report = [u ; u(N)*(rho^[1:nprev])']
end
 
retal(1)($+1) = 'forecasted lf resid'
retal('forecasted lf resid') = u_report
retal = lissquadra(retal)
retal('hf resid')  =retal('hf resid')(1:n)
 
 
endfunction
 
