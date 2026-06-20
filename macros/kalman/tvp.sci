function [rtvp]=tvp(grocer_namey,varargin)
 
// PURPOSE: time-varying parameter maximum likelihood
// estimation of the linear regression model
//          y(t) = X(t)*B(t) + e(t), e(t) = N(0,R)
//          B(t) = B(t-1) + v(t),    v(t) = N(0,Q)
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a string
// equal to the name of a time series or a (nx1) real vector
// between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (nx1) vector
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . 'priorb0=x' where x is (k x 1) vector with prior b0 values
//              (default = zeros(k,1), diffuse)
//   . 'priorv0=x' where x = (k x k) matrix with prior variance
//            for Q (default = eye(k)*1e+5, a diffuse prior)
//   . 'tvpmeth=x' where x = 1 (Q is diagonal and only Q and R
//      are estimated), x=1a (no constraint on Q and only Q and
//      R are estimated), x=2 (prirov0=0, Q is diagonal and
//      priorb0, Q and R are estimated), x=2a (no constraint on
//      Q, priorv0=0, and priorb0, Q and R are estimated)
//      default = 1
//   . 'Q=x' where x is a (kxk) initial value for Q
//   . 'R=x' where x is an initial value for R
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
//   . the string 'dropna' if the user wants to delete NAs
//     (this option should be used when dealing with daily and weekly TS)
// ------------------------------------------------------------
// OUTPUT:
// rtvp = a results tlist with
//   - rtvp('meth') = 'tvp'
//   - rtvp('Q') = estimated Q
//   - rtvp('R') = estimated R
//   - rtvp('betat') = B(t/t)
//   - rtvp('betaf') = B(t/t-1)
//   - rtvp('betas') = B(t/T)
//   - rtvp('sigmatt') = sigma(t/t)
//   - rtvp('sigmatf') = sigma(t/t-1)
//   - rtvp('sigmats') = sigma(t/T)
//   - rtvp('param') = estimated parameters
//   - rtvp('vcov') = variance-covariance matrix of
//     estimated paramters
//   - rtvp('tstat') = Student's t of estimated parameters
//   - rtvp('y') = y
//   - rtvp('x') = x
//   - rtvp('yhat') = X(t)*B(t)
//   - rtvp('resid') = y-X*B(t)
//   - rtvp('like') = log-likelihood
//   - rtvp('nobs') = # of observations
//   - rtvp('nvar') = # of exogenous variables
//   - rtvp('tR') = t-stat of estimated R variance
//   - rtvp('tQ') = t-stat of estimated Q variance
//   - rtvp('tpriorb0') = t-stat of estimated priorb0 (if
//     method 1a or 2a are used)
//   - rtvp('param') = estimated parameters in a vector form
//   - rtvp('tstat') = their t-stat
//   - rtvp('tvpmeth') = method used in tvp
//   - rtvp('namey') = name of the endogenous variable
//   - rtvp('namex') = name of the exogenous variable
//   - rtvp('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   - rtvp('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   - rtvp('dropna') = boolean indicating if NAs had
//		                         been droped
//   - rtvp('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// NOTE: the methods '1a' and '2a' are not very robust; so I
// recommend to use them with much caution !
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_tvpmeth='1'
grocer_optmeth='maxlik'
grocer_dropna=%f
grocer_prt=%t
grocer_lx=varargin
 
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
         if grocer_argi2a == 'priorb0' | grocer_argi2a == 'priorv0' then
            execstr('grocer_'+varargin(grocer_i))
            varargin(grocer_i)=null()
            grocer_lx(grocer_i)=null()
         elseif grocer_argi2a == 'tvpmeth' then
            execstr('grocer_'+strsubst(varargin(grocer_i),'=',...
                '=''')+'''')
            varargin(grocer_i)=null()
            grocer_lx(grocer_i)=null()
         elseif grocer_argi2a == 'Q' | grocer_argi2a== 'R' then
            execstr('grocer_'+varargin(grocer_i))
            varargin(grocer_i)=null()
            grocer_lx(grocer_i)=null()
         elseif or(grocer_argi2a == ['optfunc' ; 'opt_nelmead' ; 'opt_optim' ;...
             'opt_optim_ineq' ; 'opt_convg']) then
            grocer_lx(grocer_i)=null()
         end
      elseif varargin(grocer_i) == 'noprint' then
         grocer_prt=%f
         grocer_lx(grocer_i)=null()
         varargin(grocer_i)=null()
      elseif varargin(grocer_i) == 'dropna' then
         grocer_prt=%t
         grocer_lx(grocer_i)=null()
         varargin(grocer_i)=null()
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' & typeof(varargin(grocer_i)) ~= 'tsmat' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
      explouniv(grocer_namey,grocer_lx,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
[grocer_nobs,grocer_nvar] = size(grocer_x);
grocer_ik=eye(grocer_nvar,grocer_nvar)
 
// estimate the model by ols to set, if necessary, defaults value
grocer_r0=ols1(grocer_y,grocer_x)
if ~exists('grocer_R','local') then
   grocer_R=1e-3*grocer_r0('sige')
end
if ~exists('grocer_Q','local') then
   grocer_Q=grocer_ik
end
if ~exists('grocer_priorb0','local') then
   grocer_priorb0 = grocer_r0('beta')
else
   grocer_priorb0 = vec2col(grocer_priorb0)
   if size(grocer_priorb0,1) ~= grocer_nvar then
      error('invalid # of parameters in priorb0')
   end
end
 
A=0
select grocer_tvpmeth
case '1' then
// calculate intial values
   grocer_param=[sqrt(grocer_R) ; sqrt(diag(grocer_Q))]
   if ~exists('grocer_priorv0','local') then
      grocer_priorv0 = grocer_ik*100000;
   else
      if size(grocer_priorv0,1) ~= grocer_nvar ...
         | size(grocer_priorv0,2) ~= grocer_nvar then
         error('invalid # of parameters in priorv0')
      end
   end
   grocer_func='[Q,R]=tvp_param1(grocer_param)'
// estimate the kalman filter
   rtvp=kalman(grocer_func,grocer_y,grocer_x,[],grocer_ik,...
   grocer_param,'priorb0=grocer_priorb0',...
   'priorv0=grocer_priorv0',varargin(:))
   rtvp('vcov')=diag(rtvp('param'))*rtvp('vcov')*diag(rtvp('param'))
   rtvp('param')=rtvp('param').^2
// adjust the tstat to take into account the fact that R is
// the square of the first estimated parameter
   rtvp(1)($+1)='tR'
   rtvp(1)($+1)='tQ'
   rtvp('tstat')=abs(rtvp('tstat'))
   rtvp('tR')=rtvp('tstat')(1)
   rtvp('tQ')=rtvp('tstat')(2:grocer_nvar+1)
 
case '1a' then
   grocer_param=[sqrt(grocer_R) ; vech(grocer_Q)]
   if ~exists('grocer_priorv0','local') then
      grocer_priorv0 = grocer_ik*100000;
   else
      if size(grocer_priorv0,1) ~= grocer_nvar | ...
         size(grocer_priorv0,2) ~= grocer_nvar then
         error('invalid # of parameters in priorv0')
      end
   end
   grocer_func='[Q,R]=tvp_param1a(grocer_param)'
// estimate the kalman filter
   rtvp=kalman(grocer_func,grocer_y,grocer_x,[],grocer_ik,...
   grocer_param,'priorb0=grocer_priorb0',...
   'priorv0=grocer_priorv0','meth=grocer_optmeth',varargin(:))
   grocer_param=[rtvp('R') ; vech(rtvp('Q'))]
   vcovt=0.25*hessian(filter_like,grocer_param,%eps^0.25,...
   '[Q,R]=tvp_param1ad(grocer_param)',grocer_y,grocer_x,...
   grocer_ik,[])
   nparam=grocer_nvar*(grocer_nvar+1)/2
   [u,s,v]=svd(vcovt)
   tstat=grocer_param ./ sqrt(diag(u* diag(ones(size(grocer_param,1),1) ./ diag(s)) *v'))
   tQ=matrix(duplication(grocer_nvar)*tstat(2:nparam+1),...
   grocer_nvar,grocer_nvar)
   rtvp('vcov')=vcovt
   rtvp('tstat')=tstat
   rtvp(1)($+1)='tR'
   rtvp(1)($+1)='tQ'
   rtvp('tR')=tstat(1)
   rtvp('tQ')=tQ
 
case '2' then
   grocer_priorv0=grocer_ik
   grocer_param=[sqrt(grocer_R) ; sqrt(diag(grocer_Q)) ; ...
                 grocer_priorb0]
   grocer_func='[Q,R,grocer_priorb0]=tvp_param2(grocer_param,grocer_nvar)'
   grocer_z=grocer_ik
   rtvp=kalman(grocer_func,grocer_y,grocer_x,[],grocer_ik,...
   grocer_param,'priorv0=grocer_z','meth=grocer_optmeth',...
   varargin(:))
   rtvp('vcov')(1:grocer_nvar+1,1:grocer_nvar+1)=...
      diag(rtvp('param')(1:grocer_nvar+1))...
      *rtvp('vcov')(1:grocer_nvar+1,1:grocer_nvar+1)...
      *diag(rtvp('param')(1:grocer_nvar+1))
   rtvp('param')(1:grocer_nvar+1)=rtvp('param')(1:grocer_nvar+1).^2
   rtvp('tstat')(1:grocer_nvar+1)=abs(rtvp('tstat')(1:grocer_nvar+1))
   tstat=rtvp('tstat')
   rtvp(1)($+1)='tR'
   rtvp(1)($+1)='tQ'
   rtvp(1)($+1)='tpriorb0'
   rtvp('tR')=tstat(1)
   rtvp('tQ')=abs(tstat(2:grocer_nvar+1))
   rtvp('tpriorb0')=tstat(grocer_nvar+2:2*grocer_nvar+1)
 
case '2a' then
   grocer_priorv0=zeros(grocer_nvar,grocer_nvar)
   grocer_param=[sqrt(grocer_R) ; vech(chol(grocer_Q)') ; ...
                grocer_priorb0]
   grocer_func='[Q,R,grocer_priorb0]=tvp_param2a(grocer_param)'
   grocer_z=zeros(grocer_nvar,grocer_nvar)
   rtvp=kalman(grocer_func,grocer_y,grocer_x,[],...
        eye(grocer_nvar,grocer_nvar),grocer_param,...
        'priorv0=grocer_z','meth=grocer_optmeth',varargin(:))
   grocer_param=[rtvp('R') ; vech(rtvp('Q')) ; rtvp('priorb0')]
// calculate the tstat by using a function which is
// tractable because Q and R derive straitforwardly from param
   vcovt=0.25*hessian(filter_like,grocer_param,%eps^0.25,...
       '[Q,R,grocer_priorb0]=tvp_param2ad(grocer_param)',...
        grocer_y,grocer_x,eye(grocer_nvar,grocer_nvar),[])
   nparam=grocer_nvar*(grocer_nvar+1)/2
   [u,s,v]=svd(vcovt)
   tstat=grocer_param./sqrt(diag(u* diag(ones(size(grocer_param,1),1) ./ diag(s)) *v'))
   rtvp('vcov')=vcovt
   rtvp('tstat')=tstat
   rtvp(1)($+1)='tR'
   rtvp(1)($+1)='tQ'
   rtvp(1)($+1)='tpriorb0'
   rtvp('tR')=tstat(1)
   rtvp('tQ')=matrix(duplication(grocer_nvar)*tstat(2:nparam+1),...
              grocer_nvar,grocer_nvar)
   rtvp('tpriorb0')=tstat(nparam+2:nparam+grocer_nvar+1)
 
end
 
rtvp('meth')='tvp'
rtvp(1)($+1)='tvpmeth'
rtvp('tvpmeth')=grocer_tvpmeth
rtvp(1)($+1)='namey'
rtvp('namey')=grocer_namey
rtvp(1)($+1)='namex'
rtvp('namex')=grocer_namexos
rtvp(1)($+1)='prests'
rtvp('prests')=grocer_prests
rtvp(1)($+1) = 'dropna'
rtvp('dropna') =grocer_dropna
if grocer_prests then
   rtvp(1)($+1)='bounds'
   rtvp('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rtvp(1)($+1)='nonna'
   rtvp('nonna')=nonna
end
 
if grocer_prt then
   prttvp(rtvp,%io(2))
   plttvp(rtvp)
end
endfunction
