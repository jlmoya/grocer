function [res] = IPS1(Y,t_order,pmax,signif)
 
// PURPOSE: Im, Pesaran and Shin (2003) test of unit root
// "Testing for Unit Root in Heterogeneous Panels", Journal
// of Econometrics, 115, p. 53-74
// ------------------------------------------------------------
// INPUT:
// * Y = matrix (T,N) of observations
//      The data matrix can be unbalanced.
//      Missing Values must be specified as %nan
// * t_order = -1: no individual effect
//           0: individual effects and no trend (Default)
//           1: individual effects and time trends
// * pmax = Maximum Lag Order for individual ADF regressions
// * signif = Level of significance for the test on the kth lag
// order parameter
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// - res('meth') = 'IPS'
// - res('y') = (T x k) matrix of data
// - res('t_order') = the trend order (-1, 0 or 1)
// - res('tbar') = Mean of Individual Augmented Dickey Fuller
//   statistics
// - res('Wbar') = Standardized IPS statistic based on
//   E[ti(pi,0)/bi=0] and V[ti(pi,0)/bi=0]
// - res('Wbar_pvalue') = Pvalue of Wbar
// - res('Zbar') = Standardized IPS statistic based on the
//   moments of the DF distribution
// - res('Zbar_pvalue') = Pvalue of Zbar
// - res('critical') = Critical Values of the Normal distribution
//   at 1%, 5% and 10%
// - res('tbar_DF') = Mean of Individual Dickey Fuller statistics
// - res('Zbar_DF') = Standardized IPS statistic (assumption of
//   no autocorrelation of residuals)
// - res('Zbar_DF_pvalue') = Pvalue of Zbar_DF
// - res('pi') = Individual lag order in individual ADF models
// - res('pmax') = Maximum of lag order in individual ADF models
// - res('Ti') = Adjusted Individual Size
// ------------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
// C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
//------------------------
//--- Transformed Data ---
//------------------------
 
[T,N] = size(Y);// Time Dimension
 
ADFres = ADF_Individual(Y,t_order,%nan,pmax,signif);// Individual ADF REgression for get Lag Order ADF.pi and size ADF.Ti
 
//==============================================================================
//==============================================================================
//=== PART I : Test under the assumption of no Auto-Correlation of Residuals ===
//==============================================================================
//==============================================================================
 
//--------------------------------
//--- Individual DF Statistics ---
//--------------------------------
 
