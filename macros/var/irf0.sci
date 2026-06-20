function [IRF,PHI]=irf0(bet,S,N,p,P)
 
// PURPOSE: Calculates Impulse Response Function for VAR
//          (low level function)
//-------------------------------------------------------------
// REFERENCES:
// * Hamilton, Time Series Analysis (1994)
// * Lütkepohl, Introduction to Time Series Analysis (1994)
// ------------------------------------------------------------
// INPUT:
// * bet = estimated parameters from a VAR
// * S = # of periods
// * N = dimension of the VAR
// * p = # of lags
// * P = matrix such that P*e = u
//       where u is the residual from the VAR regression
//             e is the residual to be shocked
//-------------------------------------------------------------
// OUTPUT:
// * IRF = ((S+1) x T) impulse response functions
// * PHI = (N*p x T) matrix of coefficients
//-------------------------------------------------------------
// Copyright Eric Dubois 2017
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// Mike Cliff, UNC Finance  mcliff@unc.edu
 
// load PHI=[A(p)... A(1)] in Y=A(0)+A(1)Y(-1)+...+A(p)Y(-p)+U
PHI = ones(N,N*p)
for i=1:p
   PHI(:,(i-1)*N+[1:N]) = bet([1+(p-i)*N:(p-i+1)*N],:)'
end
 
IRF = [zeros(N*(p-1),N);P;zeros(N*S,N)]
 
for s = 1:S
   IRF((s+p-1)*N+1:N*(s+p),:) = PHI*IRF((s-1)*N+1:N*(s+p-1),:) ;
end
IRF=IRF(N*(p-1)+1:$,:)
 
endfunction
