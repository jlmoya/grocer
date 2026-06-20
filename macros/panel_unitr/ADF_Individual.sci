function [resADF] = ADF_Individual(Y,model,Lag_Orders,pmax,signif)
 
// PURPOSE: ADF (1981) Unit Root Tests on Individual Times
// Series Augmented Dickey Fuller Tests for a collection
// of series entered as matrix. Lag Selection is perfromed
// with the k-max Criterion proposed by  Dickey et Fuller
// (1981), Econometrica
// ------------------------------------------------------------
// INPUT:
// * Y = matrix (T,N) of observations
//       The data matrix may be unbalanced.
//       Missing Values must be specified as %nan
// * Model = -1 : no individual effect
//            0 : individual effects (Default)
//            1 : individual effects and time trends
// * Lag_Orders =
//   - %nan if the user wants the program to determine the
//   optimal lag order for each country (pmax=12 or T/4)
//   - a vector (N x 1) or (1 x N) of optimal lags for all the
//   individuals of the panel
// * pmax = Maximum of the lag order authorized
// * signif = Level of significance for the test on the kth lag
// order parameter
// ------------------------------------------------------------
// OUTPUT:
// resADF a results tlist with:
// - resADF('meth') = 'adf individual'
// - resADF('model') = model of the ADF test("Model without
//                   intercept nor trend", "Model with
//                   intercept", Model with intercept and
//                   trend")
// - resADF('tstat') = Individal ADF Statistic
// - resADF('critical') = Critical Values of the DF distribution
//                      at 1%, 5% and 10% for T and N sample
// - resADF('pvalue') = p-value for each individual ADF Statistic
// - resADF('pi') = Optimal Lag Order in ADF Regression
// - resADF('Ti') = Optimal Adjusted Size
// - resADF('rho') = Estimated autoregressive parameter
// - resADF('ser') = Standard Error of ADF Residual
// - resADF('resid') = ADF Residual
// - resADF('si') = Individual Ratios of long run standard deviation to the innovation SE
// - resADF('starti') = Starting Date of Adjusted Sample
// - resADF('endi') = Ending Date of Adjusted Sample
// - resADF('pmax') = Maximum of the lag order authorized
//
// Remark : This program can consider different samples for each individual (non balanced panel)
// ------------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// uses the function Levin_Lin1 translated and adapted from a
// Matlab program by: C. Hurlin, 11 Juin 2004
// LEO, University of Orl�ans
 
global GROCERDIR ;
 
[nargout,nargin] = argn(0)
 
if (model<-1)|(model>1) then
   model = 0
end;
 
if and(~isnan(Lag_Orders)) & length(Lag_Orders) ~= size(Y,2) then
   warning("The lag order must be specified for all the individuals of the panel: your lag structure cannot be considered ")
   Lag_Orders = %nan;
end;
 
//-----------------------
//--- Transformed Data ---
//------------------------
 
[T,N] = size(Y)
 
if isnan(pmax) then
    pmax=min(floor(T/4),12);
    // Maximum of Lag order
end
 
//------------------------
//--- Data for Pvalues ---
//------------------------
 
select model // Switch on deterministic component
 
case -1 then
   critical = 'dfnc' // Critical values model 1
   ADF_model = "Model without intercept nor trend"; // Model with no intercept
   exo=[]
 
case 0 then
   critical = 'dfc' // Critical values model 2
   ADF_model = "Model with intercept"; // Model with intercept
   exo=ones(T-1,1)
 
