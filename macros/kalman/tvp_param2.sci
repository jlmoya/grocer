function [Q,R,priorb0]=tvp_param2(param,k)
 
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
// NOTE: Q is assumed diagonal and priorb0 is estimated
// -------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
s = size(param,1)
R = param(1)^2
Q = diag(param(2:s-k).^2)
priorb0 = param(s-k+1:s)
endfunction