DF = zeros(N,1);// Individual DF Statistics
T_DF = zeros(N,1)
for i = 1:N
 
   ai=ADFres('debi')(i)
   bi=ADFres('endi')(i)
   Ti=bi-ai+1
   if Ti < 10 then
      write(%io(2),'WARNING : Individual time dimensions must be superior to 10 (or 6 for balanced data) : see variable n'+ascii([194 176])+' '+ string(i),'(a)')
   end
 
   y=Y(ai:bi,i)
   Xi=y(1:$-1)
   dy=y(2:$)-Xi
 
   select t_order
 
   case 0 then
      Xi = [ones(Ti-1,1),Xi]; // ''t_order with intercept''
 
   case 1 then
      Xi = [ones(Tip,1),[1:Ti-1]',Xi]; // ''t_order with intercept and trend''
 
   end
 
   coef_ind = ols0(dy,Xi);  // Coefficients DF Regression
   var_res_ind=sum((dy-Xi*coef_ind).^2)/(Ti-3-t_order);                        // Residual Variance of DF
   tstat_ind=coef_ind./sqrt(diag(var_res_ind*inv(Xi'*Xi)))  // Tstat DF Regression
   DF(i,1) = tstat_ind($,1);  // Individual DF statistic
   T_DF(i,1) = Ti-1;  // Adjusted sample size for DF t_order
 
end
 
//--------------------------------------------------------------------------------
//--- Moments of Individual ADF statistics under assumption of no correlation ----
//--------------------------------------------------------------------------------
// The statistic used here is the standard t(it) and not t(it)tild (page 4).
// The corresponding moments from table 1, page 60, are used.
 
TT_DF = [6,7,8,9,10,15,20,25,30,40,50,100,500,1000,5000]';
esp = [-1.52,-1.515,-1.501,-1.501,-1.504,-1.514,-1.522,-1.52,-1.526,-1.523,-1.527,-1.532,-1.531,-1.529,-1.533]';
vari = [1.745,1.414,1.228,1.132,1.069,0.923,0.851,0.809,0.789,0.77,0.76,0.735,0.715,0.707,0.706]';
 
Em_DF = 0;// Mean of Individual esps of DF tstats
 
Vm_DF = 0;// Mean of Individual Variances of DF tstats
 
for i = 1:N // Computation of the Moments of the individual DF statistic
  [a,posi_DF] = min((TT_DF-T_DF(i,1)) .^2); // Posi : Position in TT table
  Em_DF = Em_DF+esp(posi_DF); // Sum of Individual esps of DF tstats
  Vm_DF = Vm_DF+vari(posi_DF); // Sum of Individual Variances of DF tstats
end
 
//---------------------------
//--- Statistics of Tests ---
//---------------------------
tbar_DF = mean0(DF);// Mean of Individual Dickey Fuller statistics
Zbar_DF=sqrt(N)*(tbar_DF-Em_DF/N)/sqrt(Vm_DF/N);
 
//=============================================================================
//=============================================================================
//=== PART II : Test in the general case with Auto-Correlation of Residuals ===
//=============================================================================
//=============================================================================
 
//---------------------------------------------
//--- Moments of Individual ADF statistics ----
//---------------------------------------------
// The corresponding moments are issued from table 2, page 18
 
TT = [10,15,20,25,30,40,50,60,70,100]';
 
PP = (0:8)';
 
m2 = [-1.504,-1.514,-1.522,-1.52,-1.526,-1.523,-1.527,-1.519,-1.524,-1.532;
     -1.488,-1.503,-1.516,-1.514,-1.519,-1.52,-1.524,-1.519,-1.522,-1.53;
     -1.319,-1.387,-1.428,-1.443,-1.46,-1.476,-1.493,-1.49,-1.498,-1.514;
     -1.306,-1.366,-1.413,-1.433,-1.453,-1.471,-1.489,-1.486,-1.495,-1.512;
     -1.171,-1.26,-1.329,-1.363,-1.394,-1.428,-1.454,-1.458,-1.47,-1.495;
     %nan,%nan,-1.313,-1.351,-1.384,-1.421,-1.451,-1.454,-1.467,-1.494;
     %nan,%nan,%nan,-1.289,-1.331,-1.38,-1.418,-1.427,-1.444,-1.476;
     %nan,%nan,%nan,-1.273,-1.319,-1.371,-1.411,-1.423,-1.441,-1.474;
     %nan,%nan,%nan,-1.212,-1.266,-1.329,-1.377,-1.393,-1.415,-1.456];
 
v2 = [1.069,0.923,0.851,0.809,0.789,0.77,0.76,0.749,0.736,0.735;
     1.255,1.011,0.915,0.861,0.831,0.803,0.781,0.77,0.753,0.745;
     1.421,1.078,0.969,0.905,0.865,0.83,0.798,0.789,0.766,0.754;
     1.759,1.181,1.037,0.952,0.907,0.858,0.819,0.802,0.782,0.761;
     2.08,1.279,1.097,1.005,0.946,0.886,0.842,0.819,0.801,0.771;
     %nan,%nan,1.171,1.055,0.98,0.912,0.863,0.839,0.814,0.781;
     %nan,%nan,%nan,1.114,1.023,0.942,0.886,0.858,0.834,0.795;
     %nan,%nan,%nan,1.164,1.062,0.968,0.91,0.875,0.851,0.806;
     %nan,%nan,%nan,1.217,1.105,0.996,0.929,0.896,0.871,0.818];
 
m3 = [-2.166,-2.167,-2.168,-2.167,-2.172,-2.173,-2.176,-2.174,-2.174,-2.177;
     -2.173,-2.169,-2.172,-2.172,-2.173,-2.177,-2.18,-2.178,-2.176,-2.179;
     -1.914,-1.999,-2.047,-2.074,-2.095,-2.12,-2.137,-2.143,-2.146,-2.158;
     -1.922,-1.977,-2.032,-2.065,-2.091,-2.117,-2.137,-2.142,-2.146,-2.158;
     -1.75,-1.823,-1.911,-1.968,-2.009,-2.057,-2.091,-2.103,-2.114,-2.135;
     %nan,%nan,-1.888,-1.955,-1.998,-2.051,-2.087,-2.101,-2.111,-2.135;
     %nan,%nan,%nan,-1.868,-1.923,-1.995,-2.042,-2.065,-2.081,-2.113;
     %nan,%nan,%nan,-1.851,-1.912,-1.986,-2.036,-2.063,-2.079,-2.112;
     %nan,%nan,%nan,-1.761,-1.835,-1.925,-1.987,-2.024,-2.046,-2.088];
 
v3 = [1.132,0.869,0.763,0.713,0.69,0.655,0.633,0.621,0.61,0.597;
     1.453,0.975,0.845,0.769,0.734,0.687,0.654,0.641,0.627,0.605;
     1.627,1.036,0.882,0.796,0.756,0.702,0.661,0.653,0.634,0.613;
     2.482,1.214,0.983,0.861,0.808,0.735,0.688,0.674,0.65,0.625;
     3.947,1.332,1.052,0.913,0.845,0.759,0.705,0.685,0.662,0.629;
     %nan,%nan,1.165,0.991,0.899,0.792,0.73,0.705,0.673,0.638;
     %nan,%nan,%nan,1.055,0.945,0.828,0.753,0.725,0.689,0.65;
     %nan,%nan,%nan,1.145,1.009,0.872,0.786,0.747,0.713,0.661;
     %nan,%nan,%nan,1.208,1.063,0.902,0.808,0.766,0.728,0.67];
 
//-------------------------------------------------------------
//--- Standardisation E[ti(pi,0)/bi=0] and V[ti(pi,0)/bi=0] ---
//-------------------------------------------------------------
 
Em = 0;// Mean of Individual esps E[ti(pi,0)/bi=0]
Vm = 0;// Mean of Individual Variances V[ti(pi,0)/bi=0]
 
for i = 1:N // Computation of the Moments of the individual ADF statistic
 
  [a,T_posi] = min((TT-ADFres('Ti')(i)) .^2); // Posi : Position in TT table
  [b,p_posi] = min((PP-ADFres('pi')(i)) .^2); // Posi : Position in TT table
 
   select t_order
 
   case -1 then
     Em = %nan; Vm = %nan; // Case not tabulated in (IPS 2003)
     write(%io(2)," WARNING: the moments E[ti(pi,0)/bi=0] and V[ti(pi,0)/bi=0] are not tabulated for t_order 1 in IPS",'(a)')
 
   case 0 then
      Em = Em+m2(p_posi,T_posi)    // Sum of Individual esps of DF tstats
      Vm=Vm+v2(p_posi,T_posi)    // Sum of Individual esps of DF tstats
      if isnan(m2(p_posi,T_posi)+v2(p_posi,T_posi)) then
         write(%io(2,'(a)'),'WARNING: Given the optimal lag structure, individual time dimension is not sufficient for variable '+...
           string(i)+' for T = '+string(ADFres('Ti')(i))+' and p = '+string(ADFres('pi')(i)))
      end
 
   case 1 then
      Em=Em+m3(p_posi,T_posi)    // Sum of Individual Esperances of DF tstats
      Vm=Vm+v3(p_posi,T_posi)    // Sum of Individual Esperances of DF tstats
      if isnan(m3(p_posi,T_posi)+v3(p_posi,T_posi))
         write(%io(2,'(a)'),'WARNING: Given the optimal lag structure, individual time dimension is not sufficient for variable '+...
           string(i)+' for T = '+string(ADFres('Ti')(i))+' and p = '+string(ADFres('pi')(i)))
      end
 
   end
 
end
 
 
//------------------------------------------
//--- Statistics of Test : tbar and Wbar ---
//------------------------------------------
 
tbar = mean0(ADFres('tstat')) // Mean of Individual Augmented Dickey Fuller statistics
Zbar=sqrt(N)*(tbar-Em_DF/N)/sqrt(Vm_DF/N) // Standardized IPS statistic
Wbar=sqrt(N)*(tbar-Em/N)/sqrt(Vm/N) // Standardized IPS statistic based on E[ti(pi,0)/bi=0] and V[ti(pi,0)/bi=0]
 
 
//===============
//===============
//=== res ===
//===============
//===============
select t_order
 
case -1 then
   modname = "t_order without intercept nor trend";
 
case 0 then
   modname = "t_order with intercept"
 
case 1 then
   modname = "t_order without intercept and trend"
 
end
 
res=tlist(['results';'meth';'y';'t_order';'tbar';'Wbar';'Wbar_pvalue';'Zbar';'Zbar_pvalue';'critical';...
'tbar_DF';'Zbar_DF';'Zbar_DF_pvalue';'pmax';'pi';'tstats_ind';'Ti'],...
'IPS',Y,modname,tbar,Wbar,cdfnor("PQ",Wbar,0,1),Zbar,cdfnor("PQ",Zbar,0,1),-[2.3263;1.6449;1.2816],...
tbar_DF,Zbar_DF,cdfnor("PQ",Zbar_DF,0,1),pmax,ADFres('pi'),ADFres('tstat'),...
ADFres('Ti'))
 
endfunction
