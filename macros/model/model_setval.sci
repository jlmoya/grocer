function model=model_setval(model,names,vals)
 
// PURPOSE: enter the values of a coefficient or a parameter
// into a model tlist
// ------------------------------------------------------------
// INPUT:
// * model = a model typed list
// * names = a vector of coefficients or parameters names
// * vals = a real vector of the corresponding values
// ------------------------------------------------------------
// OUTPUT:
// * model = the original model tlist, filled with the values
//   of the given coefficients
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018-2019
// http://grocer.toolbox.free.fr/grocer.html
 
if typeof(model) ~= 'modelg' then
   error('arg # 1 should be a modelg tlist')
end
 
if typeof(names) ~= 'string' then
   error('arg # 2 should be a string vector')
end
 
if typeof(vals) ~= 'constant' then
   error('arg # 3 should be a string vector')
end
 
nnames=size(names,'*')
nvals=size(vals,'*')
 
if nnames ~= nvals then
   error('names and values should have the same size')
end
 
name_coeffs=model('name coeff')
name_params=model('name param')
coeffs=model('coeffs')
params=model('params')
for i=1:nnames
   name_i=names(i)
   ind_coeff_i=find(name_i == name_coeffs)
   if isempty(ind_coeff_i) then
      ind_param_i=find(name_i == name_params)
      if isempty(ind_param_i) then
         error(name_i+' not found in the mlist of coeffs or parameters of the model')
      end
      // warbing: because param is a tlist, the n-th name of parameter matches the
      // (n+1) element of the tlist
      params(ind_param_i+1)=vals(i)
   else
      coeffs(ind_coeff_i+1)=vals(i)
   end
end
 
model('coeffs')=coeffs
model('params')=params
 
 
endfunction
