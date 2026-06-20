function res = Chang_IV1(Y,t_order,LagOrders,pmax,IGF,signif)
 
// PURPOSE: Chang (2002) unit root test "Nonlinear IV unit
// root test in panels with cross-  sectional dependency",
// Journal of Econometrics, 110, 261-292
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
// * IGF (Instrument Generating Function) function
//       = 1: F(x)=x*exp(-ci*|x|) (Default)
//         2: F(x)=I(|x|<K) Trimmed OLS on [-K,K]
//         3: F(x)=I(|x|<K)*x
// * signif = Level of significance for the test on the kth lag
// order parameter
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// -  res('meth') = 'Chang IV'
// -  res('y') = (T x k) matrix of data
// -  res('t_order') = the trend order (-1, 0 or 1)
// -  res('t_orderlit') = the trend order in plain english
// -  res('Sn') = Average IV t-ratio statistic (distributed as
//    N(0,1) under H0)
// -  res('Sn_critical') = Critical Values of normal N(0,1) at
//    1%, 5% and 10%
// -  res('Sn_pvalue') = Pvalue of the average IV t-ratio
//    statistic
// -  res('Zi') = Individual IV t-ratio statistics
// -  res('Zi_critical') = Critical Values of normal N(0,1) at
//    1%, 5% and 10%
// -  res('Zi_pvalue') = Pvalue of the individual IV t-ratio statistics
// -  res('pi') = Individual lag orders
// -  res('ADF') = Individual ADF statistics for comparison
// -  res('AR_IV_ind') = Individual IV estimates of the autoregressive parameter
// -  res('var_resIV') = Variance of Residuals of IV estimates for each unit
// -  res('var_IV') = Variance of the IV estimator of the autoregressive parameter
// -  res('IGF') = Instrument Generating Function used
// -  res('K') = Constant K of IGF function (IGF 2 and 3 only)
// -  res('ci') = Factor ci for IGF 1 : F(x)=x*exp(-ci*|x|)
// ------------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
// C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
 
 
if or(~isnan(LagOrders)) & (length(LagOrders)~= size(Y,2)) then
   warning(" The lag order must be specified for all the individuals of the panel: your lag structure cannot be considered ")
   Lag_Orders = %nan;
end
 
//------------------------
//--- Transformed Data ---
//------------------------
 
[T,N] = size(Y)// Time Dimension
 
if and(isnan(LagOrders)) then // If condition on the lag structure
   resADF = ADF_Individual(Y,t_order,%nan,pmax); // Individual ADF REgression for get Lag Order ADF.pi and size ADF.Ti
else // The lag structure is spoecifed by the user
   resADF = ADF_Individual(Y,t_order,LagOrders); // Individual ADF REgression (the lag structure is specified)
end
 
Y1=Y(1:$-1,:)
dy = Y(2:$,:)-Y(1:$-1,:);// Vector of First Order Differences
DYlag = ones(T,N,max(resADF('pi')))*%nan;// Matrix of Lagged First Order Differences
 
for p=1:max(resADF('pi')) // Loop to compute the matrix of Lagged First Order Differences
   DYlag(p+2:$,:,p) = dy(1:$-p,:); // Matrix of Lagged First Order Differences
end;// End of the loop
 
//----------------------------------------------------
//--- Demeaned or detrented data for t_orders 0 or 1---
//----------------------------------------------------
 
select t_order // Switch on the deterministic component
 
case 0 then // Model with individual effects
   for i = 1:N // Loop on individual (necessary for unbalanced data)
      ai=resADF('debi')(i)
      bi=resADF('endi')(i)
      Y1(ai:bi-1,i)=Y1(ai:bi-1,i)-cumsum(Y(ai:bi-1,i))./(1:bi-ai)'
      Y(ai+1:bi,i)=Y(ai+1:bi,i)-cumsum(Y(ai:bi-1,i))./(1:bi-ai)'; // Demeaned data y(i,t) with adaptative mean of y(i,t-1)
   end // End of the loop
 
case 1 then // Model with individual effects and time trends
   for i = 1:N // Loop on individual (necessary for unbalanced data)
      ai=ADFres('debi')(i)
      bi=ADFres('endi')(i)
      ke = [1:bi-ai]'; // Incremental variable ke=1,2,..,Ti-1
      Ti=bi-ai+1; // Adjusted Size for Individual i
      dy(:,i)=dy(:,i)-Y(bi,i)/Ti // Eliminating remaining drift in Dy(i,t)
      DYlag(:,i,:)=DYlag(:,i,:)-Y(bi,i)/Ti; // Eliminating remaining drift in Dy(i,t-k)
      Y1(ai+1:bi,i)=Y1(ai+1:bi,i)+2*cumsum(Y(ai:bi-1,i))./ke...
            -6*cumsum(Y(ai:bi-1,i).*ke)./(ke.*(ke+1));
      Y(ai+1:bi-1,i)=Y(ai+1:bi,i)+2*cumsum(Y(ai:bi-1,i))./ke...
            -6*cumsum(Y(ai:bi-1,i).*ke)./(ke.*(ke+1))-Y(bi,i)/Ti;
   end // End of the loop
 
end;// End of Switch
 
