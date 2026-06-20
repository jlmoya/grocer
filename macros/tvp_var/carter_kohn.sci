function bdraw = carter_kohn(y,X,R,Q,m,p,t,B0,V0,tol)
 
// PURPOSE: provides Carter and Kohn (1994) algorithm to perform
// Gibbs sampling for state space model:
//     y(t) = X(t) beta(t) + e(t)
//     beta(t) = beta(t-1) + u(t)
// with :
//     V(e(t) = R(t)
//     V(u(t) = Q
//     E(beta(0)) = B0
//     V(beta(0)) = V0
// ------------------------------------------------------------
// INPUT:
// * y = (k x T) matrix of measured variables
// * X = (p*T x p) matrix of exgenous variables in the
//   measurement equation
// * R = a (p*T xp) matrix of (non-constant) variance of
//   the measuremet eqation
// * Q = a (p x p) matrix of (constant) variance of the sate
//   equation
// * m = a scalar, the size of then beta(t) vector
// * p = a scalar, the size of then y(t) vector
// * B0 = a (m x 1) vector, the prior expectation of beta(0)
// * V0 = a (m x m) matrix, the prior varaince of beta(0)
// * tol = the threshold use to assess that a variance matrix is
//   singular
// ------------------------------------------------------------
// OUTPUT:
// * bdraw = a (m x t) matrix of draws for beta(t)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by Gary Koop and
// Dimitris Korobilis (http://personal.strath.ac.uk/gary.koop)
 
bp = B0;
Vp = V0;
bt = zeros(m,t);
Vt = zeros(m,m*t);
 
for i=1:t
   Ri = R((i-1)*p+1:i*p,:);
   Xi = X((i-1)*p+1:i*p,:);
   Xi_Vp=Xi*Vp
   cfe = y(:,i) - Xi*bp;     // conditional forecast error
   f = Xi_Vp*Xi' + Ri;      // variance of the conditional forecast error
   invf_Xi_Vp = f\Xi_Vp;
   bp = bp + invf_Xi_Vp'*cfe;
   bt(:,i) = bp;
 
   Vtt = Vp - Xi_Vp'*invf_Xi_Vp;
   Vtt=(Vtt+Vtt')/2
   Vp=Vtt+Q
   Vt(:,(i-1)*m+1:i*m) = Vtt
end;
 
// draw Sdraw(T|T) ~ N(S(T|T),P(T|T))
bdraw = zeros(m,t);
 
bdraw(:,t) = mvnrnd1(bp,Vtt,1,tol);
// Backward recursions
for i = 1:t-1
   bf = bdraw(:,t-i+1);
   btt = bt(:,t-i);
   Vtt = Vt(:,(t-i-1)*m+1:(t-i)*m)
   f = Vtt+Q;
   inv_f_Vtt = f\Vtt;
   cfe = bf-btt;
   bmean = btt+inv_f_Vtt'*cfe;
   bvariance = Vtt - Vtt*inv_f_Vtt;
   bvariance=(bvariance+bvariance')/2
 
   bdraw(:,t-i) = mvnrnd1(bmean,bvariance,1,tol);
end;
 
endfunction
