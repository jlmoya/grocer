function [y,res]=denton1(Y,x,z,d,ta,s)
 
// PURPOSE: Multivariate temporal disaggregation with transversal constraint
// -----------------------------------------------------------------------
// INPUT:
// * Y = (NxM) matrix ---> M series of low frequency data with N observations
// * x = (nxM) matrix ---> M series of high frequency data with n observations
// * z = (nx1) vector ---> high frequency transversal constraint
// * d = objective function to be minimized: volatility of
//    - d=0 ---> levels
//    - d=1 ---> first differences
//    - d=2 ---> second differences
// * ta = type of disaggregation
//    - ta=-1 ---> sum (flow)
//    - ta=0 ---> average (index)
//    - ta=i ---> i th element (stock) ---> interpolation
// * s = number of high frequency data points for each low frequency data point
//   - s= 4 ---> annual to quarterly
//   - s=12 ---> annual to monthly
//   - s= 3 ---> quarterly to monthly
// -----------------------------------------------------------------------------
// OUTPUT:
// * y = the disaggregated variable
// * res = a results tlist with
//   - res('meth')         = 'Multivariate Denton';
//   - res('ta')           = Type of disaggregation
//   - res('nobs_lf')      = Number of low frequency data
//   - res('nobs_hf')      = Number of high frequency data
//   - res('pred')         = Number of extrapolations (=0 in this case)
//   - res('s')            = Frequency conversion
//   - res('diff')         = Degree of differencing
//   - res('y')            = High frequency estimate
//   - res('y_lf')         = low frequency data
//   - res('indicator')    = high frequency indicators
//   - res('tanvsersal')   = data for the transversal constraint
// -----------------------------------------------------------------------
// REFERENCE: di Fonzo, T(' (1994) """"Temporal disaggregation of a system of
// time series when the aggregate is known: optimal vs(' adjustment methods"""",
// INSEE-Eurostat Workshop on Quarterly National Accounts, Paris, december
// -----------------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from a Matlab program written by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
//--------------------------------------------------------
//  **** CONSTRAINT MATRICES ***
//--------------------------------------------------------
// Required:
//   -      H1 ---> transversal
//   -      H2 ---> longitudinal
//
//---------------------------------------------------------------
//       Generate H1: n x nM
 
H1 = ones(1,M).*.eye(n,n);
 
//---------------------------------------------------------------
//       Generate H2: NM x nM.
//
// Generation of aggregation matrix C
 
C = aggreg1(n,s,ta);
H2 = eye(M,M).*.C;
 
//---------------------------------------------------------------
//       Generate H: n+NM x nM.
//
//       H = [H1
//   -  H2 ]
 
H = [H1;H2];
//--------------------------------------------------------
//  **** PREPARING DATA MATRICES ***
//--------------------------------------------------------
// Required:
//   -       x_big
//   -       Y_big, Y_e
//   -       X_diag, X_e
 
//--------------------------------------------------------
//       Generate x_big: nM x 1
x_big = vec(x);
 
//--------------------------------------------------------
//       Generate Y_big: NM x 1
Y_big = vec(Y);
 
//--------------------------------------------------------
//       Generate Y_e: n+NM x 1
//
//        It is column vector containing the transversal
//        constraint and all the observations
//        on the low frequency series
//    according to: Y_e = [ z Y1 Y2 ... YM]' = [z Y_big]'
 
Y_e = [z;Y_big];
 
//--------------------------------------------------------
//       Filtering matrices
 
select d
case 0 then
   D = eye(n,n)
case 1 then
   D = eye(n,n) - [zeros(1,n) ; diag(ones(n-1,1)) zeros(n-1,1)]
case 2 then
   D=eye(n,n) + [zeros(2,n) ; diag(ones(n-2,1)) zeros(n-2,2)]-...
   2*[zeros(2,n) ; zeros(n-2,1) diag(ones(n-2,1)) zeros(n-2,1)]
else
  error(' *** IMPROPER DEGREE OF DIFFERENCING *** ');
end
 
DD = D'*D;
Wi = eye(M,M) .*. inv(DD) ;
Vi = pinv(H*Wi*H');
 
//--------------------------------------------------------
//       Estimation
 
U_e = Y_e-H*x_big;
y_big = x_big+Wi*H'*Vi*U_e;
 
// Series y in column format y: nxM
 
y = matrix(y_big,n,M);
res=tlist(['results';'meth';'ta';'nobs_lf';'nobs_hf';'aggreg_lv';...
'diff';'y';'y_lf';'indicator';'transversal'],..
'Multivariate Denton',ta,N,n,s,d,y,Y,x,z)
endfunction
