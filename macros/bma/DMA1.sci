function r=DMA1(y,z,x,lamda,alpha,nxmax,PRM,PRV,prefix_db)
 
// PURPOSE: Prediction using DMA
//---------------------------------------------------------
// INPUT:
// * y = a (nobs x 1) vector of endogenous variables
// * z = a (nobs x nZ) vector of compulsory exogenous variables
// * x = a (nobs x nx) vector of potential exogenous variables
// * lamda = a scalar, the forgetting factor for past
//   observations in the calculation of the time-varying
//   coefficients
// * alpha = a scalar, the forgetting factor of past
//   performance (a forecast k periods old have a weight
//   equal to k^alpha)
// * nxmax = the maximum # of non zero coefficients in any
//   model
// * PRM = a (nx+nz x 1) vector of prior expectation for the
//   coefficents of the x exogenous variables
// * PRV = a (nx+nz x 1) vector of prior values for the
//   variancce of these priors
// * prefix_db = the prefix of the database where big volume
//   data will be stored
//---------------------------------------------------------
// OUTPUT:
// r = a results tlist with:
// - r('meth') = 'DMA'
// - r('y') = (nobs x 1) vector of endogenous variables
// - r('x fixed') = (nobs x nZ) matrix of compulsory
//   exogenous variables
// - r('x variable') = (nobs x nZ) matrix of potential
//   exogenous variables
// - r('lamda') = a scalar, the forgetting factor for past
//   observations in the calculation of the time-varying
//   coefficients
// - r('alpha') = a scalar, the forgetting factor of past
//   performance (a forecast k periods old have a weight
//   equal to k^alpha)
// - r('nx max') = the maximum # of non zero coefficients in
//   any model
// - r('vars proba') = a (nx x nobs) matrix giving the
//   probability assigned to each variable at each date
// - r('global forecast') = a (nobs x 1) vector giving the
//   weighted forecast of all possible models
// - r('best model') = a (nobs x 1) vector giving the
//   index of the best model
// - r('best model forecast') = a (nobs x 1) vector giving the
//   forecast by the best model at each date
// - r('combinations') = a (K x (nZ+nx)) matrix
//   indicating for each model which variables are
//   in the model (1 value in corresponding column)
//   and which variables are not in the model (0 value
//   in corresponding column)
// - r('library') = name of the library where big volume
//   results are stored
// - r('n db') = # of corresponding databases
// - r('exp # of models') = (nobs x 1) vector of # of expected
//   models at each date
// - r('exp theta') = (nobs x (N+nZ)) vector of expected
//   values at each date for each variable
//---------------------------------------------------------
// REFERENCES:
// Koop and Korobilis, 2009, Forecasting
// Inflation using Dynamic Model Averaging
// http:www.rcfea.org/RePEc/pdf/wp34_09.pdf
//---------------------------------------------------------
// Copyright E. Dubois (2012)
// http://grocer.toolbox.free.fr/grocer.html
// translated and substantially adapted from a matlab
// programm by Dimitris Korobilis, University of Strathclyde
 
// Number of observations and dimension of X and Y
T = size(y,1);
 
// Number of exogenous predictors
N = size(x,2);
nZ = size(z,2)
one_nZ=ones(1,nZ)
 
// ======================| Form all possible model combinations |======================
// if z_t (the full model matrix of regressors) has N elements, all possible combinations
// are (2^N - 1), i.e. 2^N minus the model with all predictors/constan_t excluded (y_t = error)
 
K = 2^N;//Total number of models
dim_prob=K*(nZ+N+4)
 
if getversion("scilab")(1) < 6 then
//   N0=stacksize()
//   stacksize('max')
   Nmax=stacksize()
   Tmax=min(floor((Nmax(1)-(nZ+N/2)*nZ*K+N*K/2)/dim_prob*0.11),T)
   if Tmax  == 0 then
      error('too many variables for estimation; try to increase the stacksize')
   end
   Ndb_low=floor(T/Tmax)
   Ndb_upp=ceil(T/Tmax)
else
   Tmax=T
   Ndb_low=1
   Ndb_upp=1
end
 
