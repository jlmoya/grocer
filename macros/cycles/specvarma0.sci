function S = specvarma0(sig,AR,MA,omega)
 
// PURPOSE: estimate parametric spectral density for VARMA
// models at frequency omega
//----------------------------------------------------------
// INPUTS:
// . sig = variance-covariance matrix of residuals
// . AR  = matrix of AR coefficients ar = [A1 .. Ap]
// . MA  = matrix of MA coefficients ma = [B1 .. Bq]
// . omega = vector of frequency
//----------------------------------------------------------
// OUPUTS:
// . S = spectrum or cross-spectrum
//----------------------------------------------------------
// Free adaptation from J. Matheron, CRECH, Banque de France
// by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
N = size(AR,1)
nomega = size(omega,1)
S = ones(nomega,N^2)
 
for k = 1:nomega
  x = exp(-%i*omega(k))
  ac = agf(x,AR,MA)
  s = ac*sig*ac'./(2*%pi) // spectrum
  s = s-diag((diag(s)))+diag(real(diag(s))) //make sure that the diagonal is real
  s = matrix(s,1,N^2)
  S(k,:) = s
end
 
endfunction