//------------------------------------------------------
//--- IV estimator for the AR individual coefficient ---
//------------------------------------------------------
 
ci = zeros(N,1);// Factor ci for IGF F(.)=y1*exp(-ci*|y1|)
K = zeros(N,1);// Constant K for IGF 2 and 3
IV_ind = zeros(N,1);// Individual IV estimates of the autoregressive parameter
var_res = zeros(N,1);// Variance of Residuals of IV estimates for each unit
var_IV = zeros(N,1);// Variance of the IV estimator of the autoregressive parameter
 
for i = 1:N // Loop on individual indice
 
   ai=resADF('debi')(i)
   bi=resADF('endi')(i)
   pi=resADF('pi')(i)
   Y1i=Y1(ai+pi:bi-1,i)
   dyi=dy(ai:bi-1,i)
   s2=mean(dyi(pi+1:$).^2) // Sample standard error
   ci(i)=3*resADF('Ti')(i)^(-0.5)/sqrt(s2); // Factor ci for the F(.)=y1*exp(-ci*|y1|)
   ys=gsort(abs(Y1i),'g','i')
   K(i)=ys(floor(length(ys)*0.8)) // K value for IGF 2 and 3
 
   select IGF // Switch on the IGF function
 
   case 2 then
      F = (abs(Y1i) <= K(i)) // IGF 2 : F(x)=I(|x|<K) (trimmed OLS)
   case 3 then
      F =  (abs(Y1i(ai:bi,i))<=K(i)).*Y1(ai:bi,i) // IGF 3 : F(x)=I(|x|<K)*x
   else
      F= Y1i .* exp(-ci(i)*abs(Y1i))
    end // End on switch
 
   if resADF('pi')(i) > 0 then // Case with ADF terms
      dXi=mlag(dyi,pi)
      ADF_terms = dXi(pi+1:$,:)
      dyi=dy(ai+pi:$,:)// ADF terms
   else // Case with no ADF terms
      ADF_terms = []; // ADF terms
   end; // End on the if condition
 
   Wi = [F ADF_terms]; // Matrix Wi = [IGF ADF terms]
   Yi = [Y1i ADF_terms]; // Matrix Yi = [Y1 ADF terms]
   gam_hat = (inv(Wi'*Yi)*Wi')*Y(ai+pi+1:bi,i) // IV Estimates
   IV_ind(i) = gam_hat(1); // Individual IV estimates of the autoregressive parameter
 
   if resADF('pi')(i) > 0 then // Case ADF with p>0
      res_IV = Y(ai+pi+1:bi,i)-gam_hat(1)*Y1i-ADF_terms*gam_hat(2:$); // Residuals of IV estimates (ADF case)
      CTi=F'*F-F'*ADF_terms*inv(ADF_terms'*ADF_terms)*ADF_terms'*F // CTi coefficient
      BTi=F'*Y1i-F'*ADF_terms*inv(ADF_terms'*ADF_terms)*ADF_terms'*Y1i // BTi coefficient
 
   else // Case DF with p=0
      res_IV = Y(ai+pi+1:bi,i)-gam_hat(1)*Y1i // Residuals of IV estimates (DF case)
      CTi = F'*F
      BTi = F'*Y1i // CTi and BTi coefficient
 
   end;
 
   var_res(i)=sum(res_IV.^2)/resADF('Ti')(i); // Variance of Residuals of IV estimates
   var_IV(i)=var_res(i)*CTi/BTi^2 // Variance of the IV estimator of the autoregressive parameter
 
end;// End of the loop on individual indice
 
Z_ind = (IV_ind-1) ./(var_IV .^0.5);// Individual IV t-ratio statistics
 
//-------------------
//--- Panel Tests ---
//-------------------
 
Sn = sum(Z_ind)/sqrt(N);// Average IV t-ratio statistic
 
t_orderlit = ["model without intercept nor trend ";...
"model with individual effects ";...
"model with individual effects and time trends "]
 
IGFlit=[" IGF 1 (Defaut) : F(x)=x*exp(-ci*|x1|) ";...
" IGF 2 : F(x)=I(|x|<K). Trimmed OLS on [-K,K] ";...
" IGF 3 : F(x)=I(|x|<K)*x"]
 
//===============
//=== RESULTS ===
//===============
res=tlist(['results';'meth';'y';'t_order';'t_orderlit';'IGF';'IGFlit';...
'tstat';'critical';'pvalue';'Zi';'Zi_critical';'Zi_pvalue';'pi';...
'pmax';'ADF_tstat';'IV_ind';'var_resIV';'var_IV'],...
'Chang IV',Y,t_order,t_orderlit(t_order+2),IGF,IGFlit(IGF),...
Sn,-[2.3263,1.6449,1.2816],cdfnor('PQ',Sn,0,1),...
Z_ind,-[2.3263,1.6449,1.2816],cdfnor('PQ',Z_ind,zeros(N,1),ones(N,1)),...
resADF('pi'),resADF('pmax'),resADF('tstat'),IV_ind,var_res,var_IV)
 
if IGF == 1 then
   res(1)($+1)='ci'
   res('ci')=ci
else
   res(1)($+1)='K'
   res('K')=K
end
 
endfunction
