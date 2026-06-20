function res=varwithfac(grocer_p,grocer_listy,grocer_ARF,grocer_MAF,varargin)
 
// PURPOSE: perform the estimation of a VAR models with
// factors as exogenous variables
// The model is:
// Y_t = sum{i=1:p}{A_i*Y_{t-i}}+sum{j=1:k}{lambda_j*F_t}+ui_t
// ARF(L)*F_t = MAF(L)*e_t
// ------------------------------------------------------------
// INPUT:
// * grocer_p = a scalar, the number of lags in the VAR
// * grocer_listy = a string (ny x 1) vector of names or a
//    list of ny names, ts or vectors
// * grocer_ARF =
//   - a (narf x 1) or (1 x narf) string vector of parameters
//   corresponding to the AR part of the factor process
//     . if the user does not give in the list of variable
//     arguments the option 'init=own', then the user can give
//     any value to grocer_ARF; only it size matters for the
//     estimation process
//    . if the user gives in the list of variable arguments the
//     option 'init=own', then the values given by the user are
//     used as starting values for the optimisation process
//    . the user must enter the empty matrix [] if she wants to
//      impose that the AR part is empty
//   - a list of p elements, each element of the preceding type,
//    and p is the # of factors to estimate
// * grocer_MAF = a (nmaf x 1) or (1 x nmaf) string vector of
//   parameters corresponding to the MA part of the factor
//   process or a list or p elements of this type
//   (with the same conventions as with grocer_ARF and the same
//    number of elements as for the AR part)
// * varargin = optional arguments that can be:
//   - 'init=own' if the user wants to enter her own starting
//     values
//   - 'Q=x' where x is a (ny+1 x ny+1) matrix of starting values
//     for the var-cov matrix of residuals (first the residual of
//     the factor ARMA process; note that for identification sake
//     (see manual for details) the variance of residual of the
//     factor ARMA process is fixed to the value given by the
//     user in Q or to 0.25 if the user does not give starting
//     values to Q
//   - 'loadings=x' where x is a (ny x 1)vector of starting values
//     for the loadings of the factor
//   - 'noprint' if the user does not want to print the estimation
//   results
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
// * res = the results typed list of the dynamic factor estimation
//   provided by the Kalman filter with:
//   - res('meth') = 'var with factor'
//   - res('y') = a (nobs x ny) matrix of observations
//   - res('nobs') = the # of observations
//   - res('ny') = the # of endogenous variables
//   - res('namey') = the (ny x 1) vector of names of the endogenous
//     variables
//   - res('fac') = the estimated common factor
//   - res('stud fac') = the studentized estimated common factor
//   - res('coeff') = the (nparam x 1) vector of estimated
//     parameters (exploded in the Phi, Q and H matrices)
//   - res('std') = the (nparam x 1) vector of standard errors
//     of the estimated parameters
//   - res('tstat') = the (nparam x 1) vector of t-stat
//     of the estimated parameters
//   - res('ARF') = the (1 x narf) vector corresponding to the
//     AR part of the factor process
//   - res('MAF') = the (1 x nmaf) vector corresponding to the
//     MA part of the factor process
//   - res('Phi') = the estimated Phi matrix of corresponding
//     state-measure Kalman problem
//   - res('H') = the estimated H matrix of corresponding
//     state-measure Kalman problem
//   - res('Q') = the estimated Q matrix of corresponding
//     state-measure Kalman problem
//   - res('R') = the estimated R matrix of corresponding
//     state-measure Kalman problem
//   - res('C') = the (constrained) C matrix of corresponding
//     state-measure Kalman problem
//   - res('D') = the estimated R matrix of corresponding
//     state-measure Kalman problem
//   - res('llike') = log-likelihood of the model
//   - res('grad') = gradient of the log-likelihood of the
//     model at the estimated parameters
//   - res('AIC') = the Akaike information criterium
//   - res('BIC') = the Schwarz information criterium
//   - res('E4OPTION') = the tlist of options needed to feed the
//     "e4" Kalman estimation
//   - res('prests') = a boolean indicating whether there are
//     ts in the regression
//   - res('bounds') = bounds of the estimation (if there are
//     ts in the regression)
//   - res('stdARF') = the (1 x narf) vector corresponding to the
//     AR part of the factor process
//   - res('stdMAF') = the (1 x nmaf) vector corresponding to the
//     MA part of the factor process
//   - res('stdPhi') = the estimated Phi matrix of corresponding
//     state-measure Kalman problem
//   - res('stdH') = the estimated H matrix of corresponding
//     state-measure Kalman problem
//   - res('stdQ') = the estimated Q matrix of corresponding
//     state-measure Kalman problem
//   - res('stdR') = the estimated R matrix of corresponding
//     state-measure Kalman problem
//   - res('stdD') = the estimated R matrix of corresponding
//     state-measure Kalman problem
//   - res('theta2mat') = a string vector, collecting the
//     commands that transform the vector of parameters into
//     the matrices of the Kalman filter
//   - res('neqs') = a scalar, the number of endogenous
//   - res('nlag') = a scalar, the number of lags in the VAR
//   - res('VAR nvar') = a scalar, the number of exogenous
//     in each equation of the VAR (factors included)
//   - res('VAR sigma') = a (neqs x neqs) matrix, the variance
//     the residuals of the VAR
//   - res('VAR ser') = a (neqs x 1) vector, the standard errors
//     of the residuals of the VAR
//   - res('VAR beta') = a (nvar x neqs) matrix, the estimated
//     coefficients of the VAR
//   - res('VAR tstat') = a (nvar x neqs) matrix, the Student
//     statistics of the coefficients of the VAR
//   - res('VAR pvalue') = a (nvar x neqs) matrix, the
//     corresponding p-values
//   - res('VAR rsqr') = a (neqs x 1) vector, the R-squared
//     of the equations of the VAR
//   - res('VAR rbar') = a (neqs x 1) vector, the adjusted
//     R-squared of the equations of the VAR
//   - res('VAR overallf' )= a (neqs x 1) vector, the F statictics
//     of nullity for all non-constant variables in the
//     equations of the VAR
//   - res('VAR pvaluef') = a (neqs x 1) vector, the
//     corresponding p-values
//   - res('VAR nx') = a (neqs x 1) vector, the number of
//     exogenous variables in the VAr (constant + factors)
//   - res('VAR namex') = a (nexo x 1) vector, the names of
//     exogenous variables in the VAr (constant + factors)
//   - res('VAR prescte') = %t (indicating the presence of
//     the constant in the VAR)
//   - res('VAR dw') = a (neqs x 1) vector, the Durbin-Watson
//     of the VAR equations
// ------------------------------------------------------------
// REFERENCE:
//  A. Monfort, J.-P. Renne, R. Rüffer, G. Vitale (2003):
// ""Is Economic Activity in the G7 synchronised? Common Shocks
// versus Spillover Effects", CEPR Discussion Paper, DP4119.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012-2013
// http://grocer.toolbox.free.fr/grocer.html
 
 
if typeof(grocer_ARF) == 'string' then
   grocer_ARF=list(grocer_ARF)
