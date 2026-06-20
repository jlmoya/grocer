function model=changesym(model,varargin)
 
// PURPOSE: changes the status of some variables in a model
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
// * model = the new model, with the new endogenous, exogenous
//  and residuals and coresponding fields adjusted
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014-2015
// http://grocer.toolbox.free.fr/grocer.html
 
transf=%t
nargin=length(varargin)
for i=nargin:-1:1
   if varargin(i) == 'notransf' then
      transf=%f
      nargin=nargin-1
      varargin(i)=null()
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
model_namexo=model('name exo')
model_namendo=model('name endo')
model_nameresid=model('name resid')
 
// find at what place (if any) the kewords 'endogenous', 'exogenous' and
// 'residuals' have been entered
ind_endo=find(type_variable == 'endogenous')
ind_exo=find(type_variable == 'exogenous')
ind_resid=find(type_variable == 'residuals')
 
n_removed_endo=0
n_removed_exo=0
n_removed_resid=0
ind_removed_endo=[]
ind_removed_exo=[]
ind_removed_resid=[]
removed_endo=[]
removed_exo=[]
removed_resid=[]
list_newexo=[]
list_newendo=[]
list_newresid=[]
 
if ~isempty(ind_exo) then
    // there are new exogenous variables
   list_newexo=varargin(2*ind_exo)
   list_newexo=list_newexo(:)
   list_newexo=strsubst(list_newexo,',',';')
   if size(list_newexo,1) == 1  then
      list_newexo=evstr('['''+strsubst(list_newexo,';',''';''')+''']')
   end
   // find in the list of input endogenous variables and residuals the
   // indexes of variables switched to exogenous
   for i=size(list_newexo,1):-1:1
      if ~isempty(strindex(list_newexo(i),'>')) | ~isempty(strindex(list_newexo(i),'*')) then
         [selected_resid,index_resid]=select_mask(model_nameresid,list_newexo(i))
         removed_resid=[removed_resid ; selected_resid]
         ind_removed_resid=[ind_removed_resid ; index_resid]
         n_removed_resid=n_removed_resid+size(index_resid,1)
 
         [selected_endo,index_endo]=select_mask(model_namendo,list_newendo(i))
         removed_endo=[removed_endo ; selected_endo]
         ind_removed_endo=[ind_removed_endo ; index_endo]
         n_removed_endo=n_removed_endo+size(index_endo,1)
 
         list_newexo=[list_newexo(1:i-1) ; selected_resid ; selected_endo ; list_newexo(i+1:$)]
 
      else
 
         ind_removed_endoi=find(list_newexo(i) == model_namendo)
         if ~isempty(ind_removed_endoi) then
            removed_endo=[removed_endo ; model_namendo(ind_removed_endoi)]
            ind_removed_endo=[ind_removed_endo ; ind_removed_endoi]
            n_removed_endo=n_removed_endo+1
         end
 
         ind_removed_residi=find(list_newexo(i) == model_nameresid)
         if ~isempty(ind_removed_residi) then
            removed_resid=[removed_resid ; model_namendo(ind_removed_resid)]
            ind_removed_resid=[ind_removed_resid ; ind_removed_residi]
            n_removed_resid=n_removed_resid+1
         end
      end
   end
   list_newexo=unique(list_newexo)
end
 
if ~isempty(ind_resid) then
   // there are new residuals
   list_newresid=varargin(2*ind_resid)
   list_newresid=list_newresid(:)
   list_newresid=strsubst(list_newresid,',',';')
   if size(list_newresid,1) == 1  then
      list_newresid=stripblanks(evstr('['''+strsubst(list_newresid,';',''';''')+''']'))
   end
   for i=size(list_newresid,1):-1:1
   // find in the list of input endogenous variables and residuals the
   // indexes of variables switched to residuals
      if ~isempty(strindex(list_newresid(i),'>')) | ~isempty(strindex(list_newresid(i),'*')) then
         [selected_exo,index_exo]=select_mask(model_namexo,list_newresid(i))
         removed_exo=[removed_exo ; selected_exo]
         ind_removed_exo=[ind_removed_exo ; index_exo]
         n_removed_exo=n_removed_exo+size(index_exo,1)
 
         [selected_endo,index_endo]=select_mask(model_namendo,list_newresid(i))
         removed_endo=[removed_endo ; selected_endo]
         ind_removed_endo=[ind_removed_endo ; index_endo]
         n_removed_endo=n_removed_endo+size(index_endo,1)
         list_newresid=[list_newresid(1:i-1) ; selected_exo ; selected_endo ; list_newresid(i+1:$)]
 
      else
         if size(list_newresid,1) == 1 then
            list_newresid=strsubst(list_newresid,',',';')
            list_newresid=stripblanks(evstr('['''+strsubst(list_newresid,';',''';''')+''']'))
         end
 
         ind_removed_endoi=find(list_newresid(i) == model_namendo)
         if ~isempty(ind_removed_endoi) then
            removed_endo=[removed_endo ; model_namendo(ind_removed_endoi)]
            ind_removed_endo=[ind_removed_endo ; ind_removed_endoi]
            n_removed_endo=n_removed_endo+1
         end
 
         ind_removed_exoi=find(list_newresid(i) == model_namexo)
         if ~isempty(ind_removed_exoi) then
            removed_exo=[removed_exo ; model_namexo(ind_removed_exo)]
            ind_removed_exo=[ind_removed_exo ; ind_removed_exo]
            n_removed_exo=n_removed_exo+1
         end
      end
   end
   list_newresid=unique(list_newresid)
end
 
// remove the endogenous variables switched to exogenous or residuals
// from the list of parameters to be optimized
// this is done first in the transformed equations, then in the Jacobian
// and the list of Jacobian non zero indexes
if isempty(ind_endo) then
   warning('you do not switch variables to endogenous type')
   n_newendo=0
 
else
   list_newendo=varargin(2*ind_endo)
   list_newendo=list_newendo(:)
   n_newendo=size(list_newendo,1)
   if size(list_newendo,1) == 1 then
      list_newendo=strsubst(list_newendo,',',';')
      list_newendo=stripblanks(evstr('['''+strsubst(list_newendo,';',''';''')+''']'))
   end
 
   for i=size(list_newendo,1):-1:1
      if ~isempty(strindex(list_newendo(i),'>')) | ~isempty(strindex(list_newendo(i),'*')) then
         [selected_resid,index_resid]=select_mask(model_nameresid,list_newendo(i))
         removed_resid=[removed_resid ; selected_resid]
         ind_removed_resid=[ind_removed_resid ; index_resid]
         n_removed_resid=n_removed_resid+size(index_resid,1)
 
         [selected_exo,index_exo]=select_mask(model_namexo,list_newendo(i))
         removed_exo=[removed_exo ; selected_exo]
         ind_removed_exo=[ind_removed_exo ; index_exo]
         n_removed_exo=n_removed_exo+size(index_exo,1)
 
         list_newendo=[list_newendo(1:i-1) ; selected_exo ; selected_resid ; list_newendo(i+1:$)]
      else
      // find in the list of input endogenous variables and residuals the
      // indexes of variables switched to residuals
 
         ind_removed_residi=find(list_newendo(i) == model_nameresid)
         if ~isempty(ind_removed_residi) then
            removed_resid=[removed_resid ; model_nameresid(ind_removed_residi)]
            ind_removed_resid=[ind_removed_resid ; ind_removed_residi]
            n_removed_resid=n_removed_resid+1
         end
 
         ind_removed_exoi=find(list_newendo(i) == model_namexo)
         if ~isempty(ind_removed_exoi) then
            removed_exo=[removed_exo ; model_namexo(ind_removed_exoi)]
            ind_removed_exo=[ind_removed_exo ; ind_removed_exoi]
            n_removed_exo=n_removed_exo+1
         end
      end
   end
end
 
n_newendo=size(list_newendo,1)
if n_newendo ~= n_removed_endo then
   warning('# of removed ('+string(n_removed_endo)+') and added ('+string(n_newendo)+') endogenous variables are different')
end
if n_newendo < n_removed_endo
   model_namendo(ind_removed_endo(1:n_newendo))=list_newendo
   model_namendo(ind_removed_endo(n_newendo+1:n_removed_endo))=[]
else
   model_namendo(ind_removed_endo)=list_newendo(1:n_removed_endo)
   model_namendo=[model_namendo ; list_newendo(n_removed_endo+1:$)]
end
 
model_namexo(ind_removed_exo)=[]
model_namexo=[model_namexo ; list_newexo]
model_nameresid(ind_removed_resid)=[]
model_nameresid=[model_nameresid ; list_newresid]
model('name resid')=model_nameresid
model('name endo')=model_namendo
model('name exo')=model_namexo
 
if transf then
   model=model_transf(model)
else
   model('transf')=%f
end
 
endfunction
