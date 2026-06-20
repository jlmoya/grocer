function [Q,R]=tvp_param1a(param)
 
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
// * b0 = (k x 1) vector of intial conditions for b
// -------------------------------------------------------------
// NOTE: Q is not assumed diagonal and priorb0 is not estimated
// -------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
R = param(1)^2
s=size(param,1)
k=round(-0.5+0.5*sqrt(1+8*(s-1)))
Q = tril(matrix(duplication(k)*param(2:s,1),k,k))
Q=Q*Q'
endfunction
