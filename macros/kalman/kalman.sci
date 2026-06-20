function [rkalman]=kalman(grocer_func,grocer_y,grocer_x,grocer_z,grocer_F,grocer_param,grocer_optfunc,varargin)
 
// PURPOSE: maximum likelihood estimation of a kalman model:
//          y(t) = X(t)*B(t) + Z(t)*A + e(t), e(t) = N(0,R)
//          B(t) = Z(t) * B(t-1) + v(t),    v(t) = N(0,Q)
// ------------------------------------------------------------
// INPUT:
// * grocer_func = the function which transforms the parameters
//        into the matrix of variances (Q and R)
// * grocer_y = (nobs x 1) dependent variable vector
// * grocer_x = (nobs x 1) explanatory variable matrix
// * grocer_z = (nxl) data matrix of exogenous variables (or []
//    if there are no exogenous variables in the model)
// * grocer_F = the transfer matrix
// * grocer_param = a vector of parameters (sqrt of variances)
// * varargin = optional arguments which can be:
//   - 'priorb0=x' where x is (k x 1) vector with prior b0 values
//              (default = zeros(k,1), diffuse)
//   - 'priorv0=x' where x = (k x k) matrix with prior variance
//            for Q (default = eye(k)*1e+5, a diffuse prior)
//   - 'optfunc=optimg' if the user wants to use the optim
//   optimisation function (default: optim)
//   - 'opt_nelmead=crit,nitermax' with crit the value of the
//   convergence criterion in the Nelder-Meade optimisation
//   function and nitermax the maximum number of iterations
//   (default = 'opt_nelmead=2*%eps,1000')
//   - 'opt_optim_ineq=opts' where opts are inquality options
//   for the parameters
//  (default = '')
//   - 'opt_optim=opts' where opts are options for optim
//   that can be entered after the starting value of the
//   parameters
//   (default = 'opt_optim=,''ar'',1e6,1e6'')
//   - 'opt_convg=val' where val is the threshold on gradient
//   norm
//   (default = 'opt_convg=1e-5')
// ------------------------------------------------------------
// OUTPUT:
// rkalman = a results tlist with
//   - rkalman('meth') = 'kalman'
//   - rkalman('Q') = estimated Q
//   - rkalman('R') = estimated R
//   - rkalman('priorb0') = B(0/0)
//   - rkalman('priorv0') = sigma(0/0)
//   - rkalman('betat') = B(t/t)
//   - rkalman('betaf') = B(t/t-1)
//   - rkalman('betas') = B(t/T)
//   - rkalman('sigmatt') = sigma(t/t)
//   - rkalman('sigmatf') = sigma(t/t-1)
//   - rkalman('sigmats') = sigma(t/T)
//   - rkalman('param') = estimated parameters
//   - rkalman('vcov') = variance-covariance matrix of
//     estimated parameters
//   - rkalman('tstat') = Student's t of estimated parameters
//   - rkalman('y') = y
//   - rkalman('x') = x
//   - rkalman('z') = z
//   - rkalman('yhat') = X(t)*B(t)
//   - rkalman('resid') = y-X*B(t)
//   - rkalman('like') = log-likelihood
//   - rkalman('nobs') = # of observations
//   - rkalman('nvar') = # of exogenous variables
// ------------------------------------------------------------
// Copyright Eric Dubois 2002-2013
// http://grocer.toolbox.free.fr/grocer.html
 
 
[grocer_n,grocer_k] = size(grocer_x);
grocer_param=vec2col(grocer_param)
grocer_begsmooth=1
grocer_kalman_ik=eye(grocer_k,grocer_k)
grocer_priorb0 = zeros(grocer_k,1);
grocer_priorv0 = grocer_kalman_ik*100000;
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e6,1e6'],'',',2*%eps,1000',1e-5)
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi2=strsubst(varargin(grocer_i),' ','')
      grocer_indeq=strindex(grocer_argi2,'=')
      if size(grocer_indeq,2)>1 then
         error('argument should have only one ''='' sign')
 
      elseif size(grocer_indeq,2) == 1 then
         grocer_argi2a=strsubst(part(grocer_argi2,1:grocer_indeq-1),' ','')
         grocer_argi2b=part(grocer_argi2,grocer_indeq+1:length(grocer_argi2))
         if or(grocer_argi2a == ['meth' ;'priorb0' ; 'priorv0'; 'begsmooth' ]) then
            execstr("grocer_"+varargin(grocer_i))
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'optfunc' then
             grocer_optfunc=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_nelmead' then
             grocer_opt_optim('nelmead')=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_optim' then
            grocer_opt_optim('optim')=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_optim_ineq' then
            grocer_opt_optim('optim ineq')=grocer_argi2b
            varargin(grocer_i)=null()
         elseif grocer_argi2a == 'opt_convg' then
            execstr('grocer_opt_optim(''convg'')='+grocer_argi2b)
            varargin(grocer_i)=null()
         end
      end
   else
      error('wrong type for entry # '+string(grocer_i+6))
   end
