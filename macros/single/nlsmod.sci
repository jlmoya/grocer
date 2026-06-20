function varargout=nlsmod(grocer_model,grocer_tsmat,grocer_indeq,varargin)
 
// PURPOSE: estimate by non-linear least squares an equation of
// a model
// ------------------------------------------------------------
// INPUT:
// * grocer_model = a model tlist
// * grocer_tsmat = a tsmat containing all data needed for
//   estimating the equation (should be the tsmat associated to
//    the model, created by function create_dbmod)
// * grocer_indeq =
//   - a string, the name of the equation to estimate or the
//   keyword 'all' (to estimate all equations)
//   - or an interger, the # of the equation in the model
// * varargin = optional arguments
//   - 'noprint' if the user does not want to print the result
//   (defautlt: results are displayed on screen)
//   - 'save=%t' if the user wants to save the estimated
//   coefficients in the model tlist
//   - 'optfunc=optim' if the user wants to use the optim
//   optimisation function (default: optimg)
//   - 'opt_nelmead=crit,nitermax' with crit the value of the
//   convergence criterion in the Nelder-Meade optimisation
//   function and nitermax the maximum number of iterations
//   (default = 'opt_nelmead=2*%eps,1000')
//   - 'opt_optim=opts' where opts are options for optim
//   that can be entered after the starting value of the
//   parameters
//   (default = 'opt_optim=,''ar'',1e6,1e6'')
//   - 'opt_convg=val' where val is the threshold on gradient
//   norm
//   (default = 'opt_convg=1e-5')
// ------------------------------------------------------------
// OUTPUT:
// * grocer_model = the model tlist, with the estimated
//   coefficients if the option save has been swtiched to %t
// * rnlsmod = a results tlist, with:
//   . rnlsmod('meth')  = 'olsmod'
//   . rnlsmod('y')     = y data vector
//   . rnlsmod('x')     = x data matrix
//   . rnlsmod('nobs')  = # observations
//   . rnlsmod('nvar')  = # variables
//   . rnlsmod('beta')  = bhat
//   . rnlsmod('yhat')  = yhat
//   . rnlsmod('resid') = residuals
//   . rnlsmod('vcovar') = estimated variance-covariance matrix of
//     beta
//   . rnlsmod('sige')  = estimated variance of the residuals
//   . rnlsmod('sigu')  = sum of squared residuals
//   . rnlsmod('ser')  = standard error of the regression
//   . rnlsmod('tstat') = t-stats
//   . rnlsmod('pvalue') = pvalue of the betas
//   . rnlsmod('dw')    = Durbin-Watson Statistic
//   . rnlsmod('condindex') = multicolinearity cond index
//   . rnlsmod('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . rnlsmod('llike') = the log-likelihood
//   . rnlsmod('aic')= the Akaike information criterion
//   . rnlsmod('bic')= the Schwarz information criterion
//   . rnlsmod('hq')= the Hannan-Quinn information criterion
//   . rnlsmod('rsqr')  = rsquared
//   . rnlsmod('rbar')  = rbar-squared
//   . rnlsmod('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . rnlsmod('pvaluef') = its significance level
//   . rnlsmod('like') = log-likelihood of the regression
//   . rnlsmod('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rnlsmod('namey') = name of the y variable
//   . rnlsmod('namex') = name of the coefficients
//   . rnlsmod('dropna') = boolean indicating if NAs have
//		   been dropped
//   . rnlsmod('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rnlsmod('nonna') = vector indicating position of non-NAs
//   . rnlsmod('saturation significance level') = significance
//     level used to keep the dummies
//   . rnlsmod('significant dummies') = the remaining dummies
//     after testing
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018-2019
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_listout=list()
grocer_dropna=%f
grocer_prt=%t
grocer_save=%f
grocer_prt=%t
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',10*%eps,1000',1e-5)
// grocer_initcoeffs collects all coeffs with given starting values and grocer_coeffs0 their values
grocer_initcoeffs=[]
grocer_coeffs0=[]
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if part(grocer_argi,1:4) == 'save'
         execstr('grocer_'+grocer_argi)
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
      elseif part(grocer_argi,1:5) == 'init_' then
         grocer_indeqi=strindex(grocer_argi,'=')
         grocer_initcoeffs=[grocer_initcoeffs ; part(grocer_argi,6:length(grocer_argi))]
         grocer_coeffs0=[grocer_coeffs0 ; evstr(part(grocer_argi,grocer_indeqi+1:length(grocer_argi)))]
      elseif part(grocer_argi,1:8) == 'optfunc=' then
         grocer_optfunc=part(grocer_argi,9:length(grocer_argi))
      elseif part(grocer_argi,1:12) == 'opt_nelmead=' then
         grocer_opt_optim('nelmead')=part(grocer_argi,13:length(grocer_argi))
      elseif part(grocer_argi,1:10) == 'opt_optim=' then
         grocer_opt_optim('optim')=part(grocer_argi,11:length(grocer_argi))
      elseif part(grocer_argi,1:10) == 'opt_optim_ineq=' then
            grocer_opt_optim('optim ineq')=part(grocer_argi,16:length(grocer_argi))
      elseif part(grocer_argi,1:10) == 'opt_convg=' then
         execstr('grocer_opt_optim(''convg'')='+part(grocer_argi,11:length(grocer_argi)))
      end
   end
