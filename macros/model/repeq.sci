function model=repeq(model,equations,newnames,neweq,transf)
 
// PURPOSE: replace equations with other ones in a model
// ------------------------------------------------------------
// INPUT:
// * model = a model tlist
// * equations = a string vector, collecting the names of the
//   equations to replace
// * newnames = a string vector, collecting the names of the
//   new equations
// * newnames = a string vector, collecting the text  of the
//   new equations
// * transf = an optional argument: if given then the model
//   is not transformed for estimation and simulation
// ------------------------------------------------------------
// OUTPUT:
// * model = a model tlist with the given equatiosn deleted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
transf=%f
[nargout,nargin]=argn(0)
if nargin == 4 then
    transf=%t
end
 
if typeof(equations) == 'string' then
   name_eq=model('name eq')
   ind_eq=[]
   for j=1:size(equations,'*')
      ind_model=find(name_eq == equations(j))
      if isempty(ind_model) then
         warning('equation '+equations(j)+' not found in model')
      else
         ind_eq=[ind_eq ; ind_model]
      end
   end
   equations=ind_eq
 
elseif typeof(equations) ~= 'constant' then
   error(typeof(equations)+'is not suitable for input # 2')
 
end
 
[equations,indeq]=gsort(equations)
model_eq=model('equations')
model_nameq=model('name eq')
model_eq(equations)=neweq(indeq)
model_nameq(equations)=newnames(indeq)
model('equations')=model_eq
model('name eq')=model_nameq
 
if transf then
   model=model_transf(model)
else
   model('transf')=%f
end
 
endfunction
