function [results] = Choi1(Y,t_order,Lag_Orders,pmax,signif)
 
// PURPOSE: Choi(2006) Test of Unit Root "Unit Root Tests
// for Cross-Sectionally Correlated Panels" in Frontiers
// of Analysis and Applied Research, Cambridge University
// Press.
// -------------------------------------------------------
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
// -  res('meth') = 'Choi'
// -  res('y') = (T x k) matrix of data
// -  res('t_order') = the trend order (0 or 1)
// -  res('t_orderlit') = the trend order in plain english
// -  res('Pm') = Fisher''s modified Statistic (for large
//    N) : converge toward N(0,1) under H0
// -  res('Z') = Inverse Normal Test : converge toward
//    N(0,1) under H0 when N tends to infinity
// -  res('Lstar') = Modified Logit Test (George 1977):
//    converge toward N(0,1) under H0
// -  res('Pm_critical') = Critical Values of the Fisher's
//    modified Statistic (Choi, 2001) at 1%, 5% and 10%:
//    if Pm>Ca Reject H0
// -  res('Z_critical') = Critical Values of the Inverse
//    Normal Test: at 1%, 5% and 10% : if Z<Ca Reject H0
// -  res('Lstar_critical') = Critical Values of the
//    Modified Logit Test at 1%, 5% and 10%: if Lstar<Ca
//    Reject H0
// -  res('Pm_pvalue') = Pvalue associated to the Fisher's
//    modified Statistic
// -  res('Z_pvalue') = Pvalue associated to the Inverse
//    Normal Test
// -  res('Lstar_pvalue') = Pvalue associated to the
//    Modified Logit Test
// -  res('pvalue_ADF') = Individual pvalues of individual
//    ERS statitics based on standard DF pvalues (only for
//    t_order=0)
// -  res('tstat') = Individual statistics of ERS tests
// -  res('pi') = Individual lag order in individual ADF
//    models
// -  res('Ti') = Adjusted Individual Size
// -  res('pmax') = Maximum Lag Order for individual ADF
//    regressions
// ------------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
// C. Hurlin, 11 Juin 2004
// LEO, University of Orléans
 
 
//------------------------
//--- Transformed Data ---
//------------------------
 
[T,N] = size(Y)
 
select t_order
 
case 0 then
   c = -7; // Constant term of quasi-differenciation model with intercept
   namemod='Model with intercept'
 
case 1 then
   c = -13.5; // Constant term of quasi-differenciation model with intercept and trend
   namemod='Model with intercept and trend'
 
end;
 
Ti = sum(~isnan(Y),'r');
Ytild = Y(2:$,:)- ( ( ones(T-1,1) .*. (1+c ./ Ti) ) .* Y(1:$-1,:) )// Quasi-Differentiated Serie
Ytild = [%nan*ones(1,N);Ytild];// Quasi-Differentiated Serie
Ctild = [ones(1,N);ones(T-1,N) - ( ones(T-1,1) .*. (1+c ./Ti) )];// Quasi-Differentiated Constant Term
Ttild = [ones(1,N);ones(T-1,N) - ( (ones(1,N) .*. (1:T-1)')*c ) ./ (ones(T-1,1) .*. Ti) ];// Quasi-Differentiated Trend
 
//-----------------------------------------------------
//--- GLS estimate of individual constants alpha(i) ---
//-----------------------------------------------------
GLS = zeros(N,t_order+  1) // GLS estimates of individual constants alpha(i)
ai = zeros(N,1);
bi = zeros(N,1);// Starting Date and Ending Dates of Adjusted Sample
 
for i = 1:N
   //----------------------------------------
   //--- Determination of Adjusted Sample ---
   //----------------------------------------
   y=Y(:,i)
   ai(i)=sum(cumprod(bool2s(isnan(y))))+1
   [junk,b1]=max(cumsum(1-isnan(y)))
   bi(1)=b1
   Tip = bi(i)-ai(i)+1;  // Adjusted Size for Individual i
 
   //---------------------
   //--- GLS estimates ---
   //---------------------
   Yreg = [Y(ai(i),i);Ytild(ai(i)+1:bi(i),i)];  // Endogenous Variable in GLS detrending
 
   select t_order
 
   case 2 then
      GLS(i) = Ctild(1:Tip,i)\Yreg // GLS estimates of individual constants alpha(i)
 
    case 3 then
      GLS(i,:) = ([Ctild(1:Tip,i),Ttild(1:Tip,i)]\Yreg)'; // GLS estimates of individual constants alpha(i)
 
  end;
end;
 
select t_order
 
case 0 then
   Ys = Y - (ones(T,1) .*. GLS'); // Detrended Individual Series
 
case 1 then
   Ys = Y - (ones(T,1) .*. GLS(:,1)') - (ones(T,1) .*. GLS(:,2)') .* (ones(1,N) .*. (1:T)'); // Detrended Individual Series
 
end;
 
//--------------------------------------
//--- Demeaning Ys cross-sectionnaly ---
//--------------------------------------
Zc = ones(T,N)*%nan;// Matrix of demeaned data
 
for i = 1:N
   Zc(:,i) =Ys(:,i)- mean0(Ys(~isnan(Y(:,i)),i),'r');  // Demean the data cross-sectionnaly
end;
 
//-----------------------------------------
//--- Augmented Dickey Fuller GLS Tests ---
//-----------------------------------------
ADFres = ADF_Individual(Zc,t_order-1,Lag_Orders,pmax,signif);
 
pvalue_ERS = zeros(N,1);
for i = 1:N
   pvalue_ERS(i) = Choi_Pvalue(ADFres('tstat')(i),ADFres('Ti')(i),t_order);
end;
 
//--------------------
//--- Pooled Tests ---
//--------------------
Pm = -(1/sqrt(N))*sum(log(pvalue_ERS)+1);// Fisher''s modified Statistic (for large N) : converge toward N(0,1) under H0
Z = (1/sqrt(N))*sum(cdfnor('X',zeros(N,1),ones(N,1),pvalue_ERS,1-pvalue_ERS));// Inverse Normal Test : converge toward N(0,1) under H0 when N tends to infinity
Lstar = (1/sqrt(((%pi^2)*N)/3))*sum(log(pvalue_ERS ./(1-pvalue_ERS)));// Modified Logit Test (George 1977) : converge toward N(0,1) under H0
 
if isnan(Lag_Orders) then
   pi = ADFres("pi");  // Individual lag order in individual ADF models (optimal)
else
   pi = Lag_Orders(:);  // Individual lag order in individual ADF models (given by user)
end;
 
//===============
//=== RESULTS ===
//===============
 
results=tlist(['results';'meth';'y';'t_order';'t_orderlit';'Pm';'Z';'Lstar';'Pm_critical';...
'Z_critical';'Lstar_critical';'Pm_pvalue';'Z_pvalue';...
'Lstar_pvalue';'pvalues';'tstat';'pi';'Ti';'pmax'],...
'Choi',Y,t_order,namemod,Pm,Z,Lstar,[2.3263 1.6449 1.2816 ],-[2.3263 1.6449 1.2816 ],...
-[2.3263 1.6449 1.2816 ],1-cdfnor('PQ',Pm,0,1),cdfnor('PQ',Z,0,1),...
cdfnor('PQ',Lstar,0,1),pvalue_ERS,ADFres('tstat'),pi,ADFres('Ti'),pmax);
 
 
endfunction
