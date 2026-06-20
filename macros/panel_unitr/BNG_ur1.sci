function res = BNG_ur1(Y,t_order,typeoflag,pmax,kmax,criteria,signif)
 
// PURPOSE: Bai and Ng (2004) test of unit root "A PANIC
// attack on unit root and cointegration", Econometrica,
// vol; 72, n°4, p.1127-1177.
// ------------------------------------------------------------
// INPUT:
// * Y = matrix (T,N) of observations
//      The data matrix can be unbalanced.
//      Missing Values must be specified as %nan
// * t_order = -1: no individual effect
//           0: individual effects and no trend (Default)
//           1: individual effects and time trends
// * typeoflag = the string:
//   - 'common' if the lag order is common to all variables (in
//   that case, the lag order is determined as in Bai and Ng,
//   2004)
//  -'individual' if the lag order is optimally chosen for each
//  variable
// * pmax = Maximum Lag Order for individual ADF regressions
// * kmax = The maximum number of common factors used to compute
//   the criterion functions for the estimation of r, the number
//   of common factors. It is not specified rmax=min(N,T)
// * criteria = Criteria used to estimate the number of common
//               factors
//            = 'IC1', 'IC2', 'IC3', 'PC1', 'PC2', 'PC3',
//              'AIC3', 'BIC3'
//            (see Bai and Ng (2002))
// * signif = significance level for the ADF individual t-tests
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// - res('meth') = 'BNG panel ur test'
// - res('y') = (T x k) matrix of data
// - res('t_order') = the trend order (-1, 0 or 1)
// - res('t_orderlit') = the trend order in plain english
// - res('ratio1') = Variance of idiosyncratic component divided
//   by the variance observed data (both in first differences)
// - res('ratio2') = Variance of residuals of common components
//   divided by variance on idiosyncratic component
// - res('ADFe') = Individual ADF statistics on idyosincratic
//   component : ADFe(i)
// - res('ADFe_pvalue') = Individual ADF statistics on
//   idyosincratic component : ADFe(i)
// - res('ADFe_pi') = Number of ADF terms in ADF tests on e(i,t)
// - res('pmax') = Maximum Lag Order for individual ADF
//   regressions on e(i,t)
// - res('ADFe_Ti') = Adjusted time dimension for ADF tests on
//   e(i,t)
// - res('nbfactors') = Estimated number of common factors
// - res('khat') = Estimated Numbers of Factor with IC1, IC2,
//   IC3, PC1, PC2, PC3, AIC3 and BIC3
// - res('criteria') = Criteria used to estimate the number of
//   common factors. Default value = 1 (IC1)
// - res('IC') = IC1, IC2 and IC3 Information criterions
//   for r=1,..,kmax
// - res('PC') = PC1, PC2 and PC3 Information criterions
//   for r=1,..,kmax
// - res('BIC3') = BIC3 Information criterion for k=1,..,kmax
//   (only BIC criteria function of N and T)
// - res('AIC3') = AIC3 Information criterion (only AIC criteria
//   function of N and T) : it tends to overestimate r
// - res('kmax') = Maximum number of common factors authorized
//       When there is one common factor (r=1):
//       **************************************
// - res('BNG.ADF_F') = ADF statistic on common factor: ADFf
// - res('BNG.ADF_F_pvalue') = Pvalue associated to ADFf
// - res('ADF_F_pi') = Number of ADF terms in ADF tests on
//   e(i,t)
// - res('ADF_F_Ti') = Adjusted time dimension for ADF tests
//   on e(i,t)
//       When there is more than one common factor (r>1):
//       ************************************************
// - res('MQc') = MQc(m) Statistics with critical values at 1%,
//   5% and 10% for m=r,..,1
// - res('MQf') = MQf(m) Statistics with critical values at 1%,
//   5% and 10% for m=r,..,1
// - res('MQc_r1') = Number of Common Stochastic Trends at 1%,
//   5% and 10% (MQc Test)
// - res('MQf_r1') = Number of Common Stochastic Trends at 1%,
//   5% and 10% (MQf Test)
// - res('MQf_p') = Optimal lag order for the VAR(p) on dYc
//   (MQf test)
//       If t_order == 1:
//       ****************
// - res('PCe_Choi') = Pooled test standardized statistic
//  (Choi 2001) on idiosyncratic components e: N(0,1) under H0
// - res('PCe_Choi_critical') = Critical Values of the pooled
//   test statistic (Choi, 2001) at 1%, 5% and 10%
// - res('PCe_Choi_pvalue') = Pvalue Pooled test statistic
//  (Choi 2001)
// - res('PCe_MW') = Pooled test statistic (Maddala Wu 1999)
//  on idiosyncratic components e : X(2N) under H0
// - res('PCe_MW_critical') = Critical Values of the pooled
//   test statistic (Maddala Wu 1999) at 1%, 5% and 10%
// - res('PCe_MW_pvalue') = Pvalue Pooled test statistic
//   (Maddala Wu 1999)
// ------------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// uses the function Levin_Lin1 translated and adapted from a
// Matlab program by: C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
 
