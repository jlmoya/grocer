function [grocer_g]=numz0(grocer_namefunc,grocer_param,grocer_k,grocer_g,grocer_delta,varargin)
 
// PURPOSE: calculate a numerical derivative of function
// namefunc at point param
// ------------------------------------------------------------
// INPUT:
// * grocer_namefunc = name of function namefunc with the parameters
//   as first argument
// * grocer_param = point where the derivative is calculated
// * grocer_k = dimension of param
// * grocer_g = a pre-determinated matrix with dimension (k,n) where n
//   is the dimension of namefunc
// * grocer_delta = the Increment used to evaluate the derivative
//    if grocer_delta = [] the increment is chossen to be %eps^(1/3) (see NOTES)
// * varargin = the arguments other than param in function
//   namefunc
// ------------------------------------------------------------
// OUPTUT:
//  * grocer_g = numerical derivative
// ------------------------------------------------------------
// NOTES:
// * %eps^(1/3) is the optimal stepsize for the gradient
// * used by the following functions: nls(), maxlik()
// ------------------------------------------------------------
// Copyright: Eric Dubois/Emmanuel Michaux 2002-20016
// http://grocer.toolbox.free.fr/grocer.htm
// adapted and improved from:
// Mike Cliff,  UNC Finance   mcliff@unc.edu
 
if isempty(grocer_delta)  then
   grocer_delta = (%eps^(1/3)*grocer_param+sqrt(%eps)*(grocer_param==0))
end
 
grocer_xdh = grocer_param+grocer_delta
grocer_delta = grocer_xdh-grocer_param // improves accuracy
grocer_id=diag(grocer_delta)
 
for grocer_i=1:grocer_k
   grocer_g(grocer_i,:)=(grocer_namefunc(grocer_param+...
      grocer_id(:,grocer_i),varargin(:))-...
      grocer_namefunc(grocer_param-grocer_id(:,grocer_i),...
      varargin(:)))'/2/grocer_delta(grocer_i)
end
 
endfunction
