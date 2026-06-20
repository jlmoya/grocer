function res = Levin_Lin1(Y,t_order,LagOrders,pmax,bandwidth,ker,signif)
 
// PURPOSE: Levin an Lin (1992) Unit Root Tests on Panel Data
// Levin, Lin and Chu (2002), Journal of Econometrics
// ------------------------------------------------------------
// INPUT:
// * Y = matrix (T,N) of observations
//      The data matrix can be unbalanced.
//      Missing Values must be specified as %nan
// * t_order = -1: no individual effect
//           0: individual effects and no trend (Default)
//           1: individual effects and time trends
// * Lag_Orders = - if Lag_Orders is not specified the program
//       determines the optimal lag order in individual ADF
//       regression with (pmax=12 or T/4) with Hall(1990)'s
//       method
//                - if Lag_Orders is specified by the user, it
//       must be a vector (N,1) or (1,N) with the optimal lags
//       for all the individuals of the panel.
// * pmax = Maximum Lag Order for individual ADF regressions
// * bandwidth = 'C' (Default) common lag troncature for the
//      Bartlett kern (Levin and Lin 2003)
//               'N' for the Newey-West (1994)'s non parametric
//      bandwidth parameter
//               'A' for the Andrews (1991) automatic bandwidth
//      parameter selection with AR(1) structure
// * ker = 'B' for Bartlett (Defaut)
//          'QS' for Quadratic Spectral (not possible when
//      bandwidth = 'C')
// * signif = signification level for the ADF individual t-tests
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// -  res('meth') = 'Levin-Lin'
// -  res('y') = (T x k) matrix of data
// -  res('tstat') = (T x k) matrix of data
// -  res('critical') = Critical Values at 1%, 5% and 10% for
//    the N(0,1) distribution
// -  res('pvalue') = Pvalue for the corrected statistic
// -  res('rho') = Estimate of the common autoRegresive parameter
// -  res('var_rho') = Variance of the estimator of the common
//    autoRegresive parameter
// -  res('mu_star') = Mean Adjustement Factor
// -  res('sig_star') = Variance Adjustement Factor
// -  res('bandwidth') = Method to fix the bandwidth parameter
// -  res('kernel') = kernel function
// -  res('h') = Bandwicth parameter
// -  res('omega') = Individual Long run variances of first
//    differences
// -  res('si') = Individual Ratios of long run standard
//    deviation to the innovation SE
// -  res('pi') = Individual lag order in ADF regressions
// -  res('pmax') = Maximum lag order for ADF individual
//    regressions
// -  res('Ti1') = Auxiliary Regression 1: Adjusted individual
//    size, starting date and ending date
// -  res('Ti2') = Auxiliary Regression 1: Adjusted individual
//    size, starting date and ending date
// -  res('t_order') = the trend order (-1, 0 or 1)
// -  res('t_orderlit') = the trend order in plain english
// -  res('tstat_nc') = Non corrected t-statistic (if t_order == 1
//    only)
// -  res('pvalue_nc') = Pvalue for non corrected t-statistic
//    (if t_order == 1 only)
// -------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
// C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
 
//------------------------
//--- Transformed Data ---
//------------------------
[T,N] = size(Y)
exo=[]
 
select t_order // switch according determinitic structure
 
case -1 then
 
   // Mean Adjustment for t_order -1 without Individual Effects
   mu = [0.004,0.003,0.002,0.002,0.001,0.001,0.001,0,0,0,0,0,0]';
   sig = [1.049,1.035,1.027,1.021,1.017,1.014,1.011,1.008,1.007,1.006,1.005,1.001,1]';
 
case 0 then
   exo = ones(T,1)// Matrix of regressors (t_order 0)
   // Mean Adjustment for t_order 2 with Individual Effects
   mu = [-0.554,-0.546,-0.541,-0.537,-0.533,-0.531,-0.527,-0.524,-0.521,-0.52,-0.518,-0.509,-0.5]';
   sig = [0.919,0.889,0.867,0.85,0.837,0.826,0.81,0.798,0.789,0.782,0.776,0.742,0.707]';
 
