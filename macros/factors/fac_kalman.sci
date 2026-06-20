function res=fac_kalman(grocer_e4_listy,grocer_ARF,grocer_MAF,grocer_listar,varargin)
 
// PURPOSE: perform the estimation of a dynamic factor model
// with the Kalman filter
// The model is:
// yi_t = lambda(i)*F_t+ui_t
// ARF(L)*F_t = MAF(L)*e_t
// ARi(L)*ui_t=ei_t
// ------------------------------------------------------------
// INPUT:
// * grocer_e4_listy = a string (ny x 1) vector of names or a
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
// * grocer_listar = a list of n vectors with:
//   - n: # of y variables
//   - each element of the list if the AR part of the residuals
//     of the ith y variable
//    (with the same conventions as with grocer_ARF)
// * varargin = optional arguments that can be:
//   - 'init=own' if the user wants to enter her own starting
//     values
//   - 'Q=x' where x is a (ny+1 x ny+1) matrix of starting values
//     for the var-cov matrix of residuals (first the residual of
//     the factor ARMA process, then the ny residuals of the
//     endogenous variables); note that for identification sake
//     (see manual for details) the variance of residual of the
//     factor ARMA process is fixed to the value given by the
//     user in Q or to 0.25 if the user does not give starting
//     values to Q
//   - 'loadings=x' where x is a (ny x 1)vector of starting values
//     for the loadings of the factor
//   - 'noprint' if the user does not want to print the estimation
//   results
//   - 'nap=x' with x = maximum # of calls to the function to
//     optimize (Scilab optim option; default=1000)
//   - 'niter=x' with x = maximum # of iterations
//     (Scilab optim option; default=1000)
// ------------------------------------------------------------
// OUTPUT:
// * res = the results typed list of the dynamic factor estimation
//   provided by the Kalman filter with:
//   - res('meth')= 'fac_kalman'
//   - res('y')= a (nobs x ny) matrix of observations
//   - res('nobs')= the # of observations
//   - res('ny')= the # of endogenous variables
//   - res('namey')= the (ny x 1) vector of names of the endogenous
//     variables
//   - res('fac')= the estimated common factor
//   - res('stud fac')= the studentized estimated common factor
//   - res('ARF')= the (1 x narf) vector corresponding to the
//     AR part of the factor process
//   - res('MAF')= the (1 x nmaf) vector corresponding to the
//     MA part of the factor process
//   - res('ary')= the list of ny vectors correspondingto the
//     AR processes of the residuals of the endogenous
//     variables
//   - res('Phi')= the estimated Phi matrix of corresponding
//     state-measure Kalman problem
//   - res('H')= the estimated H matrix of corresponding
//     state-measure Kalman problem
//   - res('Q')= the estimated Q matrix of corresponding
//     state-measure Kalman problem
//   - res('coeff')= the (nparam x 1) vector of estimated
//     parameters (exploded in the Phi, Q and H matrices)
//   - res('std')= the (nparam x 1) vector of standard errors
//     of the estimated parameters
//   - res('tstat')= the (nparam x 1) vector of t-stat
//     of the estimated parameters
//   - res('llike') = log-likelihood of the model
//   - res('grad') = gradient of the log-likelihood of the
//     model at the estimated parameters
//   - res('aic')= the Akaike information criterium
//   - res('bic')= the Schwarz information criterium
//   - res('E4OPTION')= the tlist of options needed to feed the
//     "e4" Kalman estimation
//   - res('prests') = a boolean indicating whether there are
//     ts in the regression
//   - res('bounds') = bounds of the estimation (if there are
//     ts in the regression)
// ------------------------------------------------------------
// REFERENCE:
// Doz C. and Lenglart F. (1999): "Analyse factorielle
// dynamique : test du nombre de facteurs, estimation et
// application à l'enquête de conjoncture dans l'industrie",
// Annales d'Economie et de Statistique, n° 54.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
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
 
if grocer_narf ~= grocer_nmaf then
   error('sizes of the AR and MA parts for the factors are not conformable')
end
 
grocer_dropna=%f
grocer_prt=%t
grocer_initown=%f
grocer_optfunc='optimg'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],'',',10*%eps,1e4',sqrt(%eps))
 
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
 
[grocer_e4_y,grocer_e4_namey,grocer_e4_prests,grocer_e4_boundsvarb]=...
explone(grocer_e4_listy)
grocer_e4_zeps = sqrt(%eps)
grocer_e4_deps = .00000001;
[grocer_e4_T,grocer_e4_m]=size(grocer_e4_y)
grocer_e4_ydm=grocer_e4_y-ones(grocer_e4_T,1).*.sum(grocer_e4_y,'r')/grocer_e4_T
grocer_e4_r=0
 
grocer_e4_delta=sqrt(%eps)
//ps = 1e-10
grocer_e4_deps = .00000001;
grocer_e4_MV = 1;
grocer_theta2ss=theta2ssss
 
grocer_e4_userflag=0
grocer_e4_u0=[]
// generate the matrices of the state-measure representation
[Phi,Gam,E,H,D,C,Q,S,R,p0,q0]=fac2kalm(grocer_e4_ydm,grocer_ARF,grocer_MAF,grocer_listar,grocer_initown,varargin(:))
 
