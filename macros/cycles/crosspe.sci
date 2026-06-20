function S = crosspe(y,k)
 
// PURPOSE: compute spectrum and cross-spectrum of a vector or a matrix
// for frequence omega
//--------------------------------------------------------------------
// INPUT:
// . y  = (T x N) matrix having variables on the columns
// . k  = truncation window
//--------------------------------------------------------------------
// OUPUT:
// . S = vector of spectrum and cross-spectrum
//--------------------------------------------------------------------
// Translated to scilab by E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
// from : Julien Matheron, Banque de France, Centre de recherche
// julien.matheron@banque-france.fr
 
 
[nargout,nargin] = argn(0)
 
// compute T and n
[T,n] = size(y);
 
// defaults
if nargin==1 then
  k = round(sqrt(T));
end;
 
// compute covariances
S = vecautcov(y,k) ;
 
 
// construct the window
w = (0:k)/k
w = [w w(k:-1:1)]'
 
// weight covariances
S = diag(w)*S(T-k:T+k,:)
 
// compute the fourier transform
omega = 0:%pi/64:2*%pi-%pi/64
S = (1/(2*%pi))*(S'*exp(-%i*(-k:k)'*omega))'
endfunction