end
 
if grocer_z == [] then
// the function needs values for z and 0 ; A is set to 0
// so that it does not affect the estimation
   grocer_z=ones(grocer_n,1)
   A=0
end
 
grocer_ng=size(grocer_param,1)
grocer_ong=ones(grocer_ng,1)
 
grocer_ch='deff(''[f,g,ind]=grocer_cost(grocer_param,ind)'',[''f=filter_like(grocer_param,'''''+grocer_func...
+''''',grocer_y,grocer_x,grocer_F,grocer_z)'';''g=numz0(filter_like,grocer_param,grocer_ng,grocer_ong,1e-5,'''''+...
grocer_func+''''',grocer_y,grocer_x,grocer_F,grocer_z)''])'
 
execstr(grocer_ch)
// Do maximum likelihood estimation
select grocer_optfunc
case 'optimg' then
   [grocer_like,grocer_param,grocer_grad] = optimg(filter_like,grocer_cost,grocer_param,...
                  grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
 
case 'optim' then
   execstr('[grocer_like,grocer_param,grocer_grad] = optim(grocer_cost'+...
   grocer_opt_optim('optim ineq')+',grocer_param'+grocer_opt_optim('optim')+')')
end
 
grocer_like=-(grocer_like+0.5*grocer_n*log(2*%pi));
grocer_H0=hessian0(filter_like,grocer_param,%eps^(0.25))
grocer_vcovt=inv(grocer_H0);
// retrieve Q, R , A and, eventually, grocer_priorb0
execstr(grocer_func)
 
// retrieve filtered beta and sigmas
[betat,betaf,sigmatt,sigmatf]=kalm_filter(grocer_param,grocer_func,grocer_y,grocer_x,grocer_F,...
grocer_z)
 
tmp=sqrt(diag(grocer_vcovt))
tstat = grocer_param ./ tmp;
yhat = zeros(grocer_n,1);
for i = 1:grocer_n
  yhat(i) = grocer_x(i,:)*betat(i,:)'+grocer_z(i,:)*A;
end
 
resid = grocer_y-yhat;
 
// retrieve smoothed beta and sigmas
[betas,sigmats]=smoothing(grocer_F,betat,betaf,sigmatt,sigmatf,...
grocer_begsmooth)
 
// return results structure information
rkalman=tlist(['results';'meth';'Q';'R';'A';'F';'priorb0';...
'priorv0';'betat';'betaf';'betas';'sigmatt';'sigmatf';...
'sigmats';'param';'vcov';'tstat';'y';'x';'z';'yhat';...
'resid';'like';'grad';'nobs';'nvar'],...
'kalman',Q,R,A,grocer_F,grocer_priorb0,grocer_priorv0,betat,betaf,betas,...
sigmatt,sigmatf,sigmats,grocer_param,grocer_vcovt,tstat,...
grocer_y,grocer_x,grocer_z,yhat,resid,grocer_like,grocer_grad,...
grocer_n,grocer_k)
 
endfunction
