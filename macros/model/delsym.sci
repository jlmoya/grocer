function model=delsym(model,varargin)
 
// PURPOSE: remove some variables from a model
// ------------------------------------------------------------
// INPUT:
// * model = a model typed list created by the function
//   create_model
// * varargin = a number of paired arguments with the following
//   sequence: 'type of variable', vector_of_variables_names
//   with 'type of variable' = 'endogenous', 'exogenous' or
//   'residuals' or 'notransf' if the user does not want to
//   transform for estimation and simulation
// ------------------------------------------------------------
// OUTPUT:
// * model = the new model, with the variables dropped
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014-2015
// http://grocer.toolbox.free.fr/grocer.html
 
transf=%t
nargin=length(varargin)
for i=nargin:-1:1
   if varargin(i) == 'notransf' then
      transf=%f
      nargin=nargin-1
   end
end
if 2*floor(nargin/2) ~= nargin then
   error('number of variables types and lists do not match')
end
 
type_variable=[]
for i=1:nargin/2
   type_variable=[type_variable ; stripblanks(varargin(i*2-1))]
end
 
// retrieve all fields from the model tlist that will be used
// in the function, and, in some cases, changed
// retrieve all fields from the model tlist that will be used
// in the function, and, in some cases, changed
model_namexo=model('name exo')
model_namendo=model('name endo')
model_nameresid=model('name resid')
model_namecoeff=model('name coeff')
model_nameparam=model('name param')
 
// find at what place (if any) the kewords 'endogenous', 'exogenous' and
// 'residuals' have been entered
ind_endo=find(type_variable == 'endogenous')
ind_exo=find(type_variable == 'exogenous')
ind_resid=find(type_variable == 'residuals')
ind_coeff=find(type_variable == 'coefficients')
ind_param=find(type_variable == 'parameters')
 
if ~isempty(ind_exo) then
    // there are exogenous variables to drop
   list_dropexo=varargin(2*ind_exo)
   for i=1:size(list_dropexo,'*')
      model_namexo(find(model_namexo == list_dropexo(i)))=[]
   end
   model('name exo')=model_namexo
end
 
if ~isempty(ind_endo) then
    // there are endogenous variables to drop
   list_dropendo=varargin(2*ind_endo)
   for i=1:size(list_dropendo,'*')
      model_namendo(find(model_namendo == list_dropendo(i)))=[]
   end
   model('name endo')=model_namendo
end
 
if ~isempty(ind_resid) then
    // there are residuals to drop
   list_dropresid=varargin(2*ind_resid)
   for i=1:size(list_dropresid,'*')
      model_nameresid(find(model_nameresid == list_dropresid(i)))=[]
   end
   model('name resid')=model_nameresid
end
 
if ~isempty(ind_coeff) then
    // there are coefficients to drop
   list_dropcoeff=varargin(2*ind_coeff)
   for i=1:size(list_dropcoeff,'*')
      model_namecoeff(find(model_namcoeff == list_dropcoeff(i)))=[]
   end
   model('name coeff')=model_namecoeff
end
 
if ~isempty(ind_param) then
    // there are parameters to drop
   list_dropcoeff=varargin(2*ind_coeff)
   for i=1:size(list_dropcoeff,'*')
      model_namecoeff(find(model_namcoeff == list_dropcoeff(i)))=[]
   end
   model('name coeff')=model_namecoeff
end
 
 
if transf then
   model=model_transf(model)
else
   model('transf')=%f
end
 
endfunction
