function [grocer_estim_meth,varargin]=automatic_method(varargin)
 
// PURPOSE: find among the arguments given by the user of
// function automatic the one relative to the estimation
// method
// ------------------------------------------------------------
// INPUT:
// * varargin = variable arguments entered into function
//   automatic
// ------------------------------------------------------------
// OUTPUT:
// * grocer_estim_meth = the name of the econometric method
//   used by automatic
// * varargin = the remaining variable arguments
// ------------------------------------------------------------
// Copyright: Eric Dubois 2013
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_estim_meth='ols'
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_var=strsubst(varargin(grocer_i),' ','')
      if part(grocer_var,1:6) == 'estim=' then
         grocer_estim_meth=strsubst(grocer_var,'estim=','')
         varargin(grocer_i)=null()
      end
   end
end
 
 
endfunction
