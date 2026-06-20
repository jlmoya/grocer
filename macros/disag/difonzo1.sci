function [y,res]=difonzo1(Y,x,z,ta,s,typemod)
 
// PURPOSE: Multivariate temporal disaggregation with transversal constraint
// -----------------------------------------------------------------------------
// INPUT:
// * Y = NxM real vector
//     ---> M series of low frequency data with N observations
// * x = nxM real vector
//     ---> M series of high frequency data with n observations
// * z = nx1 ---> high frequency transversal constraint with nz obs.
// * ta = type of disaggregation
//      ta=1 ---> sum (flow)
//      ta=0 ---> average (index)
//      ta=i ---> i th element (stock) ---> interpolation
// * s = number of high frequency data points for each low frequency data point
//      s= 4 ---> annual to quarterly
//      s=12 ---> annual to monthly
//      s= 3 ---> quarterly to monthly
// * typemod = model for the high frequency innovations
//            typemod='wn' ---> multivariate white noise
//            typemod='rw' ---> multivariate random walk
// -----------------------------------------------------------------------
// OUTPUT:
// * y = the disaggregated variable
// * res= a result tlist with:
//   - res('meth')      = 'Multivariate di Fonzo'
//   - res('typemod')   = type of the model for the high frequency innovations
//   - res('ta')        = type of disaggregation
//   - res('nobs_lf')   = nobs of low frequency data
//   - res('nobs_hf')   = nobs of high-frequency data
//   - res('pred')      = number of extrapolations
//   - res('s')         = frequency conversion between low and high freq
//   - res('y')         = high frequency estimate
//   - res('y_lf')      = low frequency data
//   - res('indicator') = high frequency indicators
//   - res('transversal') = high frequency transversal constraint
//   - res('y_dt')      = high frequency estimate: standard deviation
//   - res('resid')     = high frequency residuals
//   - res('resid_U')   = low frequency residuals
//   - res('beta')      = estimated model parameters
//   - res('sd')        = standard deviation of the estimated model parameters
// -----------------------------------------------------------------------
// NOTE: Extrapolation is automatically performed when n>sN.
//       If n=nz>sN restricted extrapolation is applied.
//       Finally, if n>nz>sN extrapolation is perfomed in constrained
//       form in the first nz-sN observatons and in free form in
//       the last n-nz observations.
// -----------------------------------------------------------------------
// REFERENCE: di Fonzo, T.(1990)""""The estimation of M disaggregate time
// series when contemporaneous and temporal aggregates are known"""", Review
// of Economics and Statistics, vol. 72, n. 1, p. 178-182.
// -----------------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from Matlab programs written by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
//--------------------------------------------------------
//       Preliminary checking
 
[N,M] = size(Y);
[n,m] = size(x);
[nz,mz] = size(z);
 
// Number of extrapolations
h1 = n-nz;
h2 = n-s*N;
clear('m','nz','mz');
 
 
//--------------------------------------------------------
//  **** CONSTRAINT MATRICES ***
//--------------------------------------------------------
// Required:
//              H1 ---> transversal
//              H2 ---> longitudinal
//
//---------------------------------------------------------------
//       Generate H1: (n-h1) x nM
 
H1 = ones(1,M).*.[eye(n-h1,n-h1),zeros(n-h1,h1)];
 
//---------------------------------------------------------------
//       Generate H2: NM x nM.
//
// Generation of aggregation matrix C
 
 
C = aggreg1(n,s,ta);
C = [C,zeros(N,h2)];
 
H2 = eye(M,M).*.C;
 
//---------------------------------------------------------------
//       Generate H: (n-h1+NM) x nM.
//
//       H = [ H1
//             H2 ]
 
H = [H1;H2];
 
//--------------------------------------------------------
//  **** PREPARING DATA MATRICES ***
//--------------------------------------------------------
// Required:
//               x_diag
//               Y_big,  Y_e
//               X_diag, X_e
 
//--------------------------------------------------------
//       Generate x_diag: nM x pM
//
// It is a diagonal matrix formed by the high frequency
// indicators, including a vector of ones for the intercept
//
//       x_diag = [ x1 0  0  ... 0
//                  0  x2 0  ... 0
//                  0  0  x3 ... 0
//                  ..............
//                  0  0  0  ... xM ]
//
// It is made by means of a recursion.
 