elseif typeof(grocer_ARF) == 'constant' then
   grocer_ARF=list(string(grocer_ARF))
elseif typeof(grocer_ARF) ~= 'list' then
   error(typeof(grocer_ARF)+' is not an admissible type for the AR part for the factors')
end
grocer_narf=length(grocer_ARF)
 
if typeof(grocer_MAF) == 'string' then
   grocer_MAF=list(grocer_MAF)
elseif typeof(grocer_MAF) == 'constant' then
   grocer_MAF=list(string(grocer_MAF))
elseif typeof(grocer_MAF) ~= 'list' then
   error(typeof(grocer_MAF)+' is not an admissible type for the AR part for the factors')
end
grocer_nmaf=length(grocer_MAF)
 
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',2*%eps,1000',1e-5)
grocer_dropna=%f
grocer_prt=%t
grocer_initown=%f
 
// separate from the list of variable arguments the list of
// exogenous variables and 'noprint' or 'dropna' if the user has
// given one of these arguments
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argis=strsubst(grocer_argi,' ','')
      grocer_indeq=strindex(grocer_argis,'=')
      if isempty(grocer_indeq) then
         select grocer_argi
         case 'noprint' then
            grocer_prt=%f
            varargin(grocer_i)=null()
         case 'dropna' then
            grocer_dropna=%t
            varargin(grocer_i)=null()
         end
      else
         grocer_startargi=part(grocer_argis,1:grocer_indeq-1)
         if grocer_startargi == 'optfunc' then
             grocer_optfunc=part(grocer_argi,grocer_indeq+1:length(grocer_argi))
            varargin(grocer_i)=null()
         elseif grocer_startargi == 'opt_nelmead' then
             grocer_opt_optim('nelmead')=part(grocer_argi,grocer_indeq+1:length(grocer_argi))
            varargin(grocer_i)=null()
         elseif grocer_startargi == 'opt_optim' then
            grocer_opt_optim('optim')=part(grocer_argi,grocer_indeq+1:length(grocer_argi))
            varargin(grocer_i)=null()
         elseif grocer_startargi == 'opt_optim_ineq' then
            grocer_opt_optim('optim ineq')=part(grocer_argi,grocer_indeq+1:length(grocer_argi))
            varargin(grocer_i)=null()
         elseif grocer_startargi == 'opt_convg' then
             execstr('grocer_opt_optim(''convg'')='+part(grocer_argi,grocer_indeq+1:length(grocer_argi)))
            varargin(grocer_i)=null()
         elseif part(grocer_argi,1:4) == 'init' then
            grocer_initown=%t
            varargin(grocer_i)=null()
         end
      end
   end
