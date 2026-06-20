function varargout=ladmod(grocer_model,grocer_tsmat,grocer_indeq,varargin)
 
// PURPOSE: compute least absolute deviations regression
// for equations of a model
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
// * varargin = arguments which can be:
//   . a time series
//   . a real (n x 1) vector
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'win=n' where n is the length of the Barlett
//     window (default = floor(5*nobs^0.25))
//   . the string 'dropna' if the user wants to delete NAs
//     (this option should be used when dealing with daily and
//     weekly TS)
//   . 'save=%t' if the user wants to save the estimated
//   coefficients in the model tlist
// ------------------------------------------------------------
// OUTPUT:
// varargout =  a variable number of arguments with:
// * Arg # 1: the input model tlist, updated with the estimated
//   coefficients of the equations given in argument
//   grocer_indeq if the user has entered the option 'save=%t'
// * following arguments: a variable number of lad results
//   tlists, each one corresponding to the results of the
//   corresponding estimated equation
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the results of the regression and various diagnostics
// ------------------------------------------------------------
// Copyright: E. Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_prt=%t
grocer_crit=sqrt(%eps)
grocer_maxit=100
grocer_save=%f
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if part(grocer_argi,1:4) == 'crit' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif part(grocer_argi,1:5) == 'maxit' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif part(grocer_argi,1:4) == 'save'
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
   end
end
 
[grocer_model,grocer_listout]=estim_univmod(grocer_model,grocer_indeq,lad1,grocer_save,grocer_prt,grocer_crit,grocer_maxit)
 
varargout=lstcat(list(grocer_model),grocer_listout)
 
endfunction
