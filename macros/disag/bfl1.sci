function [y,res]=bfl1(Y,ta,d,s)
 
// PURPOSE: Temporal disaggregation using the Boot-Feibes-Lisman method
// -----------------------------------------------------------------------
// INPUT:
// * Y = Nx1 vector of low frequency data
// * ta = type of disaggregation
//   - ta=-1 ---> sum (flow)
//   - ta=0 ---> average (index)
//   - ta=i ---> i-th element (stock) ---> interpolation
// * d = objective function to be minimized: volatility of ...
//   - d=0 ---> levels
//   - d=1 ---> first differences
//   - d=2 ---> second differences
// * s = number of high frequency data points for each low frequency data point
//   - s= 4 ---> annual to quarterly
//   - s=12 ---> annual to monthly
//   - s= 3 ---> quarterly to monthly
// -----------------------------------------------------------------------
// OUTPUT:
// * y = High frequency estimate
// * res = a results tlist with:
//   - res('meth')         = 'Boot-Feibes-Lisman';
//   - res('nobs_lf')      = Number of low frequency data
//   - res('aggreg_mode')  = Type of disaggregation
//   - res('s')            = Frequency conversion
//   - res('diff')         = Degree of differencing
//   - res('y_lf')         = Low frequency data
//   - res('y')            = High frequency estimate
// -----------------------------------------------------------------------
// REFERENCE: Boot, J.C.G., Feibes, W. y Lisman, J.H.C. (1967)
// """"Further methods of derivation of quarterly figures from annual data"""",
// Applied Statistics, vol. 16, n. 1, p. 65-75.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from a Matlab program written
// by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
// -----------------------------------------------------------------------
// Size of the problem
 
[N,M] = size(Y);
n = s*N;
 
// -----------------------------------------------------------------------
// Generation of aggregation matrix C
 
C = aggreg1(n,s,ta);
 
// -----------------------------------------------------------------------
// Generation of (implicit) VCV matrix H: nxn
// depending on the selected objective function
//       d=0 ---> H=I
//       d=1 ---> H=D
//       d=2 ---> H=D*D
 
select d
case 0 then
 
  H = eye(n,n);
  // Levels
case 1 then
  D = zeros(n-1,n);
  // First differences
  for i = 1:n-1
    D(i,i) = -1;
    D(i,i+1) = 1;
  end
  H = D'*D;
case 2 then
  D = zeros(n-2,n);
  // Second differences
  for i = 1:n-2
    D(i,i) = 1;
    D(i,i+1) = -2;
    D(i,i+2) = 1;
  end
  H = D'*D;
else
  error(' *** IMPROPER VALUE d FOR OBJECTIVE FUNCTION *** ');
end
 
// -----------------------------------------------------------------------
// Computing high frequency series:
//       1. Generation of supermatrix A
//       2. Expandig low freq. input
//       3. y=inv(A)*Ye. Selection of relevant part: 1..n
 
A = [H C';C zeros(N,N)];
 
Ye = [zeros(n,1);Y];
 
y = A\Ye;
y = y(1:n);
 
// -----------------------------------------------------------------------
// Loading the structure
// -----------------------------------------------------------------------
 
// Basic parameters
res = tlist(['results';'meth';'N';'aggreg_mode';'aggreg_lvl';...
'diff';'y_lf';'y'],'Boot-Feibes-Lisman',N,ta,s,d,Y,y)
 
endfunction
