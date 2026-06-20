function A=Abuild(nn,nq,g,root)
 
// PURPOSE: builds the nn x nn A matrix in A.12 in
//  Christiano-Fitzgrald (1999) paper
//   if root == 1 (unit root)
//      Abig is used to construct all but the last 2 rows of the A matrix
//   elseif root == 0 (no unit root)
//      Abig is used to construct the entire A matrix
//
// ------------------------------------------------------------
// INPUT:
// * nn = # of observations
// * nq = truncation lag
// * g = a (nx1) vector (equal to the convoltion of the ma
//   part of the process with its reverse
// * root = the # of unit roots in the process (0 or 1)
// ------------------------------------------------------------
// OUPTUT:
// * A = a (nnxnn) matrix
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
// adapted from Terry Fitzgerald
//   tj.fitzgerald@clev.frb.org
//
 
if root==1 then
  Abig = zeros(nn-2,nn+2*(nq-1));
  for j = 1:nn-2
    Abig(j,j:j+2*nq) = g';
  end
  A = Abig(:,nq:nn+nq-1);
  //   construct A(-f)
  Q = -ones(nn-1,nn);
  Q = tril(Q);
  F = zeros(1,nn-1);
  F(nn-1-nq:nn-1) = g(1:nq+1)
  A(nn-1,:) = F*Q;
  //    construct last row of A
  A(nn,:) = ones(1,nn);
else
  Abig = zeros(nn,nn+2*(nq-1));
  for j = 1:nn
    Abig(j,j:j+2*nq) = g';
  end
  A = Abig(:,nq+1:nn+nq);
end
//    multiply A by 2*pi
A = 2*%pi*A;
 
endfunction
