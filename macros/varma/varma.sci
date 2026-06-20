function result=varma(grocer_e4_endo,grocer_AR,grocer_ARS,grocer_MA,grocer_MAS,grocer_v,grocer_s,varargin)
 
// PURPOSE: estimate a VARMA model using E4 functions
// the ARMA model has the following form:
// AR(L)*ARS(L^s) y = MA(L)*MAS(L^s) e [+G(L)X]
// where L is the lag operator, X is an optional vector of
// exogenous variables
// ------------------------------------------------------------
// INPUT:
// * grocer_e4_endo = either
//   - a matrix of strings, each one being the name of a
//   variable
//   - a (Txn) real matrix
//   - a ts
//   - a list of variables
//   each element could be a timeseries, a real vector,
//   a real matrix or a string (the name of a variable with
//   one of the types cited above, between quotes)
// * grocer_AR = the matrix [] or a (n x (n*p)) matrix
//   with:
//   - n = # of endogenous variables in grocer_e4_endo
//   - p = # of lags in the AR part of the process
// * grocer_ARS = the matrix [] or a (n x (n*ps)) matrix
//   with ps = # of lags in the seasonal AR part of the
//   process
// * grocer_MA = the matrix [] or a (n x (n*q)) matrix
//   with: q = # of lags in the AM part of the process
// * grocer_MAS = the matrix [] or a (n x (n*qs)) matrix
//   with qs = # of lags in the seasonal MA part of the process
// * grocer_v = a (nx1) vector if the user wants to impose
//   independence between resisduals or a (nxn) matrix in the
//   other case
// * grocer_s = a scalar representing the order of the
//   seasonality
// * varargin = optional arguments that can be:
//   - 'init=own' if the users wants to use as starting values
//   of the optimisation algorithm those given by her as entry
//   of varma
//   - 'exo=xxx' where xxx is the names of exogenous variables
//   which can take the form of a list or a vector of strings
//   - 'Gexo=xxx' where xxx is a vector of coefficients
//   corresponding to the exogenous variables
//   - 'delta=xx' where xx is the increment used to calculate
//   the numerical derivative of the log-likelihood
//   (default: sqrt(%eps)
//   - 'noprint' if the user does not want to print the results
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
// result = a results tlist with:
// - result('meth') ='varma'
// - result('y') = (nobs x nendo) matrix of values for the
//   endogenous variables
// - result('namey') = (nvar x 1) vector of names for the
//   endogenous variables
// - result('z') = (nobsx(nendo+nexo)) matrix of endogenous and
//   exogenous variables
// - result('nobs') = # of observations
// - result('nendo') = # of endogenous variables
// - result('nvar') = # of endogenous and exogenous variables
// - result('coeff') = (npx1) vector of estimated parameters
// - result('lab') = (npx1) string vector of names for the
//   estimated parameters
// - result('llike') = log-likelihood of the model
// - result('grad') = gradient of the log-likelihood of the
//   model at the estimated parameters
// - result('tstat') = Student's t of the coefficients
// - result('std') = (np x 1) Student's t of the coefficients
// - result('exact') = a boolean equal to %T indicating that
//   the covariance matrix of the estimated parameters has been
//   calculated with an exact formula
// - result('cov') = (np x np) covariance matrix
// - result('AIC') = Akaike information criterion
// - result('BIC') = Schwartz information criterion
// - result('theta2mat') = (npx1) string vector making the
//   transformation of the vector of estimated parameters into
//   the matrices of the problem
// - result('seas') = order of the seasonality
// - result('nexo') = # of exogenous variables in the model
// - result('AR') = the estimated AR part of the ARMA
// - result('MA') = the estimated MA part of the ARMA
// - result('ARS') = the estimated seasonal AR part of the
//   ARMA
// - result('MAS') = the estimated seasonal MA part of the
//   ARMA
// - result('V') = the estimated variance of residuals
// - result('G') = the estimated parameters of the exogenous
//   variables
// - result('e4param') = a structure, collecting the parameters of
//   the model
// - result('k') = maximum degree of the total AR, MA and G
//   parts
// - result('p') = # of AR parameters
// - result('P') = # of ARS parameters
// - result('q') = # of MA parameters
// - result('Q') = # of MAS parameters
// - result('lagexo') = # of lags applied to the vector of
//   exogenous variables
// - result('n') = n*nendo
// - result('type') = 1 = type of the e4 model
// - result('prests') = a boolean indicating whether there are
//   ts in the regression
// - result('E4OPTION') = the list of options used to perform
//   optimisation (see sete4opt for details)
// - result('yhat') = adjusted y
// - result('resid') = residuals of the VARMA
// - result('std resid') = standardized residuals of the VARMA
// - result('exo') = value of the exogenous variables (if any)
// - result('bounds') = bounds of the estimation (if there are
//   ts in the regression)
// - result('dropna') = boolean indicating if NAs have been
//   dropped
// - result('nonna') = vector indicating position of non-NA
//   values (if the option 'dropna' was active)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2004-2013
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_E4OPTION=sete4opt('vcond=lyap','var=fac');
grocer_e4_prt=%t
grocer_e4_prtopt=%f
grocer_e4_delta=sqrt(%eps)
grocer_e4_inite4=%t
grocer_fast=%t
grocer_theta2ss=theta2sss
grocer_iter=10000
grocer_e4_zeps = 1e-10
grocer_e4_deps = .00000001;
grocer_e4_userflag = 0
grocer_e4_mV = 0
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
',''ar'',1e4,1e4','',',2*%eps,1000',1e-5)
 
