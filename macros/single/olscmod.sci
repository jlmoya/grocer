function varargout=olscmod(grocer_model,grocer_tsmat,grocer_indeq,varargin)
 
// PURPOSE: compute Cochrane-Orcutt ols Regression for AR1
// errors for equations of a model
// ------------------------------------------------------------
// INPUT:
// * grocer_model = a model tlist
// * grocer_tsmat = a tsmat containing all data needed for
//   estimating the equation (should be the tsmat associated to
//    the model, created by function create_dbmod)
// * grocer_indeq =
//   - a string, the name of the equation to estimate or the
//   keyword 'all' (to estimate all equations)
//   - or an integer, the # of the equation in the model
// * varargin = optional arguments which can be:
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'maxit=n' where n is the maximum number of
//     iterations that can be performed (default = 100)
//   . the string 'crit=n' where crit is the convergence
//     criterion, used to assess if the difference between
//     successive values of the autocorrelation coefficient is
//     significant (default=sqrt(%eps))
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
//   - the string 'save=%t' if the user wants to save the
//     estimated coefficients in the model tlist
// ------------------------------------------------------------
// OUTPUT:
// varargout =  a variable number of arguments with:
// * Arg # 1: the input model tlist, updated with the estimated
//   coefficients of the equations given in argument
//   grocer_indeq if the user has entered the option 'save=%t'
// * following arguments: a variable number of olsc results
//   tlists, each one corresponding to the results of the
//   corresponding estimated equation
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2007
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
// set default values
grocer_prt=%t
grocer_crit=sqrt(%eps)
grocer_maxit=100
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
 
[grocer_model,grocer_listout]=estim_univmod(grocer_model,grocer_indeq,olsc1,grocer_save,grocer_prt,grocer_maxit,grocer_crit)
 
varargout=lstcat(list(grocer_model),grocer_listout)
 
endfunction