//------------------------
//--- Transformed Data ---
//------------------------
[T,N] = size(Y);
Y = Y -(ones(T,1) .*. mean0(Y,'r'));// Demean the data
X = Y(2:$,:) - Y(1:$-1,:);// Vector of First Order Differences
 
if t_order == 1 then
   X = X-(ones(T-1,1) .*. mean0(X,'r'));  // Demean the data in first differences (model with time trend)
   t_orderlit='Model with individual effets '
else
   t_orderlit='t_order without intercept and trend'
end;
 
ind_crit=find(['ic1' 'ic2' 'ic3' 'pc1' 'pc2' 'pc3' 'aic3' 'bic3'] == convstr(criteria))
 
//---------------------
//--- Balanced Data ---
//---------------------
if or(isnan(X)) then
   error(" Panel data must be balanced in Bai_Ng program")
end
 
//===================================================
//===================================================
//=== STEP 0 : Estimated Number of Common Factors ===
//===================================================
//===================================================
// Bai and Ng (2004), page 18, section 4 Monte Carlo Simulation
//
rhat = NbFactors(X,kmax);// Statistics in order to estimate the Number of Common Factors
r = rhat('khat')(ind_crit);// Estimated Number of Common Factors (IC1 is used)
 
//============================================
//============================================
//=== STEP 1 : Estimates of Common Factors ===
//============================================
//============================================
 
