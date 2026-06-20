function resirfcb=msvar_irf_cb(res,hor,niter,siz,varargin)
 
// PURPOSE: calculate confidence bands for impulse response
// functions for a Markov-switching VAR
// ------------------------------------------------------------
// INPUT:
// * res = a tlist result from a ms var estimation
// * hor = a scalar, the horizon of the irf (note that the
//   shocks are supposed to happen at time 0; therefore
//   (hor+1) impulses are calculated)
// * niter = number of iterations
// * siz = siz of confidence bands
// * mres = optional argument that can be:
//   - x = chol1 (cholesky decomposition)
//   - x = chol2 (triangular factorisation)
//   - x = original (original residuals)
//   - x = soriginal (standardized (one standard deviation shock)
//         uncorrelated residuals)
//   - x = girf (Generalized Impulse Response based on Pesaran
//         and Shin)
//   (default = soriginal)
// * 'nopprint' = optional argument if the suer does not want
//   to plot the irf
// ------------------------------------------------------------
// OUTPUT:
// resirf = a result tlist with:
// - resirf('meth') = 'msvar cb irf'
// - resirf('msvar cb res') = the input ms var results tlist
// - resirf('# irf') = the horizon of the irf calculations
// - resirf('nb states') = the # of states
// - resirf('nb irf') = the # of different AR parts
//   * 1 if they do not switch
//   * the # states if they switch
// - resirf('sigma switch') = the # of switching variances
//   * 1 if they do not switch
//   * the # states if they switch
// - resirf('irf part state') = the partial impulse response
// - resirf('irf full state') = the full impulse response
// - resirf('irf part lower cb') = the lower part of the
//   confidence band for the partial impulse response
// - resirf('irf full lower cb') = the lower part of the
//   confidence band for the full impulse response
// - resirf('irf part upper cb') = the upper part of the
//   confidence band for the partial impulse response
// - resirf('irf full upper cb') =  the upper part of the
//   confidence band for the full impulse response
// - resirf('irf part median') = the median part of the
//   confidence band for the partial impulse response
// - resirf('irf full median') = the median part of the
//   confidence band for the full impulse response
// - resirf('irf part state # i') = partial impulse response
//   for state i
// - resirf('irf full state # i') = the full impulse response
//   for state i
// - resirf('irf part lower cb state # i') = lower part of the
//   confidence band for partial impulse response of state i
// - resirf('irf part upper cb state # i') = upper part of the
//   confidence band for partial impulse response of state i
// - resirf('irf part median state # i') = median partial
//   impulse response of state i
// - resirf('irf full lower cb state # i') = lower part of the
//   confidence band for full impulse response of state i
// - resirf('irf full upper cb state # i') = upper part of the
//   confidence band for full impulse response of state i
// - resirf('irf full median state # i') = median full impulse
//   response of state i
// ------------------------------------------------------------
// Copyright Stefan Fiesel 2015
// irf_cb is part of Grocer, available at:
// http://grocer.toolbox.free.fr/grocer.html
 
 
// set defaults
mres='soriginal'
grocer_plt=%t
 
if res('meth') ~= 'ms var' then
   error('first arg should be a ms var results tlist')
end
 
if and(type(niter) ~=[1 5 8]) then
    error('niter should be an integer')
end
 
if int(niter) ~= niter then
    error('niter should be an integer')
end
 
if and(type(hor) ~=[1 5 8]) then
    error('hor should be an integer')
end
 
if int(hor) ~= hor then
    error('hor should be an integer')
end
 
if and(type(siz) ~=[1 5 8]) then
    error('siz should be an integer')
end
 
if siz > 1 | siz < 0 then
    error('siz should be between 0 and 1')
end
 
if floor(0.5*siz*niter) < 1 then
    write(%io(2),'niter too small','(a)')
end
 
for i=1:length(varargin)
   ieq=strindex(varargin(i),'=')
   car1=part(varargin(i),1:ieq-1)
   l=length(varargin(i))
 
   if car1 == 'mres' then
      mres=part(varargin(i),ieq+1:l)
   elseif stripblanks(varargin(i)) == 'noprint' then
      groceer_plt=%f
   end
end
 
grocer_hessian=%t
grocer_gdelta = 1e-4
grocer_hdelta = 1e-5
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',2*%eps,1000',1e-5)
beta_id=res('beta_id');
beta_co=res('beta_co');
nlag=res('nlag');
grocer_MS_K=res('nendo');
grocer_MS_T=res('nobs')
nobs=grocer_MS_T+nlag;
grocer_MS_M=res('nb_states');
y = res('yall');
VCV = res('sigma');
grocer_MS_var_opt = res('var_opt');
grocer_MS_M_V = res('switching V');
namey=res('namey')
eprob = res('prob_st');
grocer_MS_typmod=res('typemod')
grocer_optfunc='optim'
param0=res('coeff')
var_temp=res
 