end
 
if typeof(grocer_model) == 'string' then
   grocer_model=create_model(grocer_model)
end
 
grocer_equations=grocer_model('equations')
grocer_linear=grocer_model('linearity')
grocer_coeffs=grocer_model('coeffs')
grocer_namecoeffs=grocer_coeffs(1)(2:$)
grocer_params=grocer_model('params')
grocer_nameparams=grocer_params(1)(2:$)
for grocer_i=1:size(grocer_nameparams,1)
    execstr(grocer_nameparams(grocer_i)+'=grocer_params(grocer_i+1)')
end
grocer_namendos=grocer_model('name endo')
grocer_namexos=grocer_model('name exo')
grocer_nameresids=grocer_model('name resid')
grocer_listexog=grocer_model('names for regressions')
 
grocer_resid=grocer_model('name resid')
 
grocer_tsmat_names=grocer_tsmat('names')
grocer_series=grocer_tsmat('series')
 
grocer_one=tlist(['ts';'freq';'dates';'series'],grocer_tsmat('freq'),grocer_tsmat('dates'),ones(size(grocer_series,1),1))
grocer_ts=grocer_one
grocer_zero=grocer_ts
grocer_zero('series')=zeros(size(grocer_series,1),1)
 
if typeof(grocer_indeq) == 'string' then
   grocer_indeqnum=[]
   grocer_nameq=grocer_model('name eq')
   for grocer_j=1:size(grocer_indeq,'*')
      grocer_indeqj=stripblanks(grocer_indeq(grocer_j))
      grocer_indeqnumj=find(grocer_nameq == grocer_indeqj)
      if isempty(grocer_indeqnumj) then
         warning('equation '+grocer_indeqj+' not found')
      end
      grocer_indeqnum=[grocer_indeqnum ; grocer_indeqnumj]
   end
 
elseif typeof(grocer_indeq) == 'constant' then
   grocer_indeqnum=grocer_indeq
 
end
 
grocer_neq=size(grocer_indeqnum,1)
if size(grocer_save,'*') == 1 then
   grocer_save=grocer_save*ones(grocer_neq,1)
end
 
