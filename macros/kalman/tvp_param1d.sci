function [Q,R]=tvp_param1d(param)
 
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
// NOTE: Q is assumed diagonal and priorb0 is not estimated
// -------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
R = param(1)
Q = diag(param(2:size(param,1)))
endfunction
