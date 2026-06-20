function [Q,R,priorb0]=tvp_param2a(param)
 
// PURPOSE: in a time-varying estimation, transform the vectors
// parameters into their matrix and vectors counterpart in the
// corresponding Kalman filter
// ------------------------------------------------------------
// INPUT:
// * param = vector of parameters
// * k = size of the vectors of parameters
// -------------------------------------------------------------
// OUTPUT:
// * Q = variance of the state equation
// * R = variance of the observation equation
// -------------------------------------------------------------
// NOTE: Q is not assumed diagonal and priorb0 is estimated
// -------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
R = param(1)^2
s=size(param,1)
// determine the # of exogenous variables from the # of parameters
k=round(-1.5+0.5*sqrt(9+8*(s-1)))
priorb0=param(s-k+1:s)
Q = tril(matrix(duplication(k)*param(2:s-k,1),k,k))
Q=Q*Q'
 
endfunction
