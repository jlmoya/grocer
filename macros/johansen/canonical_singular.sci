function [lambda,bet]=canonical_singular(s11,s10,s00,m,r)
 
[eigenv,rho]=spec(s11)
[rho,aind]=gsort(real(diag(rho)),'g','d')
C=eigenv(:,aind(1:m))*diag(ones(m,1)./sqrt(rho(1:m)))
[u,lambda]=spec(C'*s10*pinv(s00)*s10'*C)
[lambda,aind]=gsort(real(diag(lambda)),'g','d')
lambda=lambda(1:r)
bet=C*u(:,aind(1:r))
 
endfunction
 