[U,S,V] = svd(X'*X);// Singular Value Decomposition of X''*X
LAMBDA = U(:,1:r)*sqrt(N);// Estimated loading matrix
f = X*LAMBDA/N;// Estimate of f = DF
FIT = f*LAMBDA';// Matrix of fitted values of X
Z = X-FIT;// Matrix of deviations z(i,t)
 
 
//===============================
//===============================
//=== STEP 2 : Test on e(i,t) ===
//===============================
//===============================
e = cumsum(Z,'r');// Estimate of e(i,t)
 
if typeoflag=='common' then
   pstar = ceil(4*(min(T)/100)^0.25)*ones(N,1);  // Lag order proposed by Bai and Ng
   ADF_e = ADF_Individual(e,-1,pstar,%nan,signif);  // ADF tests on idyosyncratique components e
 
else
   ADF_e = ADF_Individual(e,-1,%nan,pmax,signif);  // ADF tests on idyosyncratique components e
 
end;
 
Ratio1 = diag(varcov0(Z)) ./diag(varcov0(X));// Variance of idyosyncratic component divised by variance observed data (both in first differences)
Ratio2 = diag(varcov0(cumsum(f,'r')*LAMBDA')) ./diag(varcov0(e));// Variance of residuals of common components divised by variance on idyosyncratic component
 
//--------------------
//--- Pooled Tests ---
//--------------------
 
PCe_Choi = (-2*sum(log(ADF_e('pvalue')))-2*N)/sqrt(4*N);// Pooled test standardized statistic (Choi 2001) on idyosyncratique components e : N(0,1) under H0
PCe_MW=-2*sum(log(ADF_e('pvalue'))) // Pooled test statistic (Maddala Wu 1999) on idyosyncratique components e : X(2N) under H0
 
//===============================
//===============================
//=== STEP 3 : Test on F(m,t) ===
//===============================
//===============================
 
F = cumsum(f);// Estimate of F(m,t)
 
//====================
//=== Case 1 : r=1 ===
//====================
 
if r==1 then // Case 1 : one common factor
   if typeoflag=='common' then
      ADF_F = ADF_Individual(F,t_order,pstar(1));  // ADF tests on idyosyncratique components e
   else
      ADF_F = ADF_Individual(F,t_order,%nan,pmax);  // ADF tests on idyosyncratique components e
   end
end
 
//====================
//=== Case 1 : r>1 ===
//====================
 
// Critical Values for MQc (table 1, page 50)
 
Critical_MQc = [-20.151,-13.73,-11.022;
     -31.621,-23.535,-19.923;
     -41.064,-32.296,-28.399;
     -48.501,-40.442,-36.592;
     -58.383,-48.617,-44.111;
     -66.978,-57.04,-52.312];
 
// Critical Values for MQf (table 1, page 50)
 
Critical_MQf = [-29.246,-21.313,-17.829;
     -38.619,-31.356,-27.435;
     -50.019,-40.18,-35.685;
     -58.14,-48.421,-44.079;
     -64.729,-55.808,-55.286;
     -74.251,-64.393,-59.555];
 
if r > 1 then // Case 2 : more than one common factor
   Fc = F-(ones(T-1,1) .*. mean0(F,'r')) // Demeaned Common Factor Components
   p_star = zeros(r,1); // Optimal lag order for VAR in MQf(m)
   for m = r:-1:1
      Omega = (Fc'*Fc)/(T^2);  // Matrix (r,r) T-2*sum[Fc(t)*Fc(t)'']
      [Vm,Dm] = spec(Omega);  // Eigenvalues and eigenvectors of Omega
      [Dm,ind] = gsort(diag(Dm),'g','i')
      Vm=Vm(:,ind)
      Yc = Fc*Vm(:,r-m+1:r);  // Matrix (T-1,m) of estimates Yc(t)
 
   //========================
   //=== Statistic MQc(m) ===
   //========================
 
      coef_VAR1 = [ones(T-2,1),Yc(1:$-1,:)]\Yc(2:$,:);  // Estimated Parameters of VAR(1)
      Res_VAR1 = Yc(2:$,:)-[ones(T-2,1),Yc(1:$-1,:)]*coef_VAR1;  // Residuals of VAR(1)
      J = 4*(ceil(min(N,T)/100)^(1/4));  // Troncature Lag
      K = 1-(1:J)'/(J+1);  // Bartlett Kernel
      SIG1 = zeros(m,m);  // One sided long run variance
 
      for j = 1:J // One sided long run variance
         SIG1=SIG1+(Res_VAR1(1:$-j,:)'*Res_VAR1(j+1:$,:)/T)*K(j)
      end
 
      PHIc = 0.5*(Yc(2:$,:)'*Yc(1:$-1,:)+Yc(1:$-1,:)'*Yc(2:$,:)-T*(SIG1+SIG1'))...
                 *inv(Yc(1:$-1,:)'*Yc(1:$-1,:));
      [V_PHIc,D_PHIc] = spec(PHIc);  // Eigenvalues and eigenvectors of PHIc
      MQc(m,1) = T*(min(real(diag(D_PHIc)))-1)  // Statistic MQc(m)
 
   //========================
   //=== Statistic MQf(m) ===
   //========================
 
      dYc = Yc(2:$,:)-Yc(1:$-1,:)
 
   //----------------------------------------
   //--- Lag Selection for the VAR on DYc ---
   //----------------------------------------
 
      npoint = 3;
      pmaxV = ceil((T-(npoint+2))/(npoint*m+1));  // Max lag order wich ensures nbpoints observations for each parameter
      Xreg = [ones(T-3,1),dYc(1:$-1,:)];  // Matrix of Regressors for a VAR(1)
      SC = zeros(pmaxV,1);  // Schwarz Information criterion
 
      for indic_p = 1:pmaxV
         coef_VAR = ols0(dYc(1+indic_p:$,:),Xreg);  // Estimated Parameters of VAR(p)
         res_VAR = dYc(1+indic_p:$,:)-Xreg*coef_VAR  // Residual of VAR(p)
         Ta = size(res_VAR,1);  // Adjusted size
         l = -((m*Ta)/2)*(1+log(2*%pi))-(Ta/2)*log(det((res_VAR'*res_VAR)/Ta));  // Log-Likelihhod of the VAR(p)
         ncoef = m*(1+indic_p*m);  // Number of Coefficients in VAR(p)
         SC(indic_p,1) = -(2*l)/Ta+(ncoef*log(Ta))/Ta;  // Schwarz Information criterion
         Xreg = [Xreg(2:$,:),dYc(1:$-1-indic_p,:)];  // Matrix of Regressors for a VAR(p+1)
      end
 
      [SC_star,p_star_m] = min(SC);  // Optimal Lag = p_star
      p_star(m)=p_star_m
 
   //------------------------------------------
   //--- Estimate of the VAR(p_star) on dYc ---
   //------------------------------------------
 
      Xreg = [ones(T-3,1),dYc(1:$-1,:)];  // Matrix of Regressors for a VAR(1)
      Yclag = [ones(T-2,1),Yc(1:$-1,:)];  // Matrix of Lagged Values of Yc
 
      for indic_p = 2:p_star(m,1)
         Xreg = [Xreg(2:$,:),dYc(1:$-1-(indic_p-1),:)];  // Matrix of Regressors for a VAR(p+1)
         Yclag = [Yclag(2:$,:),Yc(1:$-1-(indic_p-1),:)];
      end
 
      coef_VAR = ols0(dYc(1+p_star(m,1):$,:),Xreg);  // Estimated Parameters of VAR(p*)
 
   //--------------------------------
   //--- Filtered Components f(t) ---
   //--------------------------------
 
      yc = Yc(1+p_star(m):$,:)-Yclag*coef_VAR  // Filtered Common Components
      PHIf = (yc(2:$,:)'*yc(1:$-1,:)+yc(1:$-1,:)'*yc(2:$,:))*inv(yc(1:$-1,:)'*yc(1:$-1,:));
      [V_PHIf,D_PHIf] = spec(PHIf);  // Eigenvalues and eigenvectors of PHIc
      MQf(m) = T*(min(real(diag(D_PHIf)))-1);  // Statistic MQf(m)
 
   end
 
 //------------------------------------------
 //--- Number of Common Stochastic Trends ---
 //------------------------------------------
 
   if r < 7 then
      r1_MQc = r-sum(cumprod(MQc .*. ones(1,3) < Critical_MQc(r:-1:1,:)))  // Number of Common Stochastic Trends at 1%, 5% and 10% (MQc Test)
      r1_MQf = r-sum(cumprod(MQf .*. ones(1,3) < Critical_MQf(r:-1:1,:)))  // Number of Common Stochastic Trends at 1%, 5% and 10% (MQf Test)
   else
      r1_MQc = %nan;
      r1_MQf = %nan;
   end
 
end;
 
 
//===============
//===============
//=== RESULTS ===
//===============
//===============
 
res=tlist(['results';'meth';'y';'t_order';'t_orderlit';'ADFe';'ratio1';...
'ratio2';'nbfactors';'khat';'criteria';'IC';'PC';'BIC3';'AIC3';'kmax'],...
'BNG panel ur test',Y,t_order,t_orderlit,ADF_e('tstat'),Ratio1,...
Ratio2,r,rhat('khat'),criteria,rhat('IC'),rhat('PC'),rhat('BIC3'),rhat('AIC3'),kmax)
 
if r==1 then                                                   // Case of r=1
   res(1)($+1)='ADF_F'
   res(1)($+1)='ADF_F_pvalue'
   res(1)($+1)='ADF_F_pi'
   res(1)($+1)='ADF_F_Ti'
   res('ADF_F')=ADF_F('tstat');                                          // Individual ADF statistics on common factor  : ADFf
   res('ADF_F_pvalue')=ADF_F('pvalue');                                  // Pvalue associated to ADFf
   res('ADF_F_pi')=ADF_F('pi');                                          // Number of ADF terms in ADF tests on e(i,t)
   res('ADF_F_Ti')=ADF_F('Ti');                                          // Adjusted time dimension for ADF tests on e(i,t)
 
else
   res(1)($+1)='MQc'
   res(1)($+1)='MQf'
   res(1)($+1)='MQc_r1'
   res(1)($+1)='MQf_r1'
   res(1)($+1)='MQf_p'
   if r<7 then
      res('MQc')=[(r:-1:1)' MQc Critical_MQc(r:-1:1,:)];                // MQc(m) Statistics with critical values at 1//, 5// and 10// for m=r,..,1
      res('MQf')=[(r:-1:1)' MQf Critical_MQf(r:-1:1,:)];                // MQf(m) Statistics with critical values at 1//, 5// and 10// for m=r,..,1
 
   else
      res('MQc')=[(r:-1:1)' MQc [ones(r-6,3)*NaN ; Critical_MQc(6:-1:1,:)]];     // MQc(m) Statistics with critical values at 1//, 5// and 10// for m=r,..,1
      res('MQf')=[(r:-1:1)' MQf [ones(r-6,3)*NaN ; Critical_MQf(6:-1:1,:)]];     // MQf(m) Statistics with critical values at 1//, 5// and 10// for m=r,..,1
   end
 
   res('MQc_r1')=r1_MQc;                                             // Number of Common Stochastic Trends at 1//, 5// and 10// (MQc Test)
   res('MQf_r1')=r1_MQf;                                             // Number of Common Stochastic Trends at 1//, 5// and 10// (MQf Test)
   res('MQf_p')=p_star;                                              // Optimal lag order for the VAR(p) on dYc (MQf test)
 
end
 
 
if t_order==0 then // For model 1 the asymptotic distribution of ADFe is not DF (see Bai et Ng section 2.3)
   res(1)($+1)='ADFe_pvalue'
   res(1)($+1)='ADFe_pi'
   res(1)($+1)='pmax'
   res(1)($+1)='ADFe_Ti'
   res(1)($+1)='PCe_Choi'
   res(1)($+1)='PCe_Choi_critical'
   res(1)($+1)='PCe_Choi_pvalue'
   res(1)($+1)='PCe_MW'
   res(1)($+1)='PCe_MW_critical'
   res(1)($+1)='PCe_MW_pvalue'
   res('ADFe_pvalue') = ADF_e('pvalue'); // Individual ADF statistics on idyosincratic component : ADFe(i)
   res('ADFe_pi') = ADF_e('pi'); // Number of ADF terms in ADF tests on e(i,t)
   res('pmax') = pmax // Maximum lag order
   res('ADFe_Ti') = ADF_e('Ti'); // Adjusted time dimension for ADF tests on e(i,t)
   res('PCe_Choi') = PCe_Choi; // Pooled test standardized statistic (Choi 2001) on idyosyncratique components e : N(0,1) under H0
   res('PCe_Choi_critical') = [2.3263,1.6449,1.2816]; // Critical Values of the pooled test statistic (Choi, 2001) at 1%, 5% and 10%
   res('PCe_Choi_pvalue') = 1-cdfnor('PQ',PCe_Choi,0,1); // Pvalue Pooled test statistic (Choi 2001)
   res('PCe_MW') = PCe_MW; // Pooled test statistic (Maddala Wu 1999) on idyosyncratique components e : X(2N) under H0
   res('PCe_MW_critical') = cdfchi('PQ',[0.99,0.95,0.9],2*N*ones(1,3)); // Critical Values of the pooled test statistic (Maddala Wu 1999) at 1%, 5% and 10%
   res('PCe_MW_pvalue') = 1-cdfgam('PQ',PCe_MW/2,N,1); // Pvalue Pooled test statistic (Maddala Wu 1999)
 
end;
 
 
endfunction
