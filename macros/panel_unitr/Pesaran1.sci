function res = Pesaran1(Y,t_order,LagOrder,pmax,signif)
 
// PURPOSE: Pesaran (2007) unit root test "A simple panel
// unit root test in the presence of cross-section dependence",
// Journal of Applied Econometrics, John Wiley & Sons, Ltd.,
// vol. 22(2), pages 265-312.
// ------------------------------------------------------------
// INPUT:
// * Y = matrix (T,N) of observations
//      The data matrix can be unbalanced.
//      Missing Values must be specified as %nan
// * t_order = 0: individual effects and no trend (Default)
//           1: individual effects and time trends
// * Lag_Orders = - if Lag_Orders is not specified the program
//       determines the optimal lag order in individual ADF
//       regression with (pmax=12 or T/4) with Hall(1990)'s
//       method
//                - if Lag_Orders is specified by the user, it
//       must be a vector (N,1) or (1,N) with the optimal lags
//       for all the individuals of the panel.
// * pmax = Maximum Lag Order for individual ADF regressions
// * signif = Level of significance for the test on the kth lag
// order parameter
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// -  res('meth') = 'Pesaran'
// -  res('y') = (T x k) matrix of data
// -  res('t_order') = the trend order (-1, 0 or 1)
// -  res('t_orderlit') = the trend order in plain english
// -  res('CIPS') = CIPS statistic
// -  res('CIPS_star') = Truncated CIPS : CIPS* statistic
// -  res('CIPS_pvalue') = Pvalue of the CIPS statistic
// -  res('CIPS_star_pvalue') = Pvalue of the truncated CIPS
//    statistic
// -  res('CIPS_critical') = Critical Values of the CIPS
//    distribution at 1%, 5% and 10% for T and N sample
// -  res('CADF') = Individual CADF statistics
// -  res('CADF_pvalue') = Pvalues of the individual CADF
//    statistics (based on the CADF distribution)
// -  res('CADF_critical') = Critical Values of the CADF
//    distribution at 1%, 5% and 10% for T and N sample
// -  res('CADF_star') = Truncated individual CADF statistics
// -  res('CADF_star_critical') = Critical Values of the CADF
//    distribution at 1%, 5% and 10% for T and N sample
// -  res('CADF_star_pvalue') = Pvalues of the individual
//    truncated CADF_star statistics (based on the CADF
//    distribution)
// -  res('p') = Lag order in the CADF regressions (common for
//    all individuals)
// -  res('CP') = Chi-Squared test statistic CP
// -  res('CZ') = Inverse normal test statistic CZ
// ------------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
// C. Hurlin, 11 Juin 2004
// LEO, University of Orl�ans
 
 
global GROCERDIR;
 
if or(isnan(Y)) then
   error(" Panel data must be balanced in this program")
end;
 
//-------------------------------
//--- Data and Transformations---
//-------------------------------
[T,N] = size(Y);
 
resADF = ADF_Individual(Y,t_order,LagOrder*ones(N,1),pmax,signif);// Individual ADF REgression for get Lag Order ADF.pi and size ADF.Ti
 
dy = Y(2:$,:)-Y(1:$-1,:);// Matrix of First Order Differences
 
if isnan(LagOrder) then
   p = ceil(mean0(resADF('pi')));
else
   p = LagOrder;
end
 
DYlag = ones(T,N,p)*%nan;// Matrix of Lagged First Order Differences
 
for i = 1:p // Loop on lag order
   DYlag(i+2:T,:,i) = dy(1:$-i,:); // Matrix of Lagged First Order Differences
end
 
T = T-1-p;// Adjusted Time Dimension
dy = dy(p+1:$,:);// Matrix of First Order Differences (adjusted sample)
Y0 = Y(p+2:$,:)
Y1 = Y(p+1:$-1,:);// Matrices of y(i,t) and y(i,t-1)
DYlag = DYlag($-T+1:$,:,:);// Matrix of Lagged First Order Differences (adjusted sample)
 
 
//----------------------------------
//--- Individual CADF Statistics ---
//----------------------------------
 
DYmean = [mean0(dy,'c'),zeros(T,p)];// Matrix of means of dy(i,t), d(i,t-1).. d(i,t-p)
for j = 1:p // Loop on lag order p
   DYmean(:,j+1) = mean0((DYlag(:,:,j)),'c'); // Vector T,1) of the means of d(i,t-j)
end // End on loop on lag order p
 
CADF = zeros(N,1);// Individual CADF Statistics
 
