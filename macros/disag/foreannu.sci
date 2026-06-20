function retal = foreannu(retal)
 
// PURPOSE: with Insee's disaggregation forecast the low
// frequency endoegnous variable over the years where the low
//  frequency variable is not available
// ------------------------------------------------------------
// INPUT:
// * retal = an Insee's disaggregation result tlist
// ------------------------------------------------------------
// OUTPUT:
// * retal = an Insee's disaggregation result tlist
// ------------------------------------------------------------
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
retal(1)($+1) = 'lf yhat'
retal(1)($+1) = 'lf resid'
 
retal('lf yhat') = retal('aug lf x')*retal('beta') ;
retal('lf resid') = retal('lf y') - retal('lf yhat') ;
 
endfunction
