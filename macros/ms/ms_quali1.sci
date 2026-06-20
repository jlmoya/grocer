function [res,ind]=ms_quali1(data,coding,nbqua,nblatent,initparam,nbstates,nojump,grocer_opt_optim,grocer_hdelta)
 
// PURPOSE: estimate a HMM turning point model
// ------------------------------------------------------------
// INPUT:
// * data = a (T x k) data matrix
// * coding = the way variables will be coded:
//            - 'KERN' = by quantiles estimated by the
//              Epanechnikov kernel method
//            - 'AR' = by the sign of innovation estimated from
//              an AR regression on the data (not yet
//              implemented)
//            - 'no' (or anything different from 'KERN' and
//              'AR') = raw data
// * nbqua = a (2 x 1 ) vector:
//           - nbqua(1) = # of quantiles used to divide the data
//           - nbqua(2) = useless (fro the moment...)
// * nblatent = # of latent variables (1 or 2)
// * initparam =
//   - 0 for the standard intial parameters
//   - 1 for a variant
//   - a (nvar x 1) vector of intial aprameters given by the
//     user
// * nbstates = # of latent states (only if # of latent state
//   variables is 1)
// * nojump = a boolean indicating whether the latent state is
//            prevented from jumping from a state to non
//            adjacent states (only if # of of latent state
//   variables is 1)
// ------------------------------------------------------------
// OUTPUT:
// * res = a results tlist with:
//   - res('meth') = 'ms turning point'
//   - res('y') = original data
//   - res('nobs') = # of observations
//   - res('nvar') = # of variables
//   - res('coded y') = data transformed by the coding
//   - res('nb_quantiles') = # of quantiles used by the coding
//    (if the kernel method has been used)
//   - res('nb_latent') = # of latent state variable
//   - res('nb_states') = # of states
//   - res('nojump') = a boolean indicating whether the latent
//     state is allowed to jump from a state to another non
//     contiguous one
//   - res('param') = vector of estimated parameters
//   - res('std') = vector of associated standard errors
//   - res('tstat') = vector of associated Steudent stats
//   - res('llike') = log-likelihood
//   - res('grad') = gradient at the solution
//   - res('transition probabilities') = matrix of transition
//     probabilities (if there is only 1 state latent variable)
//   - res('transition probabilities') = matrix of transition
//     probabilities (if there is only 1 state latent variable)
//   - res('first transition probabilities') = matrix of
//     transition probabilities for the first latent variable
//     (if there are 2 state latent variables)
//   - res('first transition probabilities') = matrix of
//     transition probabilities for the second latent variable
//     (if there are 2 state latent variables)
//   - res('conditional probabilities') = matrix of conditional
//     probabilities (if there is only 1 state latent variable)
//   - res('filtered probabilities') = matrix of filtered state
//     probabilities
//   - res('smoothed probabilities') = matrix of smoothed state
//     probabilities
//   - res('PZ_std') = matrix of standard errors for the
//     transition probabilities for the first latent variable
//   - res('PW_std') = matrix of standard errors for the
//     transition probabilities for the second latent variable
//   - res('PX_cond_std') = matrix of standard errors for the
//     latent variable
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adapted from a Gauss programm by J. Bardaji
// and F. Tallet
 
[nobs,nvar]=size(data)
indrows=find(sum(bool2s(~isnan(data)),'c') ~= 0)
 
select coding
 
case 'KERN'
   mat_cod=cod_kern(data,nbqua);
 
else
   uniq=unique(data)
   uniq(isnan(uniq))=[]
   uniq=gsort(uniq,'g','i')
   nuniq=size(uniq,1)
   mat_cod=zeros(nobs,nvar*nuniq)
 
   for i=1:nvar
      for j=1:nuniq
          mat_cod(:,j+nuniq*(i-1))=bool2s(data(:,i) == (ones(nobs,1) .*. uniq(j)));
      end
   end
 
   puis=ones(nvar,1)
 
end
 
[mat_cal,puis,ind]=ms_coding(mat_cod,nvar,nbqua)
 
select nblatent
case 1 then
   res=tlist(['results';'meth';'y';'nobs';'nvar';...
   'coded y';'nb_quantiles';'nb_latent';'nb_states';'nojump';...
   'param';'std';'llike';'grad';'transition probabilities';...
   'conditional probabilities';'filtered probabilities';...
   'smoothed probabilities';'filtered indicator';'smoothed indicator';...
   'PZ_std';'PX_cond_std'],...
   'ms turning point',data,nobs,nvar,...
   mat_cal,nbqua,nblatent,nbstates,nojump,...
   [],[],[],[],[],[],...
   %nan*ones(nobs,nbstates),%nan*ones(nobs,nbstates),%nan*ones(nobs,1),%nan*ones(nobs,1))
 
   Write_matrices=Write_matrices_1latent
   ms_quali_filt=filt_ms_1latent
   res=est_BB(res,mat_cal,puis,nbqua,nblatent,nbstates,nojump,initparam,indrows,grocer_opt_optim,grocer_hdelta)
 
case 2 then
   nbstates=4
   res=tlist(['results';'meth';'y';'nobs';'nvar';...
   'coded y';'nb_quantiles';'nb_latent';'nb_states';'nojump';...
   'param';'std';'llike';'grad';'first transition probabilities';...
   'second transition probabilities';'conditional probabilities';...
   'filtered probabilities';'smoothed probabilities';'filtered indicator';'smoothed indicator';...
   'PZ_std';'PW_std';'PX_cond_std'],...
   'ms turning point',data,nobs,nvar,...
   mat_cal,nbqua,2,2,%f,...
  [],[],[],[],[],[],[],...
   %nan*ones(nobs,nbstates),%nan*ones(nobs,nbstates),%nan*ones(nobs,1),%nan*ones(nobs,1))
 
   Write_matrices=Write_matrices_2latent
   ms_quali_filt=filt_ms_2latent
   res=est_GL(res,mat_cal,puis,initparam,indrows,grocer_opt_optim,grocer_hdelta)
end
 
endfunction