grocer_j=1
while grocer_j <=grocer_neq
   grocer_indeqj=grocer_indeqnum(grocer_j)
   grocer_linearj=grocer_linear(grocer_indeqj)
   if grocer_linearj then
      warning('equation '+grocer_indeq(grocer_j)+' is linear and could be estimated by olsmod')
   end
   grocer_eqj=grocer_equations(grocer_indeqj)
   grocer_indeqj_listexog=grocer_listexog(grocer_indeqj)
   grocer_indeqj_namecoeff=grocer_indeqj_listexog(:,1)
   grocer_derivj=grocer_indeqj_listexog(:,2)
   grocer_eqj_namevari=[grocer_namendos(find(grocer_model('eq endos')(:,grocer_indeqj)~=0)) ;
                    grocer_namexos(find(grocer_model('eq exos')(:,grocer_indeqj)~=0)) ]
   for grocer_i=1:size(grocer_eqj_namevari,1)
      grocer_k=find(grocer_tsmat_names == grocer_eqj_namevari(grocer_i))
      if isempty(grocer_k) then
         warning('series '+grocer_eqj_namevari(grocer_i)+' not in input tsmat; program will use an existing variable with that name, if any')
      else
         grocer_ts('series')=grocer_series(:,grocer_k)
         execstr(grocer_eqj_namevari(grocer_i)+'=grocer_ts')
      end
   end
   grocer_indequal=strindex(grocer_eqj,'=')
   grocer_eqj_resid=grocer_nameresids(find(grocer_model('eq resids')(:,grocer_indeqj)~=0))
   for grocer_i=1:size(grocer_eqj_resid,1)
      execstr(grocer_eqj_resid(grocer_i)+'=grocer_zero')
   end
 
   grocer_eq4func=strsubst(part(grocer_eqj,grocer_indequal+1:length(grocer_eqj))+'-('+part(grocer_eqj,1:grocer_indequal-1)+')',' ','')
   grocer_ncoeffs=size(grocer_indeqj_namecoeff,1)
 
   grocer_a=grand(grocer_ncoeffs,1,'nor',0,1)
   for grocer_i=1:grocer_ncoeffs
      grocer_namei=grocer_indeqj_namecoeff(grocer_i)
      grocer_indcoeff=find(grocer_initcoeffs == grocer_namei)
      if isempty(grocer_indcoeff) then
         execstr(grocer_namei+'=grocer_a('+string(grocer_i)+')')
      else
         execstr(grocer_namei+'=grocer_coeffs0('+string(grocer_i)+')')
      end
   end

   grocer_ts=evstr(grocer_eq4func)
   grocer_dates=grocer_ts('dates')
 
   if ~exists('grocer_boundsvar') then
      fq=grocer_ts('freq')
      [grocer_start,grocer_end]=longest_nonna_span(grocer_ts('series'))
      grocer_boundsvarnum=grocer_dates([grocer_start,grocer_end])
      grocer_boundsvar=[num2date(grocer_boundsvarnum(1),fq) ; num2date(grocer_boundsvarnum(2),fq)]
      grocer_dates_estim=string(grocer_boundsvarnum(1))+':'+string(grocer_boundsvarnum(2))
   else
      grocer_dates_estim='['+string(grocer_boundsvarnum(1))+':'+string(grocer_boundsvarnum(2))
      for grocer_k=2:size(grocer_boundsvarnum,2)/2
         grocer_dates_estim=grocer_dates_estim+','+string(grocer_boundsvarnum(2*k-1))+':'+string(grocer_boundsvarnum(2*k))
      end
      grocer_dates_estim=grocer_dates_estim+']'
   end
   grocer_nobs=size(evstr(grocer_dates_estim),2)
 
   grocer_chf='deff(''[grocer_f,index]=grocer_func2(grocer_a,index)'',';
   grocer_chf=grocer_chf+'['''+joinstr(grocer_indeqj_namecoeff,'=grocer_a(',string(1:grocer_ncoeffs),')'';''')+')'';'
   grocer_chf=grocer_chf+'''grocer_ts='+grocer_eq4func+''';'
   grocer_chf=grocer_chf+'''grocer_s=grocer_ts(''''series'''')(['+grocer_dates_estim+']-'+string(grocer_dates(1)-1)+')'';'
   grocer_chf=grocer_chf+'''grocer_f=sum(grocer_s.^2)''])'
 
   execstr(grocer_chf)
   grocer_chg=''
   for grocer_k=1:grocer_ncoeffs
      grocer_chg=grocer_chg+';''grocer_ts='+grocer_derivj(grocer_k)+''';'
      execstr('grocer_ts='+grocer_derivj(grocer_k))
      grocer_date1_k=grocer_ts('dates')(1)
      grocer_chg=grocer_chg+'''grocer_sj=grocer_ts(''''series'''')(['+grocer_dates_estim+']-'+string(grocer_date1_k-1)+')'';'
      grocer_chg=grocer_chg+'''grocer_g('+string(grocer_k)+')=2*grocer_sj''''*grocer_s'''
   end
 
   grocer_chfng='deff(''[grocer_f,grocer_g,ind]=grocer_func(grocer_a,ind)'','
   grocer_chfng=grocer_chfng+'['''+joinstr(grocer_indeqj_namecoeff,'=grocer_a(',string(1:grocer_ncoeffs),')'';''')+')'';'
   grocer_chfng=grocer_chfng+'     ''grocer_ts='+grocer_eq4func+''';'
   grocer_chfng=grocer_chfng+'''grocer_s=grocer_ts(''''series'''')(['+grocer_dates_estim+']-'+string(grocer_dates(1)-1)+')'';'
   grocer_chfng=grocer_chfng+'''grocer_f=sum(grocer_s.^2)'';'
   grocer_chfng=grocer_chfng+'''grocer_g=zeros('+string(grocer_ncoeffs)+',1)'''
   grocer_chfng=grocer_chfng+grocer_chg+'])'

   execstr(grocer_chfng)
 
   select grocer_optfunc
 
   case 'optim'
      execstr('[grocer_sigu,grocer_beta,g] = optim(grocer_func'+grocer_opt_optim('optim ineq')+',grocer_a'+grocer_opt_optim('optim')+')');
 
   case 'optimg'
      [grocer_sigu,grocer_beta,g] = optimg(grocer_func2,grocer_func,grocer_a,grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
 
   else
      error('not an available optimization function: '+grocer_optfunc)
 
   end
 
   grocer_grad=zeros(grocer_nobs,grocer_ncoeffs)
   for grocer_i=1:grocer_ncoeffs
       execstr(grocer_indeqj_namecoeff(grocer_i)+'=grocer_beta('+string(grocer_i)+')');
   end
 
   for grocer_i=1:grocer_ncoeffs
      execstr('grocer_ts='+grocer_derivj(grocer_i))
      grocer_start_date_i=grocer_ts('dates')(1)
      grocer_grad(:,grocer_i)=grocer_ts('series')(evstr(grocer_dates_estim)-grocer_start_date_i+1)
   end
 
   execstr('grocer_ts = -('+grocer_eq4func+')')
   execstr('resid=grocer_ts(''series'')(['+grocer_dates_estim+']-'+string(grocer_dates(1)-1)+')')
 
   // add the usual output (tstat, dw,...)
   sige=grocer_sigu/(grocer_nobs-grocer_ncoeffs)
   vcovar=sige*invxpx(grocer_grad)
   tmp = sqrt(diag(vcovar));
   tstat=grocer_beta ./tmp
   ediff = resid(2:grocer_nobs)-resid(1:grocer_nobs-1)
   dw = ediff'*ediff/grocer_sigu
   df=grocer_nobs-grocer_ncoeffs
   pvalue=zeros(grocer_ncoeffs,1)
   for i=1:grocer_ncoeffs
      pvalue(i)=(1-cdft("PQ",abs(tstat(i)),df))*2
   end
 
   // store the results
   rnlsmod=tlist(['results';'meth';'model name';'namey';'namex';'prests';'nobs';...
   'nvar';'resid';'ser';'sigu';'sige';'vcovar';'dw';'beta';...
   'tstat';'pvalue';'prescte';'dropna';'bounds'],'nls',grocer_model('namemod'),...
   grocer_eqj,grocer_indeqj_namecoeff,%t,grocer_nobs,grocer_ncoeffs,resid,...
   sqrt(sige),grocer_sigu,sige,vcovar,dw,grocer_beta,tstat,pvalue,%f,grocer_dropna,grocer_boundsvar)
 
   execstr('result'+string(grocer_j)+'=rnlsmod')
   execstr('grocer_listout($+1)=result'+string(grocer_j))
 
   if grocer_prt then
      prt_nls(rnlsmod,%io(2))
   end
 
   if grocer_save(grocer_j) then
      for grocer_k=1:grocer_ncoeffs
         grocer_coeffs(grocer_indeqj_namecoeff(grocer_k))=grocer_beta(grocer_k)
      end
      grocer_model('coeffs')=grocer_coeffs
   end
   grocer_j=grocer_j+1
end
 
varargout=lstcat(list(grocer_model),grocer_listout)
 
endfunction