x_diag = [ones(n,1),x(:,1)];
// Initialization of the recursion
j = 2;
while j<=M then
  xaux = x(:,j);
  xaux = [ones(n,1),xaux];
  x_diag = [x_diag,zeros((j-1)*n,2);zeros(n,2*(j-1)),xaux];
  j = j+1;
end
clear('xaux');
 
//--------------------------------------------------------
//       Generate X_diag: NM x pM
//
// Low frequency analog of x_diag. It is the result of
// applying the temporal aggregator H2 to x_diag.
 
X_diag = H2*x_diag;
 
//--------------------------------------------------------
//       Generate X_e: (n-h1+NM) x pM
//
//
// It is the result of applying the complete aggregator H
// (temporal as well as transversal).
// Lower part of X_e is X_diag.
 
X_e = H*x_diag;
sx=size(X_e,2)
 
//--------------------------------------------------------
//       Generate Y_big: NM x 1
//
// It is column vector containing all the observations on the
// low frequency series according to: Y_big = [Y1 Y2 ... YM]'
// Formally: Y_big = vec(Y)
 
Y_big = vec(Y);
 
//--------------------------------------------------------
//       Generate Y_e: (n-h1+NM) x 1
//
// It is column vector containing the transversal constraint
// and all the observations on the low frequency series
// according to: Y_e = [ z Y1 Y2 ... YM]' = [z Y_big]'
 
Y_e = [z;Y_big];
 
//--------------------------------------------------------
//  **** PRELIMINARY ESTIMATION OF SIGMA ***
//--------------------------------------------------------
// The method of di Fonzo requires the previous estimation of VCV
// matrix SIGMA for the (implied) low frequency model. This
// preliminary estimation is performed by means of estimating, equation
// by equation, the model. Formally, this is equivalent to estimate an
// unrelated SURE model. Computationally, this is also the applied procedure.
 
BETA = ols0(Y_big,X_diag);
// OLS estimator
U_big = Y_big-X_diag*BETA;
// Residuals in vec format
 
// Residuals (columnwise) U: NxM
U = matrix(U_big,-1,M);
 
// Preliminary estimation of SIGMA
SIGMA = U'*U/N
 
//--------------------------------------------------------
//  **** APPLYING DI FONZO PROCEDURE ***
//--------------------------------------------------------
 
//--------------------------------------------------------
//       High frequency VCV matrix v: nM x nM
 
select typemod
case 'wn' then
  // White noise
  v = SIGMA.*.eye(n,n);
case 'rw' then
  // Random walk, with U(0)=0
  D = eye(n,n) - [zeros(1,n) ; diag(ones(n-1,1)) zeros(n-1,1)]
  DDi = invxpx(D);
  v = SIGMA .*. DDi;
end
 
//--------------------------------------------------------
//       Low frequency VCV matrix V: (n-h1+NM) x (n-h1+NM)
//       and its generalized inverse
 
V = H*v*H';
Vi = pinv(V);
// Moore-Penrose generalized inverse
 
//--------------------------------------------------------
//       Generation of distribution filter L: nM x (n-h1+NM)
 
L = v*H'*Vi;
 
//--------------------------------------------------------
//      GLS estimation of beta in a SURE context
ixpx=pinv(X_e'*Vi*X_e)
bet = ixpx*X_e'*Vi*Y_e
 
U_e = Y_e-X_e*bet
 
//--------------------------------------------------------
//       Estimation of high frequency series
 
y_big = x_diag*bet+L*U_e;
 
// Series y in column format y: nxM
 
y = matrix(y_big,n,M);
 
//--------------------------------------------------------
 
//       VCV matrix of estimations y: nM x nM
 
sigma_y = (eye(n*M,n*M)-L*H)*v+(x_diag-L*X_e)*pinv(X_e'*Vi*X_e)*((x_diag-L*X_e)');
 
// Vector format of std. dev.
 
d_y_big = sqrt(diag(sigma_y));
 
// Std. dev. series in column format dt_y: n x M
 
d_y = matrix(d_y_big,n,M);
 
res = tlist(['results';'meth';'typemod';'ta';'nobs_lf';'nobs_hf';...
'pred';'s';'y';'y_lf';'indicator';'transversal';...
'y_lo';'resid';'resid_U';'beta';'sd'],...
'Multivariate di Fonzo',typemod,ta,N,n,h2,s,y,Y,x,z,d_y,L*U_e,U_e,bet,d_y)
 
endfunction
