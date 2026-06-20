function varargout=hwhitemod(grocer_model,grocer_tsmat,grocer_indeq,varargin)
 
// PURPOSE: computes White's adjusted heteroscedastic
// consistent Least-squares Regression for equations of a
// model
// ------------------------------------------------------------
// INPUT:
// * grocer_model = a model tlist
// * grocer_tsmat = a tsmat containing all data needed for
//   estimating the equation (should be the tsmat associated to
//    the model, created by function create_dbmod)
// * grocer_indeq = optional arguments which can be:
//   - a string, the name of the equation to estimate or the
//   keyword 'all' (to estimate all equations)
//   - or an integer, the # of the equation in the model
// * varargin = optional arguments
//   - 'noprint' if the user does not want to print the result
//   (default: results are displayed on screen)
//   - the string 'save=%t' if the user wants to save the
//     estimated coefficients in the model tlist
// ------------------------------------------------------------
// OUTPUT:
// varargout =  a variable number of arguments with:
// * Arg # 1: the input model tlist, updated with the estimated
//   coefficients of the equations given in argument
//   grocer_indeq if the user has entered the option 'save=%t'
// * following arguments: a variable number of hwhite results
//   tlists, each one corresponding to the results of the
//   corresponding estimated equation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_dropna=%f
grocer_prt=%t
grocer_save=%f
varargout=list(grocer_model)
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      if part(grocer_argi,1:4) == 'save'
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif grocer_argi == 'noprint' then
         varargin(grocer_i)=null()
         grocer_prt=%f
      elseif grocer_argi == 'dropna' then
         varargin(grocer_i)=null()
         grocer_prt=%f
      end
   end
end
 
[grocer_model,grocer_listout]=estim_univmod(grocer_model,grocer_indeq,hwhite1,grocer_save,grocer_prt)
 
varargout=lstcat(list(grocer_model),grocer_listout)
 
endfunction