for i=1:grocer_MS_M
   beta_i=beta_id(:,i);
   if isempty(res('beta_co')) then
      Const(:,i)=beta_i((grocer_MS_K*nlag+1)*[1:grocer_MS_K]);
      // remove constants from the beta vector
      beta_i((grocer_MS_K*nlag+1)*[1:grocer_MS_K])=[];
      CMatrix(:,:,i)=matrix(beta_i,grocer_MS_K*nlag,grocer_MS_K)';
   else
      Const(:,i)=beta_i;
      CMatrix=matrix(beta_co,grocer_MS_K*nlag,grocer_MS_K)';
   end
end
 
resirfcb=tlist(['results';'meth';'msvar cb res';'# irf';'nb states';'# AR';'sigma switch';'innovation type'],...
'msvar cb irf',res,hor,grocer_MS_M,1-(grocer_MS_M-1)*(grocer_MS_typmod-3),grocer_MS_M_V,[])
 
grocer_Vec_Mat_foo=MSVAR_Vec_Mat
 
INF_part = zeros(hor+1,grocer_MS_M,grocer_MS_M,grocer_MS_M);
SUP_part = zeros(hor+1,grocer_MS_M,grocer_MS_M,grocer_MS_M);
MED_part = zeros(hor+1,grocer_MS_M,grocer_MS_M,grocer_MS_M);
IRF_part = zeros(hor+1,grocer_MS_M,grocer_MS_M,grocer_MS_M,niter+1); //+1 to store IRF for original data in IRF_part(:,:,:,niter+1)
 
INF_full = zeros(hor+1,grocer_MS_M,grocer_MS_M,grocer_MS_M);
SUP_full = zeros(hor+1,grocer_MS_M,grocer_MS_M,grocer_MS_M);
MED_full = zeros(hor+1,grocer_MS_M,grocer_MS_M,grocer_MS_M);
IRF_full = zeros(hor+1,grocer_MS_M,grocer_MS_M,grocer_MS_M,niter+1);
 
transition_matrix = res('ptrans');
 
for i=1:grocer_MS_M
   beta_i=beta_id(:,i);
   if isempty(res('beta_co')) then
      Const(:,i)=beta_i((grocer_MS_K*nlag+1)*[1:grocer_MS_K]);
      // remove constants from the beta vector
      beta_i((grocer_MS_K*nlag+1)*[1:grocer_MS_K])=[];
      CMatrix(:,:,i)=matrix(beta_i,grocer_MS_K*nlag,grocer_MS_K)';
   else
      Const(:,i)=beta_i;
      CMatrix=matrix(beta_co,grocer_MS_K*nlag,grocer_MS_K)';
   end
   if res('switching V') == grocer_MS_M then
      VCV2(:,:,i) = VCV(:,(i-1)*grocer_MS_K+1:grocer_MS_K*i);
   else
      VCV2 = VCV;
   end
end
 
y_artificial=y
//Create IRF for original data
resirf=msvar_irf(res,hor,'mres='+mres);
for u=1:grocer_MS_M
    execstr('irf_full=resirf(''irf full state # '+string(u)+''')')
    execstr('irf_part=resirf(''irf part state # '+string(u)+''')')
    for i=1:grocer_MS_K
        for j=1:grocer_MS_K
            IRF_part(:,j,i,u,niter+1) = irf_part(grocer_MS_K*[0:hor]+i,j);
            IRF_full(:,j,i,u,niter+1) = irf_full(grocer_MS_K*[0:hor]+i,j);
        end
    end
end
 
