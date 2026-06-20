function c = vecautcov(y,nlag)
 
// PURPOSE: compute autocovariance function of a vector or martix
//-----------------------------------------------------------------
// INPUTS:
// . y 			= (TxN) matrix of data
// . nlag = the lag window size for the autocovariance
//-----------------------------------------------------------------
// OUPUT:
// . c  =  ( 2*T-1 x N^2 ) matrix where c(j,:) = transpose( E( y(t,:)'*y(t+j,:) ))
// 		and c(j,:) = 0  when j > nlag 	
//-----------------------------------------------------------------
// Translated to scilab by E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
// from : Julien Matheron, Banque de France, Centre de recherche
// julien.matheron@banque-france.fr
 
[nargout,nargin] = argn(0)
 
[T,N] = size(y)
 
if nargin < 2
	nlag = T
end 	
 
v = vec(matrix(1:N^2,N,N)')
 
U = (y'-mean0(y,1)'*ones(1,T))
 
co = zeros(N^2,T)
for j = 1:nlag
 
  F = [zeros(j-1,T);eye(T-j+1,T)]
  co(:,j) = vec(inv(T)*U*F*U')
	
end
co = co(v,:)
c = [co(v,T:-1:2),co]'
 
endfunction
