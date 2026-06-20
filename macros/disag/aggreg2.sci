function [C]=aggreg2(n,N,s,opt)
 
// PURPOSE: Generate a temporal aggregation matrix
// ------------------------------------------------------------
// INPUT:
// * p = number of low frequency data
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
   C = [eye(N,N) .*. ones(1,s) , zeros(N,n-s*N)]
case 0 then
   C = [eye(N,N) .*. ones(1,s)/s , zeros(N,n-s*N)]
else
   c= zeros(1,s);
   c(opt) = 1
   M=floor((n-k)/s)+1
   C0=eye(N,N) .*. c
   C=[C0(1:(M-1)*s+ta) ,  zeros(N,n-(M-1)*s+ta)]
end
 
endfunction
