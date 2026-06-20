function [R,mu]=cholp1(H,S)
 
// PURPOSE: Computes the perturbed Cholesky factor R for the
// symmetric matrix H, such that R'*R = H + mu*I.
// ------------------------------------------------------------
// INPUT:
// * H = a (nxn) symmetric square matrix
// * S = a (n x n) matrix
// ------------------------------------------------------------
// OUTPUT:
// * R = a (n x n) square matrix
// * mu = a scalar
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
eigval=abs(spec(H))
sqrteps = sqrt(%eps);
if min(eigval)/max(eigval) > sqrteps then
   R=chol(H)
   mu=0
else
   H=real(H)
   [n,m] = size(H);
 
   scalin = 0;
   if or(S~=0) then
      scalin = 1;
      S=diag(S)
      S = S(1:n,:);
      d = diag(1 ./ S);
      H = d*H*d';
   end
 
   mindiag = min(diag(H));
   maxdiag = max(diag(H));
   maxpos = max(0,maxdiag);
 
  if mindiag<=sqrteps*maxpos then
     mu = 2*(maxpos-mindiag)*sqrteps-mindiag;
     maxdiag = maxdiag+mu;
  else
     mu = 0;
  end
 
   maxoff = 0;
   if n>1 then
      maxoff=max(abs(triu(H,1)))
   end
 
   if maxoff*(1+2*sqrteps)>maxdiag then
      mu = mu+maxoff-maxdiag+2*sqrteps*maxoff;
      maxdiag = maxoff*(1+2*sqrteps);
   end
   if maxdiag==0 then
      mu = 1;
      maxdiag = 1;
   end
   if mu>0 then
      H = H+mu*eye(n,n);
   end
   maxoffl = sqrt(max(maxdiag,maxoff/n));
 
   [L,maxadd] = choldc(H,maxoffl);
 
   if maxadd>0 then
   // Hb collects off-diagonal terms
       Hb=abs(triu(H,1))+abs(tril(H,-1))
       maxev=max(diag(H)+sum(Hb,'c'))
       minev=min(diag(H)-sum(Hb,'c'))
       sdd = (maxev-minev)*sqrteps-minev;
       sdd = max(sdd,0);
       mu = min(maxadd,sdd);
       H = H+mu*eye(n,n);
       [L,maxadd] = choldc(H,0);
    end
 
   if scalin then
       d = diag(S);
      L = L*d;
   end
 
   R = L';
end
 
endfunction
 