ind_slash=strindex(strsubst(prefix_db,'/','\'),'\')
folder=part(prefix_db,1:ind_slash($))
if ~isdir(folder) then
   mkdir(folder)
end
SCIvers=getversion()
execstr('SCIvers_num='+part(SCIvers,8:10))
index_0and1=[ones(K,nZ) zeros(K,N)]
nmodels=1;
theta_pred_irep=zeros(K,N+nZ)
ncomb=1
S_t=zeros(nZ*K+N*K/2,nZ+N)
index_St=nZ
index_nmods=1
 
S_t(1:nZ,1:nZ)=diag(PRV(1:nZ))
n0=nZ
n_mods=[nZ ;zeros(K-1,1)]
for nn = 1:nxmax
   comb=combntns(1:N,nn,'nc')
   for jj = 1:size(comb,1)
      nmodels=nmodels+1
      // row k of index_0and1 contain 0 for variables not in the model
      // and 1 for varaibles in it
      ind_k=comb(jj,:)+nZ
      index_0and1(nmodels,ind_k)=1
      theta_pred_irep(nmodels,ind_k)=PRM(ind_k)
      nexos=sum(index_0and1(nmodels,:))
      range_st=[[1:nZ] ind_k]
      S_t(index_St+[1:nexos],range_st)=diag(PRV(range_st))
      index_St=index_St+nexos
   end;
   n_mods(index_nmods+[1:size(comb,1)])=nZ+nn
   index_nmods=index_nmods+size(comb,1)
end
 
X=[z x]
 
//----------------------------PRELIMINARIES---------------------------------
 
//========= PRIORS:
//-------- Now set prior means and variances (_prmean / _prvar)
theta_0_prmean=zeros(K,nZ+N)
 
// initial model probability for each individual model
prob_0_prmean = 1/K;//                      <----------------***** CHANGE *****
 
// Define forgetting factor(s):
inv_lamda = 1/lamda;
 
// Initialize matrices
//V_t = [0.1*ones(Nmax,1)  zeros(Nmax,T)] ;
 
//========= PRIORS:
//-------- Now set prior means and variances (_prmean / _prvar)
theta_0_prmean=zeros(nmodels,nZ+N)
 
// initial model probability for each individual model
prob_0_prmean = 1/nmodels;//                      <----------------***** CHANGE *****
 
// Define forgetting factor(s):
inv_lamda = 1/lamda;
 
// Initialize matrices
prob_pred = zeros(Tmax,nmodels);
y_t_pred = zeros(nmodels,Tmax)
//    V_t = [0.1*ones(nmodels,1)  zeros(nmodels,T)] ;
theta_update = zeros(nmodels,nZ+N,Tmax);
w_t = zeros(nmodels,1);
prob_update = zeros(Tmax,nmodels);
n_t=Tmax
if SCIvers_num >= 5.4 then
   for j=1:Ndb_low
      execstr('save('''+prefix_db+string(j)+'.dat'',''prob_pred'',''y_t_pred'',''theta_update'',''w_t'',''prob_update'',''n_t'')')
   end
else
   for j=1:Ndb_low
       execstr('save('''+prefix_db+string(j)+'.dat'',prob_pred,y_t_pred,theta_update,w_t,prob_update,n_t)')
   end
end
 
if Ndb_low ~= Ndb_upp then
   n_t=T-Tmax*Ndb_low
   prob_pred = zeros(n_t,nmodels);
   y_t_pred = zeros(nmodels,n_t)
   //    V_t = [0.1*ones(nmodels,1)  zeros(nmodels,T)] ;
   theta_update = zeros(nmodels,nZ+N,n_t);
   prob_update = zeros(n_t,nmodels);
   if SCIvers_num >= 5.4 then
      execstr('save('''+prefix_db+string(Ndb_upp)+'.dat'',''prob_pred'',''y_t_pred'',''theta_update'',''w_t'',''prob_update'',''n_t'')')
   else
      execstr('save('''+prefix_db+string(Ndb_upp)+'.dat'',prob_pred,y_t_pred,theta_update,w_t,prob_update,n_t)')
   end
end
clear prob_pred y_t_pred theat_update prob_update comb ;
 
y_t_DMA = zeros(T,1);
E_nmods=zeros(T,1)
 
sum_w_t=1
xRx2=zeros(K,20)
e_t = zeros(K,20)
w_t = zeros(K,1);
 
prob_update_irep=prob_0_prmean .^alpha * ones(1,nmodels)
V_t_irep=0.1*ones(nmodels,1)
theta=zeros(T,N+nZ)
 
//----------------------------- END OF PRELIMINARIES ---------------------------
 
// =============================Start now the big Kalman filter loop
irep=0
 
for db=1:Ndb_upp
   execstr('load('''+GROCERDIR+'\temp\db'+string(db)+'.dat'')')
 
   for t=1:n_t
      index_S_t=0
      irep=irep+1
      if pmodulo(irep,ceil(T ./20))==0 then
         write(%io(2),string(100*(irep/T))+"% completed",'(a)')
      end;
      sum_prob_a = sum(prob_update_irep .^alpha,2);  // this is the sum of the K model probabilities (all in the power of the forgetting factor ''a'')
      n0=1;
      for k = 1:nmodels // for 1 to nmodels competing models
        // -----------------------Predict
         ind_k=find(index_0and1(k,:) == 1)
         n_k=sum(index_0and1(k,:))
 
         R_mat = inv_lamda*S_t(index_S_t+[1:n_k],ind_k)
 
         x_t_irep_K=X(irep,ind_k)
         prob_pred(t,k) = (prob_update_irep(k) .^alpha+0.00000001) ./(sum_prob_a+nmodels*0.00000001);  // predict model probability, this is Eq. (15)
         // Now implememn_t individual-model predictions of the variable of in_terest
         y_t_pred(k,t) = x_t_irep_K*theta_pred_irep(k,ind_k)'; //one step ahead prediction
         e_t_k=y(irep)-y_t_pred(k,t)
 
         // -------------------------Update
         e_t(k,:) = [e_t(k,2:20) e_t_k]
 
         // We will need some products of matrices several times, which is better to define them
         // once here for computational efficiency
         xRx = (x_t_irep_K*R_mat)*x_t_irep_K'
         xRx2(k,:) = [xRx2(k,2:20) xRx]
 
         // Update V_t - measuremen_t error covariance matrix using rolling
         // moments estimator, see top of page 12
         // ****Note that in the revision we have an EWMA model for variance,
         // which needs a separate decay factor. See the revised paper for
         // more info.****
 
         if irep<20 then
            A_t = (1/irep)*(e_t(k,$) .^2-xRx);
         else
            A_t = (1/20)*sum(e_t(k,:) .^2 - xRx2(k,:));
         end;
 
         if A_t> 0 then // if the variance is positive keep it
            V_t_irep(k)= A_t;
         end;
 
         // Update theta[t] (regression coefficien_t) and its covariance
         // matrix S[t] (state equation covariance), see Equations (8) - (9)
         inv_mat = inv(V_t_irep(k)+xRx);
         x_R_mat=x_t_irep_K*R_mat
         x_R_mat_imat=x_R_mat'*inv_mat
         theta_pred_irep(k,ind_k)=theta_pred_irep(k,ind_k)+(x_R_mat_imat*e_t(k,$))'
         theta_update(k,ind_k,t) = theta_pred_irep(k,ind_k)
         S_t(index_S_t+[1:n_k],ind_k) = R_mat-(((R_mat*(x_t_irep_K)')*inv_mat)*x_t_irep_K)*R_mat; //#ok<*MINV>
 
         // Update model probability
         mod_variance = V_t_irep(k)+xRx;
         f_l = (1/sqrt((2*%pi)*mod_variance))*exp(-0.5*((e_t_k .^ 2)/mod_variance)); //normpdf(y_t(irep,:),mean,variance);
         w_t(k,t) = prob_pred(t,k)*real(f_l);
         n0=n0+n_k
         index_S_t=index_S_t+n_k
      end; // end cycling through all possible nmodels models
 
      // First calculate the denominator of Equation (16) (the sum of the w''s)
      sum_w_t = sum(w_t(:,t));
 
      // Then calculate the updated model probabilities
      prob_update_irep=w_t(:,t)' ./sum_w_t
      prob_update(t,:) = prob_update_irep
      // Now we have the predictions for each model & the associated model probabilities: Do DMA prediction
      y_t_DMA(irep)=y_t_DMA(irep)+prob_pred(t,:)*y_t_pred(:,t)
      E_nmods(irep)=E_nmods(irep)+prob_pred(t,:)*n_mods
      theta(irep,:)=prob_update_irep*theta_pred_irep
 
   end
   if SCIvers_num >= 5.4 then
      execstr('save('''+prefix_db+string(db)+'.dat'',''prob_pred'',''y_t_pred'',''theta_update'',''prob_update'',''n_t'')')
   else
      execstr('save('''+prefix_db+string(db)+'.dat'',prob_pred,y_t_pred,theta_update,prob_update,n_t)')
   end
end;
write(%io(2),' ','(a)')
write(%io(2),' ','(a)')
//***********************************************************
clear prod_pred y_t_pred theta_update prob_update sum_w_t w_t f_l mod_mean mod_variance e_t ;
 
// Find now the best models
g = zeros(K,T);
prob_variables=zeros(T,N)
max_prob=zeros(T,1)
best_model=zeros(T,1)
y_t_BEST = zeros(T,1);
 
ii=0
for db=1:Ndb_upp
 
   execstr('load('''+prefix_db+string(db)+'.dat'',''n_t'',''prob_update'',''y_t_pred'')')
   for t=1:n_t
      ii=ii+1
      g(:,ii)= prob_update(t,:)' ;
      [max_prob_t, best_model_t]=max(g(:,ii));
      max_prob(ii)=max_prob_t;
      best_model(ii)= best_model_t;
      y_t_BEST(ii) = y_t_pred(best_model(ii),t)
   end
   prob_variables((db-1)*Tmax+[1:n_t],:)= prob_variables((db-1)*Tmax+[1:n_t],:)+prob_update*index_0and1(:,nZ+1:nZ+N)
end;
 
r=tlist(['results';'meth';'y';'x fixed';'x variable';'lamda';...
'alpha';'nx max';'vars proba';...
'global forecast';'best model';'best model forecast';'combinations';...
'library';'n db';'exp # of models';'exp theta'],...
'DMA',y,z,x,lamda,alpha,nxmax,prob_variables,...
y_t_DMA,best_model,y_t_BEST,index_0and1,prefix_db,Ndb_upp,...
E_nmods,theta)
 
 
endfunction
