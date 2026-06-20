function [res]=est_GL(res,mat_cal,puis,initparam,indrows,grocer_opt_optim,grocer_hdelta)
 
// PURPOSE: estimation of the Gregoir and Lenglart hmm model
// ------------------------------------------------------------
// INPUT:
// * res = a result tlist
// * mat_cal = a (T x k) data matrix
// * puis = a (k x 1) vector, the interval between non NA values
//   for each coded variable
// * nbqua = a (2 x 1) vector:
//           - nbqua(1) = # of quantiles used to divide the data
//           - nbqua(2) = useless (for the moment...)
// * nblatent = # of latent variables (1 or 2)
// * nbstates = # of latent states (if # of sates is 1)
// * nojump = a boolean indicating whether the latent state is
//            prevented from jumping from a state to non
//            adjacent states
// * initparam =
//   - 0 for the standard intial parameters
//   - 1 for a variant
//   - a (nvar x 1) vector of intial aprameters given by the
//     user
// * indrows = a (N x 1) vector of non NA indexes
// ------------------------------------------------------------
// OUTPUT:
// * res = a results tlist with:
//   - res('meth') = 'ms turning point'
//   - res('y') = original data
//   - res('nobs') = # of observations
//   - res('nvar') = # of variables
//   - res('coded y') = data transformed by the coding
//   - res('nb quantiles') = # of quantiles used by the coding
//    (if the kernel method has been used)
//   - res('nb latent') = # of latent state variable
//   - res('nb states') = # of states
//   - res('nojump') = a boolean indicating whether the latent
//     state is allowed to jump from a state to another non
//     contiguous one
//   - res('param') = vector of estimated parameters
//   - res('std') = vector of associated standard errors
//   - res('tstat') = vector of associated Steudent stats
//   - res('llike') = log-likelihood
//   - res('grad') = gradient at the solution
//   - res('first transition probabilities') = matrix of
//     transition probabilities for the first latent variable
//   - res('second transition probabilities') = matrix of
//     transition probabilities for the second latent variable
//   - res('conditional probabilities') = matrix of conditional
//     probabilities (if there is only 1 state latent variable)
//   - res('filtered probabilities') = matrix of filtered state
//     probabilities
//   - res('smoothed probabilities') = matrix of smoothed state
//     probabilities
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated from a Gauss programm by J. Bardaji and F. Tallet
 
// Starting values
 
nvar=res('nvar')
variante_inno=0
 
select initparam
case 0 then
   paramini=[1.5;-1;1.5;-1;1.5*ones((nbqua(1)-1)*nvar,1);-1*ones((nbqua(1)-1)*nvar,1)];
   if variante_inno==1 then
      paramini=[paramini;0*ones(nvar+1,1);0*ones(nvar+1,1)]
   end
case -1 then// grid on the PZ parameters  */
   paramini(3:4+2*nvar)=[0.5;-1;1*ones((nbqua(1)-1)*nvar,1);-0.5*ones((nbqua(1)-1)*nvar,1)];
else
   paramini=initparam
end
 
[PZ_tran_ini,PX_cond_ini,PZ_tilde,PW_tran]=Write_matrices_2latent(paramini);
 
write(%io(2),'      Entry parameters:','(a)')
disp(paramini')
write(%io(2),'      Transition matrix P(Zt;Zt-1) : ','(a)')
disp(PZ_tran_ini)
 
if variante_inno == 1 then
   write(%io(2),'      Second transition matrix P(Ztild;Ztild-1) : ','(a)')
   disp(PZ_tilde);
    write(%io(2),' ','(a)')
   write(%io(2),'      Third transition matrix P(W    ;W    -1) : ','(a)')
   disp(PW_tran);
end
 
write(%io(2),'      Conditional observation matrix P(Xq=i;Zt=j) : ','(a)')
disp(PX_cond_ini)
write(%io(2),' ','(a)')
write(%io(2),' ','(a)')
 
nbparam=size(paramini,1)
 
if isempty(grocer_opt_optim('optim ineq')) then
   grocer_opt_optim('optim ineq')=',''b'',-log(999)*ones(nbparam,1),log(999)*ones(nbparam,1),'
end
execstr('[minusllike,paramfin,grad]=optim(ms_quali_fcn2min'+...
grocer_opt_optim('optim ineq')+'paramini'+grocer_opt_optim('optim')+')')
 
param_c=find((paramfin+log(999)) == 0 | (paramfin-log(999)) == 0)
 
[PZ_tran,PX_cond,PZ_tilde,PW_tran]=Write_matrices_2latent(paramfin);
 
[P_smoothed,P_filtered]=ms_quali_smooth(mat_cal,paramfin)
 
[std,var]=se_param(paramfin,param_c,nvar,grocer_hdelta)
param=exp(paramfin) ./ (1+exp(paramfin))
 
res('param')=param
res('std')=std
res('llike')=-minusllike
res('grad')=-grad
res('first transition probabilities')=PZ_tilde
res('second transition probabilities')=PW_tran
res('conditional probabilities')=PX_cond
fp=res('filtered probabilities')
fp(indrows,:)=P_filtered'
res('filtered probabilities')=fp
sp=res('smoothed probabilities')
sp(indrows,:)=P_smoothed'
res('smoothed probabilities')=sp
res('filtered indicator')=(fp(:,3)+fp(:,4)-fp(:,1)-fp(:,2))
res('smoothed indicator')=(sp(:,3)+sp(:,4)-sp(:,1)-sp(:,2))
 
res('PZ_std')=[std(1:2)' ; std(1:2)']
res('PW_std')=[std(3:4)' ; std(3:4)']
PX_c_std=zeros(nvar*nbqua(1),nbstates)*%nan;
PX_c_std(2*[1:nvar]-1,1)=std(4+[1:nvar]);
PX_c_std(2*[1:nvar]-1,3)=std(4+nvar+[1:nvar]);
PX_c_std(2*[1:nvar],[1 3])=PX_c_std(2*[1:nvar]-1,[1 3])
 
res('PX_cond_std')=PX_c_std;
 
endfunction
 