//Create confidence bands based on bootstrapping
for w = 1:niter
    write(%io(2),"Progress:",'(a)')
    disp(w/niter)
 
   y_artificial=msvar_draw(grocer_MS_T,grocer_MS_K,nlag,grocer_MS_M,grocer_MS_M_V,grocer_MS_typmod,y(1:nlag,:),res('ptrans'),Const,CMatrix,VCV2)
 
   y0=y_artificial(nlag+1:$,:)
   ylag=mlagb(y_artificial,nlag)
   ylag=ylag(nlag+1:$,:)
   y_mat=y0(:)
   if res('typemod') == 2 then
      x_mat=eye(grocer_MS_K,grocer_MS_K) .*. [ylag ones(grocer_MS_T,1)]
      z_mat = []
   else
      x_mat = eye(grocer_MS_K,grocer_MS_K) .*. ones(grocer_MS_T,1)
      z_mat = eye(grocer_MS_K,grocer_MS_K) .*. ylag
   end
 
   [paramfin,likl1,grad] = MSVAR_MaxHmm(param0,'optim',grocer_opt_optim);
   [prob_st,ptrans,beta_id,beta_co,sigma,inv_sigma,det_inv_sigma]=...
   MSVAR_Vec_Mat(paramfin,grocer_MS_K,grocer_MS_M,grocer_MS_var_opt,grocer_MS_M_V,size(x_mat,2),size(z_mat,2))
 
   if res('typemod') == 2 then
      beta_co = []
   end
   var_temp('beta_co')=beta_co
   var_temp('beta_id')=beta_id
   var_temp('ptrans')=ptrans
   var_temp('sigma')=sigma
   var_temp('xmat')=x_mat
   var_temp('zmat')=z_mat
   resirf=msvar_irf(var_temp,hor,'mres='+mres);
 
   for u=1:grocer_MS_M
      execstr('irf_full=resirf(''irf full state # '+string(u)+''')')
      execstr('irf_part=resirf(''irf part state # '+string(u)+''')')
      for i=1:grocer_MS_K
         for j=1:grocer_MS_K
            IRF_part(:,j,i,u,w) = irf_part(grocer_MS_K*[0:hor]+i,j);
            IRF_full(:,j,i,u,w) = irf_full(grocer_MS_K*[0:hor]+i,j);
         end
      end
   end
 
end
 
//Percentile
 
 
 
for u=1:grocer_MS_M
    for c = 1:grocer_MS_K
        for b=1:grocer_MS_K
            for a=1:(hor+1)
                irf_sort=gsort(real(IRF_part(a,b,c,u,1:niter)),'g','i');
                INF_part(a,b,c,u) = irf_sort(floor(0.5*siz*niter));
                SUP_part(a,b,c,u) = irf_sort(floor((1-0.5*siz)*niter));
                MED_part(a,b,c,u) = irf_sort(floor(0.5*niter));
                irf_sort=gsort(real(IRF_full(a,b,c,u,1:niter)),'g','i');
                INF_full(a,b,c,u) = irf_sort(floor(0.5*siz*niter));
                SUP_full(a,b,c,u) = irf_sort(floor((1-0.5*siz)*niter));
                MED_full(a,b,c,u) = irf_sort(floor(0.5*niter));
            end
        end
    end
end
 
//IRF from original data
IRF_part=IRF_part(:,:,:,:,niter+1);
IRF_full=IRF_full(:,:,:,:,niter+1);
resirfcb(1)($+1)='irf full state'
resirfcb($+1)=IRF_full(:,:,:,:)
resirfcb(1)($+1)='irf part state'
resirfcb($+1)=IRF_part(:,:,:,:)
resirfcb(1)($+1)='irf full lower cb'
resirfcb($+1)=INF_full(:,:,:,:)
resirfcb(1)($+1)='irf part lower cb'
resirfcb($+1)=INF_part(:,:,:,:)
resirfcb(1)($+1)='irf full upper cb'
resirfcb($+1)=SUP_full(:,:,:,:)
resirfcb(1)($+1)='irf part upper cb'
resirfcb($+1)=SUP_part(:,:,:,:)
resirfcb(1)($+1)='irf full median'
resirfcb($+1)=MED_full(:,:,:,:)
resirfcb(1)($+1)='irf part median'
resirfcb($+1)=MED_part(:,:,:,:)
 
for i=1:grocer_MS_M
    resirfcb(1)($+1)='irf part state # '+string(i)
    resirfcb($+1)=IRF_part(:,:,:,i)
    resirfcb(1)($+1)='irf part lower cb state # '+string(i)
    resirfcb($+1)=INF_part(:,:,:,i)
    resirfcb(1)($+1)='irf part upper cb state # '+string(i)
    resirfcb($+1)=SUP_part(:,:,:,i)
    resirfcb(1)($+1)='irf part median state # '+string(i)
    resirfcb($+1)=MED_part(:,:,:,i)
end
 
for i=1:grocer_MS_M
    resirfcb(1)($+1)='irf full state # '+string(i)
    resirfcb($+1)=IRF_full(:,:,:,i)
    resirfcb(1)($+1)='irf full lower cb state # '+string(i)
    resirfcb($+1)=INF_full(:,:,:,i)
    resirfcb(1)($+1)='irf full upper cb state # '+string(i)
    resirfcb($+1)=SUP_full(:,:,:,i)
    resirfcb(1)($+1)='irf full median state # '+string(i)
    resirfcb($+1)=MED_full(:,:,:,i)
end
 
resirfcb('innovation type')=mres
 
if grocer_plt then
   plt_msvarirf_cb(resirfcb)
end
 
endfunction
 
