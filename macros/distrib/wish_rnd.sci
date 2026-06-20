function [w]=wish_rnd(sigma,v)
 
// PURPOSE: generate random wishart matrix
// ------------------------------------------------------------
// INPUT:
// * sigma = symmetric pds input matrix
// * v = degrees of freedom parameter
// ------------------------------------------------------------
// OUTPUT:
// w = random wishart_n(sigma) distributed matrix
// ------------------------------------------------------------
// REFERENCES: Gelman, Carlin, Stern, Rubin, Bayesian Data
//             Analysis, (1995,96) pages 474, 480-481.
// ------------------------------------------------------------
// Copyright: Aki Vehtari/Eric Dubois
// translated and adapted from Aki Vehtari
// Helsinki University of Technology
// Lab. of Computational Engineering
// P.O.Box 9400
// FIN-02015 HUT
// FINLAND
// Aki.Vehtari@hut.fi
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin~=2 then
  error('Wrong # of arguments to wish_rnd');
end
 
[n,k] = size(sigma);
 
if n~=k then
  error('wish_rnd: requires a square matrix');
elseif n<k then
  warn('wish_rnd: n must be >= k+1 for a finite distribution');
end
 
y=grand(v,'mn',zeros(n,1),sigma)
w = y*y';
endfunction