case 1 then
   exo = [ones(T,1),(1:1:T)']; // Matrix of regressors (t_order 1)
   // Mean Adjustment for t_order 3 with Individual Effects and Time Trend
   mu = [-0.703,-0.674,-0.653,-0.637,-0.624,-0.614,-0.598,-0.587,-0.578,-0.571,-0.566,-0.533,-0.5]';
   sig = [1.003,0.949,0.906,0.871,0.842,0.818,0.78,0.751,0.728,0.71,0.695,0.603,0.5]';
 
end;
 
resADF = ADF_Individual(Y,t_order,LagOrders,pmax,signif);// Individual ADF REgression for get Lag Order ADF.pi and size ADF.Ti
 
//==========================================================
//=== STEP 1: Estimate of the Auto-Regressive Parameter ===
//==========================================================
 
//-----------------------------
//--- Auxiliary Regressions ---
//-----------------------------
e = ones(T,N)*%nan;// Residual of the First Auxiliary Regression
v = ones(T,N)*%nan;// Residual of the Second Auxiliary Regression
Tip1 = zeros(N,3);// Auxiliary Regression 1: Adjusted Size, starting dtae and ending date
Tip2 = zeros(N,3);// Auxiliary Regression 2: Adjusted Size, starting dtae and ending date
 
for i = 1:N
 
   //-------------------------------
   //--- Matrices of Regressors ---
   //-------------------------------
 
   y=Y(:,i)
   ai=resADF('debi')(i)
   bi=resADF('endi')(i)
   pi=resADF('pi')(i)
   Ti=bi-ai+1
   y=y(ai:bi)
   dy=y(2:Ti)-y(1:Ti-1)
   lXi=mlag(dy,pi)
   Y1=y(1+pi:Ti-1)
   Xi=[exo(1+pi:Ti-1) lXi(1+pi:Ti-1,:)];
 
   dy=dy(1+pi:Ti-1)
  //-----------------------------
  //--- Auxiliary Regressions ---
  //-----------------------------
 
   if t_order == -1 then // Case of t_order 1: non deterministic component
      e(2+pi+bi,i)=dy
      v(2+pi+bi,i)=Y1 // Second auxiliary regression
 
   else // Case of t_order 2 or 3 with deterministic component
      e(2+pi:bi,i)=dy-Xi*ols0(dy,Xi)
      v(2+pi:bi,i)=Y1-Xi*ols0(Y1,Xi)
 
   end;
 
end;
 
//----------------------------
//--- Normalized Residuals ---
//----------------------------
e_tild = e ./(resADF('sig')' .*. ones(T,1))
v_tild = v ./(resADF('sig')' .*. ones(T,1))// Normalized residual of equation 2
 
//------------------------------------------------
//--- Estimate of the AutoRegressive Parameter ---
//------------------------------------------------
vv = v_tild(~isnan(e_tild+v_tild));// Adjustement of the sample vtild residual
ee = e_tild(~isnan(e_tild+v_tild));// Adjustement of the sample etild residual
rho = vv\ee;// Estimated Auto-Regressive Parameter
 
//============================================================
//=== STEP 2: Estimate of Individual Ratios of Variances  ===
//============================================================
 
//-------------------------------------------------
//--- Estimate of Individual Long Run Variances ---
//-------------------------------------------------
omega = zeros(N,1);// Estimate of Individual Long Run Variances
T_tild = mean0(resADF('Ti')-resADF('pi'));// Mean of Individual Sample Sizes
q_indi = zeros(N,1);// Individual lag truncation parameter (Andrews or Newwey West)
q_common = 3.21*(T_tild^(1/3));// Common Lag of Troncature: Levin et Lin (2003)
 
for i = 1:N // Loop on individual Indices
   y=Y(:,i)
   ai=resADF('debi')(i)
   bi=resADF('endi')(i)
   pi=resADF('pi')(i)
   Ti=bi-ai+1
   y=y(ai:bi)
   z=y(2:Ti)-y(1:Ti-1)
 
   select t_order // switch given the deterministic structure
 
   case 0 then
      z = z-mean0(z) // First Order Differences individual i (t_order 0)
 
   case 1 then
      nz=size(z,1)
      Xdet = [ones(nz,1) [1:nz]']; // Deterministics Regressors (t_order 1)
      z = z-Xdet*ols0(z,Xdet); // First Order Differences individual i (t_order 1)
 
   end; // End on the switch
 
 //------------------------------------
 //--- Individual Lag of Troncature ---
 //------------------------------------
 
   if convstr(bandwidth) =='a' | convstr(bandwidth) =='n' then // Individual lag troncature
 
      LRV = longrun_variance(z,kern,convstr(bandwidth)); // Function LongRun_Variance
      omega = LRV('omega'); // Individual Long Run Variances
      q_indi(i)=LRV('h'); // Individual Bandwidth Parameters
 
 //------------------------------------------------------------------
 //--- Common lag troncature for the Bartlett kern (Levin Lin)  ---
 //------------------------------------------------------------------
 
   elseif convstr(bandwidth) == 'c' then // Common lag troncature for the Bartlett kern
      Ti = max(size(z)); // Adjusted Size for unit i
      q_indi = q_common; // Common bandwidth parameter
      x = (1:Ti-1)'/q_common; // Vector of j/h
      w = max(1-x,0) // Bartlett  kern
      gam_j = zeros(sum(w>0),1); // Vector of Autocovariances of z
 
      for j = 1:sum(w>0) // Loop for individual auto-covraiances
         gam_j(j)=sum(z(1+j:$) .* z(1:$-j))/Ti // Autocovariance of order j
      end; // End of Loop for individual auto-covraiances
 
      omega(i)=sum(z.^2)/Ti+ 2*sum(w(1:sum(w>0)) .* gam_j);  // Long run variance of res
 
    end; // End on if
 
end;// End on the Loop on individual Indices
 
//----------------------------------------
//--- Sn: Mean of Ratios of Variances ---
//----------------------------------------
Si = resADF('sig') ./sqrt(abs(omega));// Individual Ratios of long run standard deviation to the innovation SE
Sn = mean0(Si);// Mean of Si
 
 
//============================================================
//=== STEP 3: Estimate of Individual Ratios of Variances  ===
//============================================================
 
//-------------------------------------------------------
//--- Estimated variance of Residuals etild-rho*vtild ---
//-------------------------------------------------------
NTtild = max(size(vv));// Formulae equivalent to (T-1-mean0(ADF.pi))*N
var_eps = (1/NTtild)*sum((ee-rho*vv) .^2);// Estimated variance of Residuals etild-rho*vtild
var_rho = var_eps/sum(vv .^2);// Estimated Variance of Estimator rho
 
//---------------------------------
//--- Non Corrected t-statistic ---
//---------------------------------
tstat_nc = rho/sqrt(var_rho);// Non Corrected statistic
 
//-----------------------------------------------------------
//--- Adjustements Factors: Levin et Lin (2002), Table 2 ---
//-----------------------------------------------------------
TT = [25,30,35,40,45,50,60,70,80,90,100,250,1000]';
 
//-------------------------------
//--- Corrected t-statistique ---
//-------------------------------
[a,indic] = min((TT-NTtild/N) .^2);
Tadjusted = TT(indic);// Approximated Value of T for the Adjustement Factors
mu_star = mu(indic);// Mean Adjustement Factor
sig_star = sig(indic);// Variance Adjustement Factor
tstat = (1/sig_star)*(tstat_nc-NTtild*Sn*mu_star*sqrt(var_rho)/var_eps);// Corrected t-statistic
 
//===============
//=== RESULTS ===
//===============
 
pvalue = cdfnor('PQ',tstat,0,1);// Pvalue for the corrected statistic
if convstr(bandwidth) == 'c' then // Common lag troncature for the Bartlett kern
   bandwidth = "Common bandwidth parameter (Levin et Lin, 2002)"; // Method to fix the bandwidth parameter
   ker = "Bartlett kernel"; // kern function
   h = q_common; // Common bandwicth parameter
 
else
   bandwidth = LRV("bandwidth");  // Method to fix the bandwidth parameter
   ker = LRV("kernel");  // kern function
   h = q_indi;  // Individual bandwicth parameter
 
end;
 
t_orderlit = ["model without intercept nor trend ";...
"model with individual effects ";...
"model with individual effects and time trends "]
 
//------------------------------------
//--- Statistics of Unit Root Test ---
//------------------------------------
res=tlist(['results';'meth';'y';'tstat';'critical';'pvalue';'rho';...
'var_rho';'mu_star';'sig_star';'bandwidth';'kernel';'h';'omega';'si';...
'pi';'pmax';'Ti1';'Ti2';'t_order';'trend order'],...
'Levin-Lin',Y,tstat,[-2.3263,-1.6449,-1.2816],pvalue,rho,var_rho,...
mu_star,sig_star,bandwidth,ker,h,omega,Si,resADF('pi'),resADF('pmax'),...
Tip1,Tip2,t_order,t_orderlit(t_order+2))
 
//--------------
//--- Others ---
//--------------
 
if t_order == -1 then
// Non corrected t-statistic (t_order -1 only)
   res(1)($+1)='tstat_nc'
   res(1)($+1)='pvalue_nc'
   res('tstat_nc') = tstat_nc;
   pvalue_nc = cdfnor('PQ',tstat_nc,0,1);// Pvalue for the corrected statistic
   res('pvalue_nc') = pvalue_nc;
end;
 
endfunction
