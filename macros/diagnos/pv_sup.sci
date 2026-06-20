function [p] = pv_sup(tn,k,l)
 
// PURPOSE: Procedure to compute asymptotic p-values for
// Quandt-Andrews Sup Test based on approximation used in B.
// Hansen paper "Approximate Asymptotic P-Values for Structural
// Change Tests".
// ------------------------------------------------------------
// INPUT:
// * tn = Value of Sup Statistic
// * k = Number of parameters tested for constancy
//       (degrees of freedom of conventional Chow test)
// * l = either the "lambda" or the "pi_0" of Andrews
//      - lambda lies between [1,infinity) and pi_0 between
//      (0,1/2].
//      - pi_0 is convenient when the test is constructed using
//      symmetric trimming, and Lambda is convenient when
//      non-symmetric trimming is used.
// ------------------------------------------------------------
// OUTPUT:
// * p =  Asymptotic p-value of test statistic
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// adapted from a Matlab program written by:
// Bruce E. Hansen
// Department of Economics
// Social Science Building
// University of Wisconsin
// Madison, WI 53706-1393
// bhansen@ssc.wisc.edu
// http://www.ssc.wisc.edu/~bhansen/
 
 
if l<1	 then
   tau = l;
else
   tau=1/(1+sqrt(l));
end;
 
global GROCERDIR
load(GROCERDIR+'\data\sup_beta.dat')
execstr('bet=beta_'+string(k));
 
x = bet(:,1)+bet(:,2)*tn
x=x.*(x>0);
pp = 1-cdfgam("PQ",x,0.5*bet(:,3),0.5*ones(x));
 
if tau == .5 then
   p = 1-cdfgam("PQ",tn,0.5*k,0.5*ones(k))
elseif tau <= .01 then
   p = pp(25);
elseif tau >= .49 then
   p=((.5-tau)*pp(1)+(tau-.49)*(1-cdfgam("PQ",tn,0.5*k,0.5*ones(k))))*100;
else
   taua=(.5-tau+.01)*50;
   tau1 = floor(taua);
   p=(tau1+1-taua)*pp(tau1)+(taua-tau1)*pp(tau1+1);
end;
 
endfunction
 
