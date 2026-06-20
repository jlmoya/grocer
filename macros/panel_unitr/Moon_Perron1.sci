function res = Moon_Perron1(Y,t_order,kmax,criteria,bandwidth,ker)
 
// PURPOSE: Moon and Perron (2003) test of unit root "Testing
// for a Unit Root in Panels with Dynamic Factors",
// Journal of Econometrics, Elsevier, vol. 122(1), p. 81-126,
// September.
// ------------------------------------------------------------
// INPUT:
// * Y = matrix (T,N) of observations
//      The data matrix can be unbalanced.
//      Missing Values must be specified as %nan
// * t_order = 0: individual effects and no trend (Default)
//           1: individual effects and time trends
// * kmax = The maximum number of common factors used to compute
//   the criterion functions for the estimation of r, the number
//   of common factors. It is not specified rmax=min(N,T)
// * criteria = Criteria used to estimate the number of common
//               factors
//            = 'IC1', 'IC2', 'IC3', 'PC1', 'PC2', 'PC3',
//              'AIC3', 'BIC3'
//            (see Bai and Ng (2002))
// * bandwidth = 'C' (Default) common lag troncature for the
//      Bartlett kernel (Levin and Lin 2003)
//               'N' for the Newey-West (1994)'s non parametric
//      bandwidth parameter
//               'A' for the Andrews (1991) automatic bandwidth
//      parametr selection with AR(1) structure
// * ker = 'B' for Bartlett (Defaut)
//          'QS' for Quadratic Spectral (not possible when
//      bandwidth = 'C')
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// -  res('meth') = 'Moon-Perron'
// -  res('y') = (T x k) matrix of data
// -  res('t_order') = the trend order (-1, 0 or 1)
// -  res('t_orderlit') = the trend order in plain english
// -  res('ta_star') = Statistic ta_star
// -  res('tb_star') = Statistic tb_star
// -  res('ta_pvalue') = Pvalue for the statistics ta_star
// -  res('tb_pvalue') = Pvalue for the statistics tb_star
// -  res('critical') = Normal Critical Values for the
//    statistics ta_star and tb_star at 1%, 5% and 10%
// -  res('rho_pool') = Pooled OLS estimator on initial
//    series
// -  res('rho_star') = Modified pooled OLS estimator using
//    de-factored data
// -  res('khat') = Estimated numbers of Factor with IC1,
//    IC2, IC3, PC1, PC2, PC3, AIC3 and BIC3
// -  res('criteria') = Criteria used to estimate the number
//    of common factors. Default value = 1 (IC1)
// -  res('IC') = IC1, IC2 and IC3 Information criterions
//    for r=1,..,rmax
// -  res('PC') = PC1, PC2 and PC3 Information criterions
//    for r=1,..,rmax
// -  res('BIC3') = BIC3 Information criterion for
//    k=1,..,kmax (only BIC criteria function of N and T)
// -  res('AIC3') = AIC3 Information criterion (only AIC
//    criteria function of N and T): it tends to
//    overestimate k
// -  res('kmax') = Maximum number of common factors
//    authorized
// -  res('h') = Values of individual bandwitch parameters
// -  res('LRV') = Estimated of Individual Long Run
//    Variances
// -  res('TLRV') = Estimated of Individual Temporal Long
//    Run Variances
// -  res('kernel') = kernel function used
// -  res('bandwidth') = Method to fix the bandwitch
//    parameter
// -------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
// C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
 
if or(isnan(Y)) then
   error (' Panel data must be balanced in this program')
end
 
ind_crit=find(['ic1' 'ic2' 'ic3' 'pc1' 'pc2' 'pc3' 'aic3' 'bic3'] == convstr(criteria))
 
//-------------------------------
//--- Data and Transformations---
//-------------------------------
[T,N] = size(Y)
T=T-1
 
select t_order // Remove Determistic Component
 
case -1 then
   Yc = Y; // Case of Model 1
 
case 0 then
   Yc = Y - (ones(T+1,1) .*. mean0(Y,'r')); // Case of Model 2 with individual effects
 
