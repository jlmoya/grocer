function [C]=aggreg1(p,s,opt)
 
// PURPOSE: Generate a temporal aggregation matrix
// ------------------------------------------------------------
// INPUT:
// * N = number of low frequency data
// * s = freq. conversion
// * opt = type of temporal aggregation:
//   - opt = -1 ---> sum (flow)
//   - opt = 0 ---> average (index)
//   - opt = k ---> k-th element (k>=1 and k<=s)
// ------------------------------------------------------------
// OUTPUT:
// C = (N x sN) temporal aggregation matrix
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
// translated and adpated to Scilab from a Matlab program
// written by:
// Enrique M. Quilis
// Instituto Nacional de Estadistica
// Paseo de la Castellana, 183
// 28046 - Madrid (SPAIN)
 
select opt
case -1 then
   N=floor(p/s)
   C = eye(N,N) .*. ones(1,s);
case 0 then
   N=floor(p/s)
   C = eye(N,N) .*. ones(1,s)/s;
else
   k=modulo(p,s)
   N=floor(p/s)+bool2s(k>=ta)
   c= zeros(1,s);
   c(opt) = 1
   C=eye(N,N) .*. c
   C(:,p+1:N*s)=[]
end
 
endfunction