if ~grocer_initown then
// provide good starting values
   [Phi,H,Q,R]=fac_kalm_init(grocer_e4_ydm,grocer_ARF,grocer_MAF,Phi,H,Q,R,grocer_listar)
end
 
grocer_E4OPTION=sete4opt('vcond=lyap','econd=zero','var=fac');
[grocer_e4_theta,grocer_e4_theta2mat,grocer_e4_thetalab,grocer_e4param,grocer_e4_ineq,Phi,Gam,E,H,D,C,Q,S,R,mat2thet]=ss2param(Phi,Gam,E,H,D,C,Q,grocer_e4_r,grocer_e4_m,S,R)
 
// define the value of endogenous variables as they are used by function lfmod_gmod_103
grocer_e4_z=grocer_e4_ydm
 
select grocer_optfunc
case 'optim'
   execstr('[likl1,theta,grad] = optim(lfmod_gmod_103'+grocer_opt_optim('optim ineq')+',grocer_e4_theta'+grocer_opt_optim('optim')+')');
 
case 'optimg'
   [likl1,theta,grad] = optimg(lfmod_103,lfmod_gmod_103,grocer_e4_theta,grocer_opt_optim('optim'),grocer_opt_optim('nelmead'),grocer_opt_optim('convg'));
else
   error('not an available optimization function: '+grocer_optfun)
end
 
llike=-likl1
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
 
// as above for the AR parts of the residuals for each endogenous variable
for i=indi+1:indi+grocer_e4_m
    nari=size(grocer_listar(i-indi),'*')
    if nari ~=0 then
       ARi=Phi(li,indj+1:indj+nari)
       corrv_ari=1
       if ~isempty(grocer_listar(i-indi)) then
          if isnum(grocer_listar(i-indi)) then
             [ARi,corrv_ari]=transf_roots(ARi)
             Phi(li,indj+1:indj+nari)=ARi
          end
       end
       ary($+1)=ARi'
       indQ=i-indi+grocer_narf
       Q(indQ,indQ)=Q(indQ,indQ)*corrv_ari
       indj=indj+nari
       li=li+nari
    else
       ary($+1)=[]
    end
end
 
// calculate the smoothed variables into the matrices of the state-measure reprensentation
[x_T,P_T,z_T]=smooth_e4(theta,grocer_e4_theta2mat,grocer_e4_z,[])
 
// calculate standard errors, ...
grocer_E4OPTION('var')='unfactorized'
execstr(mat2thet)
grocer_e4param.Q=grocer_e4param.Q^2
 
[std,corrm,varm,Im] = imod(theta,grocer_e4_theta2mat,grocer_e4_z,0);
tstat=theta ./ std
AIC = 2*(likl1+grocer_e4param.np)/grocer_e4_T
BIC = (2*likl1+grocer_e4param.np*log(grocer_e4_T))/grocer_e4_T
 
p0c=cumsum(p0)
q0c=cumsum(q0)
 
fac=x_T(:,1+[0 p0c(1:$-1)+q0c(1:$-1)])
//stud_fac=fac ./ (sqrt(diag(varcov0(fac)))' .*. ones(grocer_e4_T,1))
stud_fac=fac
 
n1=1
stdARF=list()
stdMAF=list()
stdary=list()
for i=1:grocer_narf
   n2=n1-1+size(ARF(i),1)
   stdARF(i)=std(n1:n2)
   n1=n2+size(MAF(i),1)+1
   stdMAF(i)=std(n2+1:n1-1)
end
 
for i=1:length(ary)
   n2=n1+size(ary(i),1)-1
   stdary(i)=std(n1:n2)
   n1=n2+1
end
 
n2=n1-1+grocer_e4_m*grocer_narf
stdH=std(n1:n2)
 
n1=n2+1
nQ=size(Q,1)-1
stdQ=std(n1:n1+nQ-1)
 
n1=n1+nQ
nR=size(R,1)
stdR=std(n1:$)
// store the estimation results in a results tlist
res=tlist(['results';'meth';'y';'nobs';'ny';'namey';'fac';'stud fac';'ARF';'MAF';'ary';'Phi';'H';'Q';...
'R';'C';'coeff';'std';'tstat';'llike';'grad';'aic';'bic';'E4OPTION';'prests';'p0';'q0';...
'stdARF';'stdMAF';'stdary';'stdH';'stdQ';'stdR';'theta2mat';'e4param'],...
'fac_kalman',grocer_e4_y,grocer_e4_T,grocer_e4_m,grocer_e4_namey,fac,stud_fac,ARF,MAF,ary,...
Phi,H,Q,R,C,theta,std,tstat,llike,grad,AIC,BIC,grocer_E4OPTION,grocer_e4_prests,p0,q0,...
stdARF,stdMAF,stdary,stdH,stdQ,stdR,grocer_e4_theta2mat,grocer_e4param)
 
if grocer_e4_prests then
   res(1)($+1) = 'bounds'
   res('bounds')=grocer_e4_boundsvarb
end
 
if grocer_prt then
   prtfac_kalm(res)
   pltfac_kalm(res)
end
 
endfunction