case 1 then
   reg = [ones(T+1,1),(1:T+1)']; // Case of Model 3 with individual effects and time trends
   Yc = Y-reg*inv(reg'*reg)*reg'*Y // Remove Determistic Component in model 3
 
end
 
Z = Yc(2:$,:);// Matrix of contemporeneaous observations (size T)
Z1 = Yc(1:$-1,:);// Matrix of lagged observations (size T)
 
//--------------------------------------
//--- Estimated Matrix of Projection ---
//--------------------------------------
 
rho_pool=(Z1(:)'*Z(:))/(Z1(:)'*Z1(:)) // Pooled OLS estimate of the common auto-regressive parameter rho
yhat=Z-rho_pool*Z1 // Residuals of OLS pooled estimates
NbFact = NbFactors(yhat,kmax);  ; // Determination of the number of factor with khat
khat = NbFact('khat')(ind_crit);// Estimated Number of Factor with IC(1)
 
if T<N then // Choice of normalization according the computional cost
   [vect,val] =spec(yhat*yhat') // Eigenvalues and eigenvectors of XX'
   [eigen,ind] = gsort(diag(val),'g','i')
   vectors=vect(:,ind)
   facts = sqrt(T)*vectors(:,T-khat+1:T)// Estimated Factors with kmax Factors
   loadings = (yhat'*facts)/T; // Estimated Matrix of Factor Loadings
   betahat = loadings*chol((loadings'*loadings)/N); // Rescaled Estimator of the Factor Loading
 
 
else // Case T>N
   [vect,val] =spec(yhat'*yhat) // Eigenvalues and eigenvectors of XX'
   [eigen,ind] = gsort(diag(val),'g','i')
   vectors=vect(:,ind)
   loadings=sqrt(N)*vectors(:,N-khat+1:N) // Estimated Matrix of Factor Loadings with khat Factors
   facts = (yhat*loadings)/N; // Estimated Factors
   betahat = (yhat'*yhat)*loadings/(N*T); // Rescaled Estimator of the Factor Loading
 
 
end
 
Ztild = Z-Z*betahat*inv(betahat'*betahat)*betahat' // Ztild=Z*Qbeta0 where Qbeta0 is the projection matrix (de-factored data)
Z1tild = Z1-Z1*betahat*inv(betahat'*betahat)*betahat' // Z1tild=Z(-1)*Qbeta0 where Qbeta0 is the projection matrix (de-factored data lagged)
residual = Ztild-rho_pool*Z1tild // Residual built as Ztild-rho_pool*Z1tild
 
//----------------------------------------------
//--- Means of Individual Long Run Variances ---
//----------------------------------------------
 
LRV_Indi = zeros(N,1);
TLRV_Indi = zeros(N,1);// Initialisation
 
h_indi = zeros(N,1);// Individual Bandwitch Parameters
 
for i = 1:N // Loop on individual indice
   LRV_func = longrun_variance(residual(:,i),ker,bandwidth); // Long Run Variance Procedure
   LRV_Indi(i) = LRV_func('omega') // Individual Long Run Variances
   TLRV_Indi(i)=0.5*(LRV_Indi(i)-sum(residual(:,i).^2)/T); // Individual Temporal Long Run Variances
   h_indi(i)=LRV_func('h') // Bandwitch parameter
 
end;// End of the loop on individual indice
 
LRV = mean0(LRV_Indi);// Mean of individual Long Run Variances
LRV2 = mean0(LRV_Indi .^2);// Mean of squared of individual long Run Variances
TLRV = 0.5*(LRV-sum(residual.^2)/(T*N)) // Mean of individual Temporal Long Run Variances = mean0(TLRV_Indi)
 
 
//-------------------------------------
//--- Modified Pooled OLS Estimator ---
//-------------------------------------
 
if t_order <= 0 then // Model with no Trend (t_order =-1 or 0)
   rho_star = (trace(Z1tild*Ztild')-N*T*TLRV)/trace(Z1tild*Z1tild'); // Modified pooled OLS estimator using de-factored data
   ta_star=sqrt(N)*T*(rho_star-1)/sqrt(2*LRV2/LRV^2); // Statistic ta_star
   tb_star=sqrt(N)*T*(rho_star-1)*sqrt(trace(Z1tild*Z1tild')/(N*T^2))*sqrt(LRV/LRV2) // Statistic tb_star
 
else // Model with Individual Effects and Trends (model 3)
   Bkn = -0.5*sum(residual .^2)/(T*N); // Bias term in model with incidental trends
   rho_star=(trace(Z1tild*Ztild')-N*T*Bkn)/trace(Z1tild*Z1tild') // Modified pooled OLS estimator using de-factored data
   ta_star=sqrt(N)*T*(rho_star-1)/sqrt(15/4*LRV2/LRV^2) // Statistic ta_star
   tb_star=sqrt(N)*T*(rho_star-1)*sqrt(trace(Z1tild*Z1tild')/(N*T^2))*sqrt(4*LRV/LRV2) // Statistic tb_star
 
end;
 
 
//===============
//=== RESULTS ===
//===============
 
t_orderlit = ["model without intercept nor trend ";...
"model with individual effects ";...
"model with individual effects and time trends "]
 
res=tlist(['results';'meth';'y';'t_order';'t_order_lit';'ta_star';'tb_star';...
'ta_pvalue';'tb_pvalue';'critical';'rho_pool';'rho_star';...
'criteria';'nbfactors';'IC';'PC';'BIC3';'AIC3';'kmax';'h';'LRV';'TLRV';...
'kernel';'bandwidth'],...
'Moon Perron',Y,t_order,t_orderlit(t_order+2),ta_star,tb_star,...
cdfnor('PQ',ta_star,0,1),cdfnor('PQ',tb_star,0,1),[-2.3263 -1.6449 -1.2816],...
rho_pool,rho_star,criteria,khat,NbFact('IC'),NbFact('PC'),NbFact('BIC3'),...
NbFact('AIC3'),kmax,h_indi,LRV_Indi,TLRV_Indi,ker,bandwidth)
 
 
endfunction
