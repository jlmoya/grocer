function LR = longrun_variance(X,ker,bandwidth)
 
// PURPOSE: Estimate the long run variance of a stationary
// series (see Salanié (1999), "Guide Pratique des Séries
// Stationnaires", Economie et Prévision, 137, 119-140
// ------------------------------------------------------------
// INPUT:
// * X = vector of observations
// * ker =
//   - ''QS'' for Quadratic Spectral (Defaut)
//   - ''B'' for Bartlett
// *  bandwidth =
//   - 'n' (Default) for the Newey West 1994)'s non parametric
//               (bandwidth parameter
//   - 'a' for the Andrews (1991) automatic bandwidth parameter
//                selection with AR(1) structure
// ------------------------------------------------------------
// OUTPUT:
// LR a results tlist with:
// - LR('meth') = 'lr variance'
// - LR('omega') = Long run variance of X
// - LR('kernel') = kernel function
// - LR('bandwidth') = Method to fix the bandwidth parameter
// - LR('h') = Value of bandwidth parameter
// ------------------------------------------------------------
// Copyright Eric Dubois (2008)
// http://grocer.toolbox.free.fr/grocer.html
// translated from a matlab programm by:
// C. Hurlin, 08 Juin 2004
// LEO, University of Orléans
 
 
T = size(X,1);// Not adjusted Sample Size
X0 = X(2:$);// Contemporenaous series X(t)
X1 = X(1:$-1);// Lagged series X(t-1)
rho1 = sum(X0 .* X1)/sum(X1.^2);// Coefficient of the regression of X(t) on X(t-1)
res = X0-X1*rho1;// Residual X(t)-rho1*X(t-1)
 
//===================
//==== QS  ====
//===================
 
select convstr(ker)
 
case "qs" then
 
   kern_name="Quadratic Spectral "
   //-----------------------------
   //--- Bandwidth Parameter h ---
   //-----------------------------
   select convstr(bandwidth)
 
   case "a" then // Andrews (1991) Bandwidth parameter
 
      ri1 = sum(res(2:$) .*res(1:$-1))/sum(res(1:$-1) .^2); // Estimate of the autoregressive parameter in AR(1) specification
      Beta_s = (4*(ri1^2))/4*ri1^2/(1-ri1)^4   // Value of Beta_s for the QS 4
 
   case "n" then // Newey West (1994) Bandwidth parameter
 
      nmax = floor(4*((T/100)^(2/25))); // Lag Troncature for QS
      s2 = 0;
      s0 = sum(res .^2)/T; // Initialisation
 
      for j = 1:nmax
         gam_j = sum(res(1+j:$) .*res(1:$-j))/T;  // Autocovariance of order j
         s0=s0+2*gam_j;  // Component s0=gam0+2sum(gam_j)
         s2=s2+2*gam_j*j^2  // Component s2=2sum(gam_j*j^2)
      end
      Beta_s = (s2/s0)^2; // Value of Beta_s for the QS
 
   end;
 
   h = 1.3221*((Beta_s*T)^0.2);  // Value of the Bandwidth parameter for the QS
 
  //-----------------------------------------------
  //--- QS  Estimate of Long Run Variance ---
  //-----------------------------------------------
   x = (1:T-2)'/h;  // Vector of j/h
   w=(25*ones(T-2,1) ./ (12*%pi^2*x.^2)).*(sin(6*%pi*x/5)./(6*%pi*x/5)-cos(6*%pi*x/5))  // QS
   gam_j = zeros(T-2,1);  // Vector of Autocovariances of res
 
   for j = 1:T-2
      gam_j(j)=sum(res(1+j:$).*res(1:$-j))/T  // Autocovariance of order j
   end;
   omega=sum(res.^2)/T+2*sum(w.*gam_j)  // Long run variance of res
 
//=========================
//==== Bartlett  ====
//=========================
 
case "b" then
 
   kern_name="Bartlett "
   //-----------------------------
   //--- Bandwidth Parameter h ---
   //-----------------------------
   select bandwidth
 
   case "a" then // Andrews (1991) Bandwidth parameter
 
      ri1 = sum(res(2:$) .* res(1:$-1))/sum(res(1:$-1) .^2); // Estimate of the autoregressive parameter in AR(1) specification
      Alpha=4*ri1^2/(1-ri1^2)^2 // Value of Alpha for the Bartlett
 
   case "n" then // Newey West (1994) Bandwidth parameter
 
      nmax = floor(4*(T/100)^(2/9)); // Lag Troncature for Bartlett
      s1 = 0;
      s0 = sum(res .^2)/T; // Initialisation
 
      for j = 1:nmax
         gam_j = sum(res(1+j:$) .* res(1:$-j))/T;  // Autocovariance of order j
         s0=s0+2*gam_j;  // Component s0=gam0+2sum(gam_j)
         s1=s1+2*gam_j*j  // Component s2=2sum(gam_j*j^2)
      end;
 
      Alpha = (s1/s0)^2; // Value of Alpha for the Bartlett
 
   end  // end on select
 
   h = 1.1447*((Alpha*T)^(1/3));  // Value of the Bandwidth parameter for the Bartlett
 
   //-----------------------------------------------------
   //--- Bartlett  Estimate of Long Run Variance ---
   //-----------------------------------------------------
   x = (1:T-2)'/h;  // Vector of j/h
   w = max(1-x,0);  // Bartlett
   gam_j = zeros(T-2,1);  // Vector of Autocovariances of res
   for j=1:sum(w>0)
      gam_j(j)=sum(res(1+j:$).*res(1:$-j))/T  // Autocovariance of order j
   end;
 
   omega=sum(res.^2)/T+2*sum(w.*gam_j)  // Long run variance of res
 
end;
 
if convstr(bandwidth) == 'a' then
   bandwidth_name = "Andrews (1991)";
else
   bandwidth_name = "Newey et West (1994)";
end;
 
//---------------------------------------
//--- Recolour the long run variances ---
//---------------------------------------
omega=omega/(1-rho1)^2;     // Long run variance of X
 
//================
//=== RESULTS ====
//================
LR=tlist(['results';'meth';'omega';'kernel';'bandwidth';'h'],...
'lr variance',omega,kern_name,bandwidth_name,h)
 
endfunction