end
 
[grocer_e4_y,grocer_e4_namey,grocer_e4_prests,grocer_boundsvarb]=...
   explone(grocer_listy,[],'endogenous',%t,grocer_dropna,%f,grocer_p)
 
grocer_namexos=['const' ; grocer_e4_namey+'(t-1)']
for i=2:grocer_p
   grocer_namexos=[grocer_namexos ; grocer_e4_namey+'(t-'+string(i)+')']
end
grocer_e4_zeps = sqrt(%eps)
grocer_e4_deps = .00000001;
[grocer_e4_T,grocer_e4_m]=size(grocer_e4_y)
grocer_e4_r=grocer_e4_m*grocer_p+1
grocer_e4_delta=sqrt(%eps)
//ps = 1e-10
grocer_e4_deps = .00000001;
grocer_e4_MV = 1;
grocer_theta2ss=theta2ssss
 
grocer_e4_userflag=0
grocer_e4_u0=[]
// define the value of endogenous variables as they are used by function lfmod_gmod_103
grocer_e4_z1=grocer_e4_y(grocer_p+1:grocer_e4_T,:)
grocer_e4_z2=ones(grocer_e4_T-grocer_p,1)
grocer_e4_z3=mlagb(grocer_e4_y,grocer_p)
grocer_e4_z2=[grocer_e4_z3(grocer_p+1:grocer_e4_T,:) grocer_e4_z2]
grocer_e4_z=[grocer_e4_z1 grocer_e4_z2 ]
grocer_e4_T=grocer_e4_T-grocer_p
 
// generate the matrices of the state-measure representation
[Phi,Gam,E,H,D,C,Q,S,R,p0,q0]=varwithfac2kalm(grocer_p,grocer_e4_y,grocer_ARF,grocer_MAF,grocer_initown,varargin(:))
[Phi,H,Q,R,D]=varwithfac_init(grocer_p,grocer_e4_z1,grocer_e4_z2,grocer_ARF,grocer_MAF,Phi,H,Q,R,D,grocer_optfunc,grocer_opt_optim)
grocer_E4OPTION=sete4opt('vcond=lyap','econd=zero','var=fac');
[grocer_e4_theta,grocer_e4_theta2mat,grocer_e4_thetalab,grocer_e4param,grocer_e4_ineq,Phi,Gam,E,H,D,C,Q,S,R,mat2thet]=...
ss2param(Phi,Gam,E,H,D,C,Q,grocer_e4_r,grocer_e4_m,S,R)
 
