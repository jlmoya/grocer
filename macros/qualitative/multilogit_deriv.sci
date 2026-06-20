function [g,H] = multilogit_deriv(x,d,P,nvar,ncat,nobs)
 
// PURPOSE: Computes gradient and Hessian of multinomial logit
// model
// ---------------------------------------------------------
// References: Greene (1997), p.914
 
// written by:
// Simon D. Woodcock
// CISER / Economics
// 201 Caldwell Hall
// Cornell University
// Ithaca, NY 14850
// sdw9@cornell.edu
 
// compute gradient matrix (nvar x ncat)
tmp = d - P;
g = x'*tmp;
 
// compute Hessian, which has (ncat)^2 blocks of size (nvar x nvar)
// this algorithm builds each block individually, m&n are block indices
H = zeros(nvar*ncat,nvar*ncat);
for m = 1:ncat;
   for n = 1:ncat;
      fr = (m-1)*nvar + 1;
      lr = m*nvar;
      fc = (n-1)*nvar + 1;
      lc = n*nvar;
      index = (n==m);
      index = ones(nobs,1) .*. bool2s(index);
      H(fr:lr,fc:lc) = -( ( x.*( P(:,m)*ones(1,nvar) ) )' * ( x.*( (index-P(:,n))*ones(1,nvar) ) ) )
  end;
end;
endfunction
