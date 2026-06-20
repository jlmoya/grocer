    function model=addsym(model,varargin)
 
// PURPOSE: add a new variable in one of the possible lists
// (endoegnous, exogenous, residual)
// ------------------------------------------------------------
// INPUT:
// * model = a model typed list created by the function
//   create_model
// * varargin =
//  - a number of paired arguments with the following
//   sequence: 'type of variable', vector_of_variables_names
//   with 'type of variable' = 'endogenous', 'exogenous' or
//   'residuals'
//  - 'notransf' if the user does not want to
//   transform for estimation and simulation
// ------------------------------------------------------------
// OUTPUT:
// * model = the new model, with the new endogenous, exogenous
//  and residuals and coresponding fields adjusted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014-2015
// http://grocer.toolbox.free.fr/grocer.html
 
 
transf=%t
nargin=length(varargin)
for i=nargin:-1:1
   if varargin(nargin) == 'notransf' then
      transf=%f
      nargin=nargin-1
   end
end
 
if 2*floor(nargin/2) ~= nargin then
   error('number of variables types and lists do not match')
end
 
type_variable=[]
for i=1:nargin/2
   type_variable=[type_variable ; varargin(i*2-1)]
end
 
for i=1:nargin/2
   if size(varargin(i*2),'*') == 1 then
      aux='['''+strsubst(varargin(i*2),';',''';''')+''']'
      execstr('varargin(i*2)='+aux)
   end
end
 
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
    // there are new exogenous variables
   list_newexo=varargin(2*ind_exo)
   model('name exo')=unique([model_namexo ; list_newexo(:)])
end
 
if ~isempty(ind_endo) then
    // there are new exogenous variables
   list_newendo=varargin(2*ind_endo)
   model('name endo')=unique([model_namendo ; list_newendo(:)])
end
 
if ~isempty(ind_resid) then
    // there are new exogenous variables
   list_newresid=varargin(2*ind_resid)
   model('name resid')=unique([model_nameresid ; list_newresid(:)])
end
 
if ~isempty(ind_coeff) then
    // there are new exogenous variables
   list_newcoeff=varargin(2*ind_coeff)
   model('name coeff')=unique([model_namecoeff ; list_newcoeff(:)])
end
 
if ~isempty(ind_param) then
    // there are new exogenous variables
   list_newparam=varargin(2*ind_param)
   model('name param')=unique([model_nameparam ; list_newparam(:)])
end
 
if transf then
   coeffs=  model('coeffs')
   model=model_transf(model)
   model('coeffs')=coeffs
else
   model('transf')=%f
end
 
endfunction