grocer_e4_nargin=length(varargin)
for grocer_e4_i=grocer_e4_nargin:-1:1
   select typeof(varargin(grocer_e4_i))
   case 'string' then
      grocer_e4_varaux=strsubst(varargin(grocer_e4_i),' ','')
      if grocer_e4_varaux == 'noprint' then
         grocer_e4_prt=%f
         varargin(grocer_e4_i)=null()
      elseif grocer_e4_varaux == 'prtopt' then
         grocer_e4_prtopt=%t
         varargin(grocer_e4_i)=null()
      elseif grocer_e4_varaux == 'init=own' then
         grocer_e4_inite4=%f
         varargin(grocer_e4_i)=null()
      elseif part(grocer_e4_varaux,1:5) == 'delta' then
         execstr('grocer_e4_'+grocer_e4_varaux)
         varargin(grocer_e4_i)=null()
      elseif part(grocer_e4_varaux,1:5) == 'iter=' then
         execstr('grocer_'+grocer_e4_varaux)
         varargin(grocer_e4_i)=null()
      elseif part(grocer_e4_varaux,1:6) == 'fast=' then
         execstr('grocer_fast='+part(grocer_e4_varaux,6:length(grocer_e4_varaux)))
         varargin(grocer_e4_i)=null()
      elseif part(grocer_e4_varaux,1:4) == 'exo=' then
         grocer_e4_exo=part(grocer_e4_varaux,5:length(grocer_e4_varaux))
         varargin(grocer_e4_i)=null()
      elseif part(grocer_e4_varaux,1:5) == 'Gexo=' then
         execstr('grocer_e4_'+varargin(grocer_e4_i))
         varargin(grocer_e4_i)=null()
      elseif grocer_e4_varaux == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_e4_i)=null()
      elseif part(grocer_e4_varaux,1:8) == 'optfunc=' then
         grocer_optfunc=part(grocer_e4_varaux,9:length(grocer_e4_varaux))
      elseif part(grocer_e4_varaux,1:12) == 'opt_nelmead=' then
         grocer_opt_optim('nelmead')=part(grocer_e4_varaux,13:length(grocer_e4_varaux))
      elseif part(grocer_e4_varaux,1:10) == 'opt_optim=' then
         grocer_opt_optim('optim ineq')=part(grocer_e4_varaux,11:length(grocer_e4_varaux))
      elseif part(grocer_e4_varaux,1:10) == 'opt_convg=' then
         execstr('grocer_opt_optim(''convg'')='+part(grocer_e4_varaux,11:length(grocer_e4_varaux)))
      end
    end
end
 
labels='grocer_'+['AR' 'ARS' 'MA' 'MAS']
for k=1:4
   execstr('obj='+labels(k))
   [nr,nc]=size(obj)
   select typeof(obj)
   case 'constant' then
      execstr(labels(k)+'=0*obj')
   case 'string' then
      for i=1:nr
         for j=1:nc
            if isempty(strindex(obj(i,j),'=')) & isempty(strindex(obj(i,j),'<')) ...
            & isempty(strindex(obj(i,j),'>')) then
               execstr(labels(k)+'('+string(i)+','+string(j)+')=''0''')
            end
         end
      end
   end
end
 
