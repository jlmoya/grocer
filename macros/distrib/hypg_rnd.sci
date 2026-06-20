function [x]=hypg_rnd(num,n,K,N)
 
// PURPOSE: hypergeometric random draws
// prob(X=x) = (N)^-1 (K)(N-K)
//             (n)    (x)(n-x)
// ------------------------------------------------------------
// INPUT:  num = the number of draws (for x a (num x 1) vector
//               of draws) or a (2 x 1) vector
//              (for x a (num(1) x (num(2)) matrix)
//        n,K,N = parameters of the distribution
// ------------------------------------------------------------
// OUTPUT:
// x = a vector of random draws from the distribution
// ------------------------------------------------------------
// NOTE: mean     = (n/N)*k
//       variance = [(n*K)/(N*N)*(N-1)]*(N-K)*(N-n)
// ------------------------------------------------------------
//       Copyright (c) Anders Holtsberg
// translated to scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
if size(num) == 1 then
   num=[num;1]
end
 
x = hypg_inv(grand(num(1),num(2),'def'),n,K,N);
 
endfunction