case 1 then
   critical = 'dfct' // Critical values model 3
   ADF_model = "Model with intercept and trend"; // Model with intercept and trend
   exo=[ones(T-1,1) [1:T-1]']
 
end
 
 
//---------------------------------------
//--- Individual Lag Length Selection ---
//---------------------------------------
 
ADF_tstat=zeros(N,1)
ADF_critical=zeros(N,3)
ADF_pvalue=zeros(N,1)
ADF_pi=ones(N,1)*pmax
ADF_Ti=zeros(N,1)
ADF_rho=zeros(N,1)
ADF_sig=zeros(N,1)
ADF_residual=ones(T,N)*%nan;
ADF_si=zeros(N,1)
ADF_ai=zeros(N,1)
ADF_bi=zeros(N,1)
 
for i = 1:N // Loop on individual unit
 
   y=Y(:,i)
   a1=sum(cumprod(bool2s(isnan(y))))+1
   [junk,b1]=max(cumsum(1-isnan(y)))
   y=y(a1:b1)
   ADF_ai(i)=a1
   ADF_bi(i)=b1
   Ti=b1-a1+1
   dy=y(2:$)-y(1:$-1)
 
   p_indi = ADF_pi(i); // Initial Guess on the Optimal Lag order
   optimal = 1; // Optimal Lag Selection
   tstat_ind=0
 
   if ~isnan(Lag_Orders) then
// Particular case: the user gives the lag structure
 
      p_indi = Lag_Orders(i);
      lXi=mlag(dy,p_indi)
      Xi=[exo(1:Ti-p_indi-1,:) y(1+p_indi:Ti-1) lXi(1+p_indi:Ti-1,:)];
      coef_ind = ols0(dy(1+p_indi:T-1),Xi) // Coefficients ADF Regression
      var_res_ind = sum((dy(1+p_indi:T-1)-Xi*coef_ind).^2)/(Ti-3-2*p_indi-model)// Residual Variance of ADF
      tstat_ind = coef_ind ./ sqrt(diag(var_res_ind*inv(Xi'*Xi))) // Tstat ADF Regression
 
   else
      while (abs(tstat_ind($)) < cdft('T',Ti-model-3-2*p_indi,1-signif/2,signif/2)) & (p_indi>-1) & (optimal==1) then
 
         lXi=mlag(dy,p_indi)
         Xi=[exo(1:Ti-p_indi-1,:) y(1+p_indi:Ti-1) lXi(1+p_indi:Ti-1,:)];
 
         //-----------------------------------------------
         //--- Individual Regression with pi ADF terms ---
         //-----------------------------------------------
 
         coef_ind = ols0(dy(1+p_indi:T-1),Xi) // Coefficients ADF Regression
         var_res_ind = sum((dy(1+p_indi:Ti-1)-Xi*coef_ind).^2)/(Ti-3-2*p_indi-model) // Residual Variance of ADF
         tstat_ind = coef_ind ./ sqrt(diag(var_res_ind*inv(Xi'*Xi))) // Tstat ADF Regression
         p_indi = p_indi-1 // Optimal lag
 
      end; // End of while
   end
 
   //--------------------------------
   //--- Pvalue of ADF statistics ---
   //--------------------------------
   Tip=size(Xi,1)
   p_indi=size(Xi,2)-(model+2)
   pvalue = fcrit_df(tstat_ind(model+2),2,Tip,GROCERDIR+'/data/mackinnon_dftab1.dat',critical,9) // Pvalue for unit i
   load(GROCERDIR+'/data/mackinnon_dftab1.dat')
   execstr('nametab='+critical)
   nvar=size(nametab,2)-1
   regress1=(1/Tip).^[0:nvar-1]
   prob1=nametab(13,1:nvar)*regress1' // Position of the approximated critical value at 1%
   prob5=nametab(21,1:nvar)*regress1' // Position of the approximated critical value at 5%
   prob10=nametab(31,1:nvar)*regress1' // Position of the approximated critical value at 10%
 
 //-----------------------------------------
 //--- Optimal Lag Order and ADF Results ---
 //-----------------------------------------
 
   ADF_tstat(i) = tstat_ind(model+2); // Individual ADF Statistic
   ADF_pvalue(i) = pvalue; // Pvalue for each individual ADF Statistic
   ADF_pi(i) = p_indi // Optimal Lag Order in ADF Regression
 
   ADF_rho(i) = coef_ind(model+2); // Estimated autoregressive parameter
   ADF_Ti(i) = Tip; // Optimal Adjusted Size (Unbalanced Panel)
   ADF_sig(i) = sqrt(var_res_ind); // Standard Error of ADF Individual Residuals
   ADF_residual(p_indi+2:T,i)=dy(p_indi+1:T-1)-Xi*coef_ind // ADF Residual
   ADF_si(i) = abs(1-sum(coef_ind(model+3:$))) // Individual Ratios of long run standard deviation to the innovation SE
 
   ADF_critical(i,:) = [prob1,prob5,prob10] // Critical Values of the DF distribution at 1%, 5% and 10% for T and N sample
   ADF_pmax = pmax; // Maximum of the lag order authorized
   ADF_signif = signif; // Level of significance for the test on the kth lag order parameter (Default value is 0.05)
 
end // End of loop on individual
 
resADF=tlist(['results';'meth';'model';'tstat';'critical';'pvalue';'pi';'Ti';'rho';'sig';...
'residual';'si';'debi';'endi';'pmax'],'adf individual',ADF_model,ADF_tstat,ADF_critical,ADF_pvalue,ADF_pi,...
ADF_Ti,ADF_rho,ADF_sig,ADF_residual,ADF_si,ADF_ai,ADF_bi,pmax)
 
endfunction
