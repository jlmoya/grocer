function res = Maddala_Wu1(Y,t_order,Lag_Orders,pmax,signif)
 
// PURPOSE: Maddala and Wu(1999) Test of Unit Root "A
// Comparative Study of Unit Root Tests with Panel Data and a
// New simple test", Oxford Bulletin of Economics and
// Statistics, Special Issue, p. 631-652.
// ------------------------------------------------------------
// INPUT:
// * Y = a (T x N) matrix  of observations
//      The data matrix can be not balanced. Missing Values
//      must be specified as NaN
// * t_order = -1 : no individual effect
//           0 : individual effects (Default)
//           1 : individual effects and time trends
// * Lag_Orders =  a vector (N,1) or (1,N) with the optimal
//               lags for all the individuals of the panel
//  (if Lag_Orders is not specified the program determines the
//  optimal lag order in individual ADF for each country
//  - pmax=12 or T/4)
// * pmax = Maximum Lag Order for individual ADF regressions
// * signif = Level of significance for the test on the kth lag
// order parameter
// ------------------------------------------------------------
// OUTPUT:
// res = a results tlist with:
// - res('meth') = 'Maddala-Wu'
// - res('y') = (T x k) matrix of data
// - res('P') = Fisher statistic based on Individual ADF
//   statistics
// - res('P_Critical') = Critical Values of the Fisher
//   statistic at 1%, 5% and 10%
// - res('P_pvalue') = Pvalue Pooled test statistic
//   (Maddala Wu 1999)
// - res('Z') = Choi (2001) statistic based on Individual ADF
//   statistics (for large N tends to N(0,1))
// - res('Z_Critical') = Critical Values of the pooled test
//   statistic (Choi, 2001) at 1%, 5% and 10%
// - res('Z_pvalue') = Pvalue Pooled test statistic
//   (Choi 2001)
// - res('ADF_pvalues') = Individual pvalues of individual ADF
//   statistics
// - res('pi') = Individual lag order in individual ADF models
// - res('pmax') = Maximum Lag Order for individual ADF
//   regressions
// - res('Ti') = Adjusted Individual Size
// - res('ADF_tstats') = Individual ADF statistics
// - res('sample') =  Starting and Ending Dates of Adjusted
//   Sample
// -------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
// C. Hurlin, 01 June 2004
// LEO, University of Orléans
 
 
//------------------------
//--- Transformed Data ---
//------------------------
 
[T,N] = size(Y)
 
if isnan(Lag_Orders) then
  ADFres= ADF_Individual(Y,t_order,%nan,pmax,signif);  // Individual ADF REgression for get Lag Order ADF.pi and size ADF.Ti
else
  ADFres = ADF_Individual(Y,t_order,Lag_Orders,signif);  // Individual ADF REgression (the lag structure is specified)
end;
 
//----------------------------------------------------------
//--- Test 1 : Fisher Based on ADF individual Statistics ---
//----------------------------------------------------------
MW_PMW = -2*sum(log(ADFres('pvalue')))// Fisher statistic based on Individual ADF statistics
MW_PMW_Critical = cdfchi('X',2*N*ones(1,3),[0.99,0.95,0.9],[0.01 0.05 0.1]);// Critical Values of the Fisher statistic at 1%, 5% and 10%
MW_PMW_pvalue = 1-cdfchi("PQ",MW_PMW,2*N)// Pvalue Pooled test statistic (Maddala Wu 1999)
MW_ZMW = (1/(2*sqrt(N)))*sum(-2*log(ADFres('pvalue'))-2);// Choi (2001) statistic based on Individual ADF statistics (for large N tends to N(0,1))
MW_ZMW_Critical = [2.3263,1.6449,1.2816];// Critical Values of the pooled test statistic (Choi, 2001) at 1%, 5% and 10%
MW_ZMW_pvalue = 1-cdfnor("PQ",MW_ZMW,0,1);// Pvalue Pooled test statistic (Choi 2001)
 
//===============
//=== RESULTS ===
//===============
 
if isnan(Lag_Orders) then
   MW_pi = ADFres('pi');  // Individual lag order in individual ADF models
else
   MW_pi = Lag_Orders(:);  // Individual lag order in individual ADF models
end
 
select t_order
case -1 then
   MW_model = " Model without intercept nor trend: Model 1";
 
case 0 then
   MW_model = " Model with intercept: Model 2";
 
case 1 then
   MW_model = " Model with intercept and trend: Model 3 ";
 
end;
 
res=tlist(['results';'meth';'t_order';'P';'P_Critical';'P_pvalue';'Z';...
'Z_Critical';'Z_pvalue';'ADF_pvalues';'pi';'pmax';'Ti';'ADF_tstats';...
'sample'],'Maddala-Wu',MW_model,MW_PMW,MW_PMW_Critical,MW_PMW_pvalue,MW_ZMW,...
MW_ZMW_Critical,MW_ZMW_pvalue,ADFres('pvalue'),ADFres('pi'),pmax,...
ADFres('Ti'),ADFres('tstat'),[ADFres('debi') ADFres('endi')])
 
endfunction