for i = 1:N // Loop on the i units
   if p == 0 then // Case CADF(0)
      Xi = [mean0(Y1,'c'),mean0(dy','c')',Y1(:,i)]; // Matrix of Regressors of the CADF(0) model
   else // Case CADF(p) with p>0
      Xi = [matrix(DYlag(:,i,1:p),T,p),mean0(Y1,'c'),DYmean,Y1(:,i)]; // Matrix of Regressors of the CADF(p) model
 
   end; // End on the if condition
 
   select t_order // Switch on the deterministic component
 
   case 0 then
      Xi = [ones(T,1),Xi]; // Model with intercept
 
   case 1 then
      Xi = [ones(real(T),1),[1:T]',Xi]; // Model with intercept and trend
 
   end // End on select
 
   [coef_ind,xpxi] = ols0(dy(:,i),Xi); // Coefficients CADF Regression
   var_res = sum((dy(:,i)-Xi*coef_ind).^2)/(T-size(Xi,2)) // Residual Variance of CADF
   tstat_ind = coef_ind ./sqrt(diag(var_res*xpxi)); // Tstat CADF Regression
   CADF(i) = tstat_ind($,1); // Individual CADF statistic
 
end;
 
 
//-----------------------------------------------------
//--- Critical Values for CADF in t_order 1,2 and 3   ---
//--- Tables get with 50000 simulations             ---
//-----------------------------------------------------
load(GROCERDIR+'/data/tables_pesaran.dat')// Access to tables of Critical Values
execstr('critical=Critical_M'+string(t_order+2))
 
pvalue = zeros(max(size(CADF)),1) // Vector of individual pvalues on CADF statistics
[a,posi_T] = min((T-TT_pvalue).^2) // Approximated sample T size
[b,posi_N] = min((N-NN_pvalue).^2) // Approximated sample N size
critical_values = critical(posi_T,posi_N,1:size(proba,1)) // Vector of critcial values for N and T
 
for i = 1:N // Loop on individual units
   [c,posi_p]=min((CADF(i)-critical_values(:)).^2) // Position of the approximated critical value
   pvalue(i)=proba(posi_p)
end
 
 
//------------------------------------------------------
//--- Individual CADF truncated Statistics CADF_star ---
//------------------------------------------------------
 
execstr('E_CADF=E_CADF_Mod'+string(t_order+2))
execstr('V_CADF=V_CADF_Mod'+string(t_order+2))
 
eps = 0.000001;// Value of epsilon for dertermining K1 and K2
K1=-E_CADF(posi_T,posi_N)-cdfnor('X',0,1,eps/2,1-eps/2)*V_CADF(posi_T,posi_N).^0.5;
K2 = E_CADF(posi_T,posi_N)+cdfnor('X',0,1,1-eps/2,eps/2)*V_CADF(posi_T,posi_N).^0.5 // Value of K2
CADF_star = -K1.*(CADF<=-K1)+K2.*(CADF>=K2)+CADF.*((CADF>-K1)&(CADF<K2)) // Truncated individual CADF statistics
 
pvalue_star = zeros(max(size(CADF)),1);// Vector of individual pvalues on CADF_star statistics
for i = 1:N // Loop on individual units
   [c,posi_p] = min((CADF_star(i)-critical_values(:)).^2); // Position of the approximated critical value
   pvalue_star(i)=proba(posi_p) // Pvalue pvalues on CADF statistics for unit i
end;// End on the loop
 
//-------------------------------------
//--- Statistics CIPS and CIPS_star ---
//-------------------------------------
CIPS = mean0(CADF);// CIPS statistic
CIPS_star = mean0(CADF_star);// Mean of tuncated statictics
execstr('critical=CV_CIPS'+string(t_order+2))
CV_CIPS = critical(posi_T,posi_N,1:size(proba,1));// Vector of critical values of CIPS for N and T
 
[c,posi_p]=min((CIPS-CV_CIPS(:)).^2) // Position of the approximated critical value
pvalue_CIPS = proba(posi_p);// Pvalue of CIPS
 
[c,posi_p]=min((CIPS_star-CV_CIPS(:)).^2) // Position of the approximated critical value
pvalue_CIPS_star = proba(posi_p);// Pvalue of CIPS
 
//-----------------------------
//--- Stattistics CP and CZ ---
//-----------------------------
CP = -2*sum(log(pvalue));// Chi-Squared test statistic CP (not chi(2N) distributed with cross-section dependences)
CZ = (1/sqrt(N))*sum(cdfnor('X',zeros(N,1),ones(N,1),pvalue,1-pvalue));// Inverse normal test statistic CZ (not normally distributed with cross-section dependences)
 
//===============
//=== RESULTS ===
//===============
[d,posi_prob1]=min((proba-0.01).^2)// Position of the approximated critical value
[d,posi_prob5] = min((proba-0.05).^2) // Position of the approximated critical value
[d,posi_prob10] =min((proba-0.1).^2) // Position of the approximated critical value
critical_values=critical_values(:);  // Vector of critcial values for CADF for N and T
 
select t_order
 
case -1 then
   mod='No intercept and no trend ';
 
case 0 then
   mod='Model with individual effets ';
 
case 1 then
   mod='Model with individual effets and time trend ';
end
 
res=tlist(['results';'meth';'y';'t_order';'t_orderlit';'CIPS';'CIPS_star';...
'CIPS_pvalue';'CIPS_star_pvalue';...
'CIPS_critical';'CADF';'CADF_pvalue';'CADF_critical';'CADF_star';...
'CADF_star_pvalue';'p';'CP';'CZ'],...
'Pesaran',Y,t_order,mod,CIPS,CIPS_star,pvalue_CIPS,pvalue_CIPS_star,...
CV_CIPS([posi_prob1 posi_prob5 posi_prob10])',CADF,pvalue,...
critical_values([posi_prob1 posi_prob5 posi_prob10])',CADF_star,...
pvalue_star,p,CP,CZ)
 
endfunction
