function find_in_equations(model,object,output)
 
// PURPOSE: in a model, finds the equations where an object
// (endogenous, exogenous, residual, coefficient) is used
// ------------------------------------------------------------
// INPUT:
// * model = a model typed list created by the function
//   create_model
// * object = the name of the object to search
// * output = the place to save the results (optional; default:
//   the working space)
// ------------------------------------------------------------
// OUTPUT:
// nothing: the result is displayed on the screen
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014-2015
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin]=argn(0)
if nargin >3 then
    output=%io(2)
end
 
equations= model('equations')
name_equations= model('name eq')
endogenous= model('name endo')
ind_endogenous=find(endogenous == object)
if ~isempty(ind_endogenous) then
   listeqperendo=find(full(model('eq endos')(ind_endogenous,:)) == 1)
   write(%io(2),'endogenous '+object+' found in equation(s):','(a)')
   for i=1:size(listeqperendo,'*')
      ind_i=listeqperendo(i)
      write(%io(2),name_equations(ind_i)+': '+equations(ind_i),'(a)')
      write(%io(2),' ','(a)')
   end
 
else
   exogenous= model('name exo')
   ind_exogenous=find(exogenous == object)
   if ~isempty(ind_exogenous) then
      listeqperexo=find(full(model('eq exos')(ind_exogenous,:)) == 1)
      write(%io(2),'exogenous '+object+' found in equation(s):','(a)')
      for i=1:size(listeqperexo,'*')
         ind_i=listeqperexo(i)
         write(%io(2),name_equations(ind_i)+': '+equations(ind_i),'(a)')
         write(%io(2),' ','(a)')
      end
   else
      residuals= model('name resid')
      ind_resid=find(residuals == object)
      if ~isempty(ind_resid) then
         listeqperresid=find(full(model('eq resids')(ind_resid,:)) == 1)
         write(%io(2),'residual '+object+' found in equation(s):','(a)')
         for i=1:size(listeqperresid,'*')
            ind_i=listeqperresid(i)
            write(%io(2),name_equations(ind_i)+': '+equations(ind_i),'(a)')
            write(%io(2),' ','(a)')
         end
      else
         coeffs= model('name coeff')
         ind_coeffs=find(coeffs == object)
         if ~isempty(ind_coeffs) then
            listeqpercoeff=find(full(model('eq coeffs')(ind_coeffs,:)) == 1)
            write(%io(2),'coefficient '+object+' found in equation(s):','(a)')
            write(%io(2),' ','(a)')
            for i=1:size(listeqpercoeff,'*')
               ind_i=listeqpercoeff(i)
               write(%io(2),name_equations(ind_i)+': '+equations(ind_i),'(a)')
            end
         else
            write(%io(2),'variable '+object+' not found in the model equations','(a)')
         end
      end
   end
end
 
endfunction
