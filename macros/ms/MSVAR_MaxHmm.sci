function [paramfin,likl1,grad] = MSVAR_MaxHmm(param,grocer_optfunc,grocer_opt_optim)
 
// PURPOSE: peforms the optimisation and returns parameters,
// loglikelihood, gradient
// ------------------------------------------------------------
// INPUT:
// * param = a (n x1) vector of starting values for the
//   parameters to estimate
// ------------------------------------------------------------
// OUTPUT:
// * paramfin = a (n x1) vector of estimated parameters
// * likl1 = the log-liklihood at estimated parameters
// * grad = the gradient at estimated parameters
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.  All rights reserved
 
select grocer_optfunc
case 'optim'
   execstr('[likl1,paramfin,grad] = optim(MSVAR_likfcn'+grocer_opt_optim('optim ineq')+',param'+grocer_opt_optim('optim')+')');
 
case 'optimg'
    if ~isempty(grocer_opt_optim('optim ineq')) then
       warning('inequality constraints ignored: enter option ''opt_func=optim'' if you want them to prevail')
    end
   [likl1,paramfin,grad] = optimg(MSVAR_Filt,MSVAR_likfcn,param,grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
else
   error('not an available optimization function: '+grocer_optfun)
end
 
likl1=-likl1
grad=-grad
 
endfunction
