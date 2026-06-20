function [op,ind_nonempty]=remove_op(op,ind_nonempty,ind,type_op)
 
// PURPOSE: remove an operator from the list of operators
// ------------------------------------------------------------
// INPUT:
// * op = a tlist with each field corresponding to an operator
// * ind_nonempty = a vector of integers, indicating which
//   fields in op are non empty
// * ind = the position of the operator to remove
// * type_op = the
// ------------------------------------------------------------
// OUTPUT:
// * op = a the transfomed tlist of the operator positions
// * ind_nonempty = the fields in op that are non empty
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009-2010
// http://grocer.toolbox.free.fr/grocer.html
 
op_all=op('all')
op_all(:,op_all(1,:)==ind)=[]
op('all')=op_all
op_type_op=op(type_op)
op_type_op(:,op_type_op(1,:)==ind)=[]
op(type_op)=op_type_op
if isempty(op_type_op) then
   ind_type_op=find(op(1) == type_op)
   ind_nonempty(ind_nonempty == ind_type_op)=[]
end
 
 
endfunction
