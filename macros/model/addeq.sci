function model=addeq(model,position,nameq,txteq,notransf)
 
// PURPOSE: add equations to a model
// ------------------------------------------------------------
// INPUT:
// * model = a model tlist
// * position = either a scalar, indicating where to add the
//   equation or 'bottom' to add it at the bottom of the model
//   or 'top' to add it at the top of the model
// * nameq = a string vector, the names of the new equations
// * txteq = a string vector, the texts of the new equations
// * notransf = an optional argument: if given then the model
//   is not transformed for estimation and simulation
// ------------------------------------------------------------
// OUTPUT:
// * model = a model tlist with the given equatiosn deleted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
transf=%t
[nargout,nargin]=argn(0)
if nargin == 5 then
    transf=%f
end
 
model_eq=model('equations')
model_nameq=model('name eq')
 
if position == 'bottom' then
   model('equations')=[model_eq ; txteq]
   model('name eq')=[model_nameq ; nameq]
 
elseif position == 'top' then
   model('equations')=[txteq ; model_eq  ]
   model('name eq')=[nameq ; model_nameq ]
 
else
   model('equations')=[model_eq(1:position) ; txteq ; model_eq(position+1:$)]
   model('name eq')=[nameq(1:position) ; model_nameq ; nameq(position+1:$)]
 
end
 
if transf then
   model=model_transf(model)
else
   model('transf')=%f
end
 
endfunction
