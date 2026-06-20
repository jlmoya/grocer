function [results] = NbFactors(X,kmax)
 
 
// PURPOSE: Bai and Ng (2002) """"Determining the Number of Fcators in Approximate Factors Models"""",
// Econometrica, 70,1, p 191-221
//
// -------------------------------------------------------
// Usage:
// Where:   X = matrix (T,N) of observations
// Options
//       - kmax : The maximum number of common factors used to compute the criterion functions for
//                the estimation of r, the number of common factors. It is not specified kmax=min(N,T)
//
// -------------------------------------------------------
// RETURNS:
//           results.khat                 Estimated Numbers of Factor with IC1, IC2, IC3, PC1, PC2, PC3, AIC3 and BIC3
//           results.khat_IC              Estimated Numbers of Factor with IC1, IC2 and IC3
//           results.khat_PC              Estimated Numbers of Factor with PC1, PC2 and PC3
//           results.khat_BIC3            Estimated Numbers of Factor with BIC3 (only BIC criteria function of N and T)
//           results.khat_AIC3            Estimated Numbers of Factor with AIC3 (only AIC criteria function of N and T)
//                                        This criterium generaly tends to overstimate the number of factor k
//           results.kmax                 Maximum Number of Factors Authorized (for the case it is not specified)
//           results.IC                   IC1, IC2 and IC3 Information criteria for k=1,..,kmax
//           results.PC                   PC1, PC2 and PC3 Information criteria for k=1,..,kmax
//           results.BIC3                 BIC3 Information criterium for k=1,..,kmax
//           results.AIC3                 AIC3 Information criterium for k=1,..,kmax
//           results.Vkmax                Estimated Variance of Residuals with kmax factors
 
// -------------------------------------------------------
//
// C. Hurlin, 08 Juin 2004
// LEO, University of Orl�ans
//
 
[nargout,nargin]=argn(0)
if nargin==1 then
   kmax = min(size(X))
end;// Rule proposed by Bai and Ng to choose kmax
 
if kmax == 1 then
   kmax = min(size(X))
end // Rule proposed by Bai and Ng to choose kmax
 
//----------------------------------------
//--- Computation of the V(kmax,Fkmax) ---
//----------------------------------------
[T,N] = size(X);// Sample Sizes
 
