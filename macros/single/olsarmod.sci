function varargout=olsarmod(grocer_model,grocer_tsmat,grocer_indeq,varargin)
 
// PURPOSE: computes maximum likelihood ols regression with AR1
// errors for equations in a amodel
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
//   - the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   - the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
//   - 'optfunc=optim' if the user wants to use the optim
//   optimisation function (default: optimg)
//   - 'opt_nelmead=crit,nitermax' with crit the value of the
//   convergence criterion in the Nelder-Meade optimisation
//   function and nitermax the maximum number of iterations
//   (default = 'opt_nelmead=2*%eps,1000')
//   - 'opt_optim_ineq=opts' where opts are inquality options
//   for the parameters
//  (default = ',''b'',[-1+%eps ; -%inf*ones(nvar,1)]
//   ,[1-%eps ; %inf*ones(nvar,1)]')
//   - 'opt_optim=opts' where opts are options for optim
//   that can be entered after the starting value of the
//   parameters
//   (default = 'opt_optim=,''ar'',1e6,1e6'')
//   - 'opt_convg=val' where val is the threshold on gradient
//   norm
//   (default = 'opt_convg=1e-5')
// ------------------------------------------------------------
// OUTPUT:
// varargout =  a variable number of arguments with:
// * Arg # 1: the input model tlist, updated with the estimated
//   coefficients of the equations given in argument
//   grocer_indeq if the user has entered the option 'save=%t'
// * following arguments: a variable number of ols with ar
//   residuals results tlists, each one corresponding to the
//   results of the corresponding estimated equation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_prt=%t
grocer_optim_opt=''
grocer_dropna=%f
grocer_optfunc='optim'
grocer_opt_optim=tlist(['optim options';'optim';'optim ineq';'nelmead';'convg'],...
[',''ar'',1e4,1e4'],',''b'',[-1+%eps ; -%inf*ones(nvar,1)],[1-%eps ; %inf*ones(nvar,1)]',',2*%eps,1000',1e-5)
grocer_save=%f
varargout=list(grocer_model)
 
// separate from the list of variable arguments the list of
// exogenous variables and 'noprint' if the user has given this
// argument
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi2=strsubst(varargin(grocer_i),' ','')
      grocer_largi2=length(grocer_argi2)
      if grocer_argi2 == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi2 == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:8) == 'optfunc=' then
         grocer_optfunc=part(grocer_argi2,9:grocer_largi2)
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:12) == 'opt_nelmead=' then
         grocer_opt_optim('nelmead')=part(grocer_argi2,13:grocer_largi2)
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:10) == 'opt_optim=' then
         grocer_opt_optim('optim')=part(grocer_argi2,11:grocer_largi2)
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:15) == 'opt_optim_ineq=' then
         grocer_opt_optim('optim ineq')=part(grocer_argi2,16:grocer_largi2)
         varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:10) == 'opt_convg=' then
         execstr('grocer_opt_optim(''convg'')='+part(grocer_argi2,11:grocer_largi2))
               varargin(grocer_i)=null()
      elseif part(grocer_argi2,1:4) == 'save' then
         execstr('grocer_'+grocer_argi2)
         varargin(grocer_i)=null()
      end
   end
end
 
 
[grocer_model,grocer_listout]=estim_univmod(grocer_model,grocer_indeq,olsar1_1,grocer_save,grocer_prt,grocer_optfunc,grocer_opt_optim)
 
varargout=lstcat(list(grocer_model),grocer_listout)
 
endfunction