if exists('grocer_e4_exo','local') then
   if ~exists('grocer_e4_Gexo','local') then
      error('Gexo should have been entered along with exo')
   else
      grocer_E4OPTION('econd')='u0'
      grocer_e4_MV=1
      [grocer_e4_y0,grocer_e4_namey,grocer_e4_exo0,grocer_e4_namexo,grocer_e4_prests,grocer_e4_boundsvarb]=...
          explouniv(grocer_e4_endo,grocer_e4_exo,[],['endogenous' 'exogenous'],%t,grocer_dropna)
      [grocer_e4_T,grocer_e4_m] = size(grocer_e4_y0)
 
      [theta,x_T,P_T,ytT,grocer_e4_theta2mat,grocer_e4param,grocer_e4_lab,grocer_e4_vdiag,f,g,grocer_e4_u0,AR,ARS,MA,MAS,G,V,mat2thet]=...
         varma1(grocer_e4_y0,grocer_AR,grocer_ARS,grocer_MA,grocer_MAS,grocer_v,grocer_s,grocer_e4_inite4,...
         grocer_optfunc,grocer_opt_optim,grocer_e4_Gexo,grocer_e4_exo0,grocer_e4_namexo)
   end
 
else
   grocer_E4OPTION('econd')='zero'
   grocer_e4_MV=0
   grocer_e4_u0 =[]
   grocer_e4_exo=[]
   grocer_e4_exo0=[]
   [grocer_e4_y0,grocer_e4_namey,grocer_e4_prests,grocer_e4_boundsvarb]=...
   explone(grocer_e4_endo,[],'endogenous',%t,grocer_dropna)
   [grocer_e4_T,grocer_e4_m] = size(grocer_e4_y0)
 
   [theta,x_T,P_T,ytT,grocer_e4_theta2mat,grocer_e4param,grocer_e4_lab,grocer_e4_ineq,f,g,grocer_e4_u0,AR,ARS,MA,MAS,G,V,mat2thet]=...
   varma1(grocer_e4_y0,grocer_AR,grocer_ARS,grocer_MA,grocer_MAS,grocer_v,grocer_s,grocer_e4_inite4,...
   grocer_optfunc,grocer_opt_optim)
 
end
 
 
[AR,ARS,MA,MAS,V,G] = theta2arm2(theta,grocer_e4_theta2mat);
 
resid=grocer_e4_y0-ytT
std_resid=resid ./ (ones(grocer_e4_T,1) .*. sqrt(diag(V))')
 
grocer_e4_z=[grocer_e4_y0 grocer_e4_exo0]
 
grocer_E4OPTION('var')='unfactorized'
execstr(mat2thet)
 
[std,corrm,varm,Im] = imod(theta,grocer_e4_theta2mat,grocer_e4_z,0,1);
tstat=theta ./ std
AIC = 2*(f+grocer_e4param.np)/grocer_e4_T
BIC = (2*f+grocer_e4param.np*log(grocer_e4_T))/grocer_e4_T
 
 
result=tlist(['results';'meth';'y';'namey';'z';'nobs';'nendo';'nvar';'coeff';'lab';'like';'grad';...
'tstat';'std';'exact';'cov';'AIC';'BIC';'theta2mat';'seas';'nexo';'AR';'MA';'ARS';'MAS';...
'V';'G';'e4param';'k';'p';'P';'q';'Q';'lagexo';'n';'type';'prests';'E4OPTION';...
'yhat';'resid';'std resid'],...
'varma',grocer_e4_y0,grocer_e4_namey,grocer_e4_z,grocer_e4_T,grocer_e4_m,grocer_e4param.np,theta,...
grocer_e4_lab,-f,-g,tstat,std,%t,corrm,AIC,BIC,grocer_e4_theta2mat,grocer_e4param.s,grocer_e4param.r,...
AR,MA,ARS,MAS,V,G,grocer_e4param,grocer_e4param.k,grocer_e4param.p,grocer_e4param.P,...
grocer_e4param.q,grocer_e4param.Q,grocer_e4param.g,grocer_e4param.n,grocer_e4param.typ,...
grocer_e4_prests,grocer_E4OPTION,ytT,resid,std_resid)
 
if grocer_e4param.r then
   result(1)($+1)='exo'
   result('exo')=grocer_e4_exo
   result(1)($+1)='namexos'
   result('namexos')=grocer_e4_namexo
end
 
if grocer_e4_prests then
   result(1)($+1) = 'bounds'
   result('bounds')=grocer_e4_boundsvarb
end
 
if grocer_dropna then
   result(1)($+1)='nonna'
   result('nonna')=nonna
end
 
if grocer_e4_prtopt then
   prt_e4opt(result);
end
 
if grocer_e4_prt then
   prtvarma(result);
   pltvarma(result)
end
 
endfunction
 
