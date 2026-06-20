function [bet,llike]=olsar1_0(y,x,grocer_optfunc,grocer_opt_optim)
 
// PURPOSE: computes maximum likelihood ols regression for AR1
// errors
// ------------------------------------------------------------
// INPUT:
// * y = a (T x 1) real vetor
// * x = a (T x k) real matrix
// * grocer_optfunc =  the name of the optimisation function
//   (optim or optimg)
// * grocer_opt_optim = a tlist, collecting the options to
//   the optimisation function
//---------------------------------------------------
// * bet= parameters at solution (rho included)
// * llike = log-likelihood at solution
// --------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nobs,nvar] = size(x);
 
// use cochrane-orcutt estimates as initial values
reso = olsc0(y,x,'noprint');
parm = [ reso('rho'); reso('beta')];
 
deff('[f,g,ind]=cost(parm,ind)',..
     ['f=ar1_like(parm,y,x)';...
     'g=ar1_grad(parm,y,x)'])
 
select grocer_optfunc
case 'optim' then
   execstr('[like,bet,grad] = optim(cost'...
   +grocer_opt_optim('optim ineq')+',parm'+grocer_opt_optim('optim')+')')
 
case 'optimg' then
   [like,bet,grad] = optimg(ar1_like,cost,parm,...
       grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
else
   error('not an available optimisation function'+grocer_optfunc)
end
llike = -like+nobs/2*(log(nobs)-log(2*%pi))
 
endfunction
