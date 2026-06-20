function [listendo_eq,indendo_eq,ind_endo_eq,ind_exo_eq,ind_resid_eq,coeffs_eq,listeqperendo,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namexo,typevari,lags_exos,listeqperendo_wolags]=check_variables_ineq(variable,name_eq,indeq,listendo_eq,indendo_eq,coeffs_eq,listeqperendo,listeqperendo_wolags,listeqperexo,listeqperresid,listeqpercoeff,listeqperparam,namendo,namexo,nameresid,namecoeff,nameparam,lags_exos)
 
// PURPOSE: check if the variable has already been declared as
// endogenous, exogenous, residual or coefficient, if not
// consider it as exogenous; update the list of equations where
// the variable can be found
// ------------------------------------------------------------
// INPUT:
// * variable = a string, the text of an equation
// * name_eq = a string, the name of this equation
// * indeq = a scalar, the index of this equation
// * listendo_eq = a string vector, the names of the endogenous
//   variables found in the equation
// * indendo_eq = a real vector, the indexes of the endogenous
//   variables found in the equation
// * coeffs_eq = a string vector, the names of the coeffcients
//   found in the equation
// * listeqperendo = a list of nendo elements (nendo = # of
//   endogenous variables in the model), each element
//   collecting the equation for which the endogenous enters
// * listeqperendo_wolags = a list of nendo elements (nendo = #
//   of endogenous variables in the model), each element
//   collecting the equation for which the endogenous enters
//   contemporaneously
// * listeqperexo = a list of nexo elements (nexo = # of
//   exogenous variables in the model), each element
//   collecting the equation for which the exogenous enters
// * listeqperresid = a list of nres elements (nres = # of
//   residual variables in the model), each element
//   collecting the equation for which the residual enters
// * listeqpercoeff = a list of ncoeff elements (ncoeff = #
//   of coefficients in the model), each element
//   collecting the equation for which the coefficient enters
// * namendo = a string vector, the names of the endogenous
//   variables in the model
// * namexo = a string vector, the names of the exogenous
//   variables in the model
// * nameresid = a string vector, the names of the residuals
//   in the model
// * namecoeff = a string vector, the names of the coefficients
//   in the model
// * namecoeff = a string vector, the names of the parameters
//   in the model
// * lag0 = a scalar, the index of the lags already defined in
//   the equation (in practice: 0 for the lhs, and the number of
//   lags defined in the lhs for the rhs)
// ------------------------------------------------------------
// OUTPUT:
// * listendo_eq = a string vector, the names of the endogenous
//   variables found in the equation, updated
// * indendo_eq = a real vector, the indexes of the endogenous
//   variables found in the equation, updated
// * listexo_eq = a string vector, the names of the exogenous
//   variables found in the equation, updated
// * listresid_eq = a string vector, the names of the residuals
//   found in the equation, updated
// * coeffs_eq = a string vector, the names of the coeffcients
//   found in the equation, updated
// * listeqperendo = a list of nendo elements (nendo = # of
//   endogenous variables in the model), each element
//   collecting the equation for which the endogenous enters,
//   updated with the variables found in the equation
// * listeqperendo_wol = a list of nendo elements (nendo = #
//   of endogenous variables in the model), each element
//   collecting the equation for which the endogenous enters
//   contemporaneously, updated with the variables found in
//   the equation
// * listeqperexo = a list of nexo elements (nexo = # of
//   exogenous variables in the model), each element
//   collecting the equation for which the exogenous enters,
//   updated with the variables found in the equation
// * listeqperresid = a list of nres elements (nres = # of
//   residual variables in the model), each element
//   collecting the equation for which the residual enters,
//   updated with the variables found in the equation
// * listeqpercoeff = a list of ncoeff elements (ncoeff = #
//   of coefficients in the model), each element
//   collecting the equation for which the coefficient enters,
//   updated with the variables found in the equation
// * namexo = a string vector, the names of the exogenous
//   variables in the model, updated with the variables that
//   were not defined explictely and are tehrefore considered
//   as exogenous
// * typevari = a string, the type of the variable
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
 
coeffs_eq=[]
ind_endo_eq=find(namendo == variable)
ind_coeff_eq=[]
ind_exo_eq=[]
ind_resid_eq=[]
 
if isnum(variable) then
   typevari='num'
 
else
   if ~isempty(ind_endo_eq) then
      typevari='endo'
      indendo_eq=[indendo_eq ; ind_endo_eq]
      listendo_eq=[listendo_eq ; variable] // endo # j is in the variable
      listeqperendo(ind_endo_eq,indeq)=1
      listeqperendo_wolags(ind_endo_eq,indeq)=1
 
   else
      ind_resid_eq=find(nameresid == variable)
      if ~isempty(ind_resid_eq) then
         typevari= 'resid'
         listeqperresid(ind_resid_eq,indeq)=1
 
      else
         ind_coeff_eq=find(namecoeff == variable)
         if ~isempty(ind_coeff_eq) then
            typevari= 'coeff'
            coeffs_eq=[coeffs_eq ; variable]
            listeqpercoeff(ind_coeff_eq,indeq)=1
 
         else
            ind_param_eq=find(nameparam == variable)
            if ~isempty(ind_param_eq) then
               typevari= 'param'
               listeqperparam(ind_param_eq,indeq)=1
 
            else
               typevari='exo'
               ind_exo_eq=find(namexo == variable)
               if isempty(ind_exo_eq) then
                  warning('in equation '+ name_eq+', variable '+variable+' was not found in the list of variables and set to exogenous')
                  namexo=[namexo ; variable]
                  ind_exo_eq=size(namexo,1)
                  listeqperexo=[listeqperexo ; spzeros(1,grocer_neq)]
                  listeqperexo($,indeq)=1
                  lags_exos($+1)=[]
 
               else
                  listeqperexo(ind_exo_eq,indeq)=1
               end
            end
         end
      end
   end
 
end
 
endfunction
