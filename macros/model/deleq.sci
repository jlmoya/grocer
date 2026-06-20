function model=deleq(model,equations,notransf)
 
// PURPOSE: delete equations in a model
// ------------------------------------------------------------
// INPUT:
// * model = a model tlist
// * equations = either a string vector, collecting the names
//   of the equations to delete
// * notransf = an optional argument: if given then the model
//   is not transformed for estimation and simulation
// ------------------------------------------------------------
// OUTPUT:
// * model = a model tlist with the given equatiosn deleted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
transf=%f
[nargout,nargin]=argn(0)
if nargin == 2 then
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
 
equations=gsort(equations)
model_eq=model('equations')
model_nameq=model('name eq')
model_eq(equations)=[]
model_nameq(equations)=[]
model('equations')=model_eq
model('name eq')=model_nameq
 
if transf then
   model=model_transf(model)
else
   model('transf')=%f
end
 
endfunction