if T<N then // Choice of normalization according the computional cost
   [vectors,vals] =spec(X'*X) // Eigenvalues and eigenvectors of XX'
   [eigen,ind] = gsort(diag(vals),'g','i')
   vectors=real(vectors(:,ind))
   facts = sqrt(T)*vectors(:,T-kmax+1:T)// Estimated Factors with kmax Factors
   loadings = (X*facts)/T; // Estimated Matrix of Factor Loadings
   betahat = loadings*chol((loadings'*loadings)/N); // Rescaled Estimator of the Factor Loading
 
else // Case T>N
   [vectors,vals] =spec(X'*X)
   [eigen,ind] = gsort(diag(vals),'g','i')
   vectors=real(vectors(:,ind))
   loadings = sqrt(N)*vectors(:,N-kmax+1:N) // Estimated Matrix of Factor Loadings with kmax Factors
   facts = (X*loadings)/N; // Estimated Factors
   betahat =(X'*X)*loadings/(N*T) // Rescaled Estimator of the Factor Loading
 
end;
 
Z=X-X*betahat*inv(betahat'*betahat)*betahat' // Estimated Residuals
var_Z_kmax = sum(Z .^2)/(N*T);// Estimated Variance of Residuals with kmax factors
 
//----------------------------------
//--- Computation of the V(k,Fk) ---
//----------------------------------
V = zeros(kmax,1);// Vector of V(k,Fk) for k=1,..,kmax
 
if T<N then // Choice of normalization according the computional cost
   [vectors,vals] =spec(X*X') // Eigenvalues and eigenvectors of XX'
   for k = 1:kmax // Loop on the number of factor k
      [eigen,ind] = gsort(diag(vals),'g','i')
      vectors=real(vectors(:,ind))
      facts = sqrt(T)*vectors(:,T-k+1:T); // Estimated Factors with kmax Factors
      loadings = (X*facts)/T; // Estimated Matrix of Factor Loadings
      betahat = loadings*chol((loadings'*loadings)/N); // Rescaled Estimator of the Factor Loading
      Z=X-X*betahat*invxpx(betahat)*betahat'// Estimated Residuals
      V(k) = sum(Z .^2)/(N*T); // V(k,Fk)
   end
 
else // Case T>N
   [vectors,vals] =spec(X'*X)
   for k = 1:kmax // Loop on the number of factor k
      [eigen,ind] = gsort(diag(vals),'g','i')
      vectors=real(vectors(:,ind))
      loadings = sqrt(N)*vectors(:,N-k+1:N) // Estimated Matrix of Factor Loadings with kmax Factors
      facts = (X*loadings)/N; // Estimated Factors
      betahat =(X'*X)*loadings/(N*T) // Rescaled Estimator of the Factor Loading
      Z=X-X*betahat*invxpx(betahat)*betahat'// Estimated Residuals
      V(k) = sum(Z .^2)/(N*T); // V(k,Fk)
   end
 
end
 
 
//-----------------------------------
//--- Panel Information Criteria ----
//-----------------------------------
IC = ones(1,4) .*. [0:kmax]';// IC information Criteria (IC1, IC2 and IC3)
PC = IC // PC information Criteria (PC1, PC2 and PC3)
AIC3 = ones(1,2) .*. [0:kmax]'// AIC information Criteria (AIC1, AIC2 and AIC3)
BIC3 = AIC3 // BIC information Criteria (BIC1, BIC2 and BIC3)
kk = ones(1,3) .*. [1:kmax]'// Matrix with increments
 
IC(1,2:4) = log(mean0(sum((X .* X)/T,'r')))*ones(1,3);// IC information Criteria when r=0
PC(1,2:4) = mean0(sum((X .* X)/T,'r'))*ones(1,3);// PC information Criteria when r=0
AIC3(1,2) = mean0(sum((X .* X)/T,'r')) // PC information Criteria when r=0
BIC3(1,2) = mean0(sum((X .* X)/T,'r')) // PC information Criteria when r=0
 
//--------------------------
//--- PC and IC Criteria ---
//--------------------------
CNT = min(N,T);// Function Cnt^2
Penalty = [((N+T)/(N*T))*log((N*T)/(N+T)),((N+T)/(N*T))*log(CNT),log(CNT)/CNT];// Penalty Terms for IC and PC
Penalty = ones(kmax,1) .*. Penalty;// Penalty Terms for IC and PC
PC(2:$,2:$) = (ones(1,3) .*. V)+(var_Z_kmax*mtlb_double(kk)) .*Penalty;// IC information Criteria (IC1, IC2 and IC3)
 
IC(2:$,2:$) = log((ones(1,3) .*. V))+ kk .*Penalty;// PC information Criteria (PC1, PC2 and PC3)
BIC3(2:$,2) = V+(kk(:,1)*var_Z_kmax).*(N+T-kk(:,1))*log(N*T)/(N*T)// BIC3 criterium
AIC3(2:$,2) = V+(kk(:,1)*var_Z_kmax).*(N+T-kk(:,1))*2/(N*T) // AIC3 criterium
 
//------------------------------------------
//--- Estimated Number of Common Factors ---
//------------------------------------------
[PCs,khat_PC] = min(PC(:,2:4),"r")
khat_PC = khat_PC-1 // Estimated Numbers of Factor with IC
 
[ICs,khat_IC] =min(IC(:,2:4),"r")
khat_IC = khat_IC-1// Estimated Numbers of Factor with PC
 
[BIC3s,khat_BIC3] = min(BIC3(:,2),"r")
khat_BIC3 = khat_BIC3-1 // Estimated Numbers of Factor with BIC3
 
[AIC3s,khat_AIC3] = min(AIC3(:,2),"r")
khat_AIC3 = khat_AIC3-1 // Estimated Numbers of Factor with AIC3
 
khat = [khat_IC,khat_PC,khat_AIC3,khat_BIC3];// Estimated Numbers of Factor with different criteria
 
//================
//=== RESULTS ====
//================
results=tlist(['results';'meth';'kmax';'Vkmax';'factors';'loadings';'khat';'khat_IC';'khat_PC';...
'khat_AIC3';'khat_BIC3';'IC';'PC';'AIC3';'BIC3'],...
'Nbfactors',kmax,var_Z_kmax,facts,loadings,khat,khat_IC,khat_PC,khat_AIC3,khat_BIC3,IC,...
PC,AIC3,BIC3)
 
endfunction
