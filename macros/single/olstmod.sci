function varargout=olstmod(grocer_model,grocer_tsmat,grocer_indeq,varargin)
 
// PURPOSE: estimate by ols with t-distributed errors equations
// of a model
// ------------------------------------------------------------
// INPUT:
// * grocer_model = a model tlist
// * grocer_tsmat = a tsmat containing all data needed for
//   estimating the equation (should be the tsmat associated to
//    the model, created by function create_dbmod)
// * grocer_indeq =
//   - a string, the name of the equation to estimate or the
//   keyword 'all' (to estimate all equations)
//   - or an integer, the index of the equation in the model
// * varargin = optional arguments:
//   - 'noprint' if the user does not want to print the result
//   (default: results are displayed on screen)
//   - 'save=%t' if the user wants to save the estimated
//   coefficients in the model tlist
//   - the string 'maxit=xx' if the user wants to set the
//     maximum # of iterations to xx (default=500)
//   - the string 'crit=xx' if the user wants to set the
//     convergence criterion to xx (default=1e-8)
// ------------------------------------------------------------
// OUTPUT:
// varargout =  a variable number of arguments with:
// * Arg # 1: the input model tlist, updated with the estimated
//   coefficients of the equations given in argument
//   grocer_indeq if the user has entered the option 'save=%t'
// * following arguments: a variable number of ols results
//   tlists, each one corresponding to the results of the
//   corresponding estimated equation
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018-2019
// http://grocer.toolbox.free.fr/grocer.html
 
// set default values
grocer_crit = 1e-8;
grocer_prt=%t
grocer_maxit=500
grocer_dropna=%f
grocer_save=%f
varargout=list(grocer_model)
 
// separate from the list of variable arguments the list of
// exogenous variables and options if any
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=stripblanks(varargin(grocer_i))
   if typeof(grocer_argi) == 'string' then
      if grocer_argi == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif part(grocer_argi,1:4) == 'crit' |...
         part(grocer_argi,1:5) == 'maxit' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif part(grocer_argi,1:4) == 'save' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      end
   elseif typeof(grocer_argi) ~= 'constant' then
      error('invalid type: '+typeof(varargin(grocer_i)))
   end
end
 
[grocer_model,grocer_listout]=estim_univmod(grocer_model,grocer_indeq,olst1,grocer_save,grocer_prt,grocer_crit,grocer_maxit)
 
varargout=lstcat(list(grocer_model),grocer_listout)
 
endfunction
