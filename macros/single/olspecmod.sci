function varargout=olspecmod(grocer_model,grocer_tsmat,grocer_indeq,varargin)
 
// PURPOSE: perform ordinary least-squares and standard
// specification test (Chow in-sample stability tests computed
// at 50% and 90% of the sample; Doornik and Hansen normality
// test; heteroskedasticity test called xi² by D.F. Hendry;
// AutoRegressive Lagrange multiplier tests at order 4) or
// any tests given by the user for equations in a model
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
// * varargin = arguments which can be:
//   . a time series
//   . a real (nxp) vector
//   . a string equal to the name of a time series or a (nxp)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . the string 'arlm(n)' where n is the order of the ar
//     Lagrange multiplier test if the user wants another lag
//     than 4
//   . the string 'test=x1,...,xp' where xi is the name of a
//     test function
//   . the string 'dropna' if the user wants to use in the
//     regression all dates with no NA value in any variable
//     (the main use of this option should be when dealing with
//     daily ts)
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
// Copyright: Eric Dubois 2019
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_prt = %t
grocer_nar = 4
grocer_ltest=emptystr()
grocer_names=tlist(['names';'jbnorm';'doornhans';'hetero_sq';...
     'chowtest';'predfailin';'arlm';'reset'],'Jarque & Bera',...
     'Doornik & Hansen','hetero x_squared','Chow',...
     'Chow pred. fail. ','AR','reset')
grocer_save=%f
varargout=list(grocer_model)
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      if grocer_argi == 'noprint' then
         varargin(grocer_i)=null()
         grocer_prt = %f
      else
         str4=part(grocer_argi,[1:4])
         str5=part(grocer_argi,[1:5])
         str7=part(grocer_argi,[1:7])
         if str5 == 'arlm(' then
            grocer_ltest='predfailin(0.5),predfailin(0.9),doornhans,'+varargin(grocer_i)+',hetero_sq'
            varargin(grocer_i)=null()
         elseif str4 == 'save' then
            execstr('grocer_'+grocer_argi)
            varargin(grocer_i)=null()
         elseif str4 == 'test' then
            grocer_ltest=part(grocer_argi,6:length(grocer_argi))
            varargin(grocer_i)=null()
         elseif str7 == 'newname' then
            indcom=strindex(grocer_argi,',')
            grocer_names(1)($+1)=part(grocer_argi,strindex(grocer_argi,'(')+1:indcom-1)
            grocer_names($+1)=part(grocer_argi,indcom+1:strindex(grocer_argi,')')-1)
            varargin(grocer_i)=null()
         elseif grocer_argi == 'dropna' then
            grocer_dropna=%t
            varargin(grocer_i)=null()
         end
      end
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
   typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
[grocer_model,grocer_listout]=estim_univmod(grocer_model,grocer_indeq,olspec1,grocer_save,grocer_prt,grocer_names,grocer_ltest,test_spec0)
 
varargout=lstcat(list(grocer_model),grocer_listout)
 
endfunction