select grocer_optfunc
 
case 'optim' then
   execstr('[f,theta,grad]  = optim(lfmod_gmod_103,grocer_e4_theta'+grocer_opt_optim('optim')+')');
 
case 'optimg' then
   [f,theta,grad] = optimg(lfmod_103,lfmod_gmod_103,grocer_e4_theta,grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
 
end
 
// transform the estimated vector of parameters into the Kalman filter matrices
[Phi,Gam,E,H,D,C,Q,S,R] = theta2ssss(theta,grocer_e4_theta2mat,'factorized');
 
ARF=list()
MAF=list()
Phic0=0
for i=1:grocer_narf
   ARFi=Phi(Phic0+1,Phic0+1:Phic0+p0(i))
   MAFi=Phi(Phic0+1,[Phic0+p0(i)+1:Phic0+p0(i)+q0(i)])
   corrv_ar=1
   corrv_ma=1
   // transform the roots in the AR and MA parts into their stable equivalents
   if ~isempty(grocer_ARF(i)) then
     if isnum(grocer_ARF(i)) then
         [ARFi,corrv_ar]=transf_roots(-ARFi)
      end
   end
   if ~isempty(grocer_MAF(i)) then
      if isnum(grocer_MAF(i)) then
         [MAFi,corrv_ma]=transf_roots(MAFi)
      end
   end
   ARF(i)=-ARFi'
   MAF(i)=MAFi'
   // return the transformed ARF and AMF values to the Phi matrix
   // and the transformed loadings to H
   Phi(Phic0+1,Phic0+[1:p0(i)+q0(i)])=[-ARFi MAFi]
   H(:,Phic0+1)=H(:,Phic0+1)*sqrt(corrv_ar/corrv_ma)
   Phic0=Phic0+p0(i)+q0(i)
end
 
indi=sum(p0)+sum(q0)
indj=indi
li=indi+1
ary=list()
 
// calculate the smoothed variables into the matrices of the state-measure reprensentation
[x_T,P_T,z_T]=smooth_e4(theta,grocer_e4_theta2mat,grocer_e4_z,[])
// calculate standard errors, ...
grocer_E4OPTION('var')='unfactorized'
execstr(mat2thet)
grocer_e4param.Q=grocer_e4param.Q^2
 
[std,corrm,varm,Im] = imod(theta,grocer_e4_theta2mat,grocer_e4_z,0);
tstat=theta ./ std
AIC = 2*(f+grocer_e4param.np)/grocer_e4_T
BIC = (2*f+grocer_e4param.np*log(grocer_e4_T))/grocer_e4_T
 
p0c=cumsum(p0)
q0c=cumsum(q0)
fac=x_T(:,1+[0 p0c(1:$-1)+q0c(1:$-1)])
stud_fac=fac ./ (sqrt(diag(varcov0(fac)))' .*. ones(grocer_e4_T,1))
 
n1=1
stdARF=list()
stdMAF=list()
for i=1:grocer_narf
   n2=n1-1+size(ARF(i),1)
   stdARF(i)=std(n1:n2)
   n1=n2+size(MAF(i),1)+1
   stdMAF(i)=std(n2+1:n1-1)
end
stdPhi=std(1:n1)
 
n2=n1+grocer_narf*grocer_e4_m-1
stdH=matrix(std(n1:n2),grocer_e4_m,grocer_narf)
 
n1=n2+1
nQ=size(Q,1)-1
stdQ=std(n1:n1+nQ-1)
 
n1=n1+nQ
nR=size(R,1)
stdR=std(n1:n1+nR-1)
n1=n1+nR
 
stdD=matrix(std(n1:$),grocer_e4_m,-1)
// change the order of the coefficients to have the coefficients of the VAR in
// the first place
 
nvar=grocer_p*grocer_e4_m+1+grocer_narf
rsqr=zeros(grocer_e4_m,1)
rbar=zeros(grocer_e4_m,1)
overallf=zeros(grocer_e4_m,1)
pvaluef=zeros(grocer_e4_m,1)
DW=zeros(grocer_e4_m,1)
 
ym=mean0(grocer_e4_y,'r')
 
VAR_coeff=[D' ; H']
VAR_tstat=[D' ; H']./[stdD' ; stdH']
VAR_pvalue=0*VAR_tstat
for i=1:size(VAR_pvalue,'*')
   VAR_pvalue(i)=(1-cdft("PQ",abs(VAR_tstat(i)),grocer_e4_T-nvar))*2
end
 
resid=grocer_e4_z1-grocer_e4_z2*D'-fac*H'
for i=1:grocer_e4_m
   dym=grocer_e4_y(:,i)-ym(i)
   rsqr2 = dym'*dym;
   resid_i=resid(:,i)
   sigu=resid_i'*resid_i
   rsqr(i)=1-sigu/rsqr2
   rbar(i)=1-sigu/rsqr2*(grocer_e4_T-1)/(grocer_e4_T-nvar)
   if rsqr(i) >= 1 | rsqr(i)<=0 then
      overallf(i)=%nan
      pvaluef(i)=%nan
   else
      overallf(i)=rsqr(i)/(1-rsqr(i))/(grocer_e4_T-1)*(grocer_e4_T-nvar)
      pvaluef(i)=1-cdff("PQ",overallf(i),grocer_e4_T-1,grocer_e4_T-nvar)
   end
   ediff = resid_i(2:grocer_e4_T)-resid_i(1:grocer_e4_T-1)
   DW(i)= ediff'*ediff/sigu
 
end
 
if grocer_narf > 1 then
   namex=['const' ; 'factor # '+string(1:grocer_narf)']
else
   namex=['const' ; 'factor ']
end
 
// store the estimation results in a results tlist
res=tlist(['results';'meth';'y';'nobs';'ny';'namey';'fac';'stud fac';'coeff';...
'std';'tstat';'ARF';'MAF';'Phi';'H';'Q';'R';'C';'D';...
'llike';'grad';'AIC';'BIC';'E4OPTION';'prests';'p0';'q0';...
'stdARF';'stdMAF';'stdPhi';'stdH';'stdQ';'stdR';'stdD';'theta2mat';'e4param';...
'neqs';'nlag';'VAR nvar';'VAR sigma';'VAR ser';...
'VAR beta';'VAR tstat';'VAR pvalue';'VAR rsqr';'VAR rbar';'VAR overallf';...
'VAR pvaluef';'VAR nx';'VAR namex';'VAR prescte';'VAR dw'],...
'var with factor',grocer_e4_y,grocer_e4_T,grocer_e4_m,grocer_e4_namey,fac,stud_fac,...
theta,std,tstat,ARF,MAF,Phi,H,Q,R,C,D,...
-f,grad,AIC,BIC,grocer_E4OPTION,grocer_e4_prests,p0,q0,...
stdARF,stdMAF,stdPhi,stdH,stdQ,stdR,stdD,grocer_e4_theta2mat,grocer_e4param,...
grocer_e4_m,grocer_p,nvar,R,sqrt(diag(R)),...
VAR_coeff,VAR_tstat,VAR_pvalue,rsqr,rbar,overallf,...
pvaluef,1+grocer_narf,namex,%t,DW)
 
if grocer_e4_prests then
   res(1)($+1) = 'bounds'
   res('bounds')=grocer_boundsvarb
end
 
if grocer_prt then
   prt_varwithfac(res)
   pltfac_kalm(res)
end
 
endfunction
