function [ind_start,ind_end]=find_limits(stat,ind_leftpar,ind_rightpar,ind_fuspar,ind_all,preced,ind_i,ind_length)
 
// PURPOSE: find the start and end index of an expression of
// the kind: lhs separator rhs
// ------------------------------------------------------------
// INPUT:
// * stat = a gauss statement
// * op = a tlist which contains at least the following fields:
//   - 'leftpar' = a (k x N) vector, with the index of left
//   parentheses on the first row
//   - 'rightpar' = a (k x N) vector, with the index of right
//   parentheses on the first row
//   - 'all' = a (m x N) vector, with the index of the operator
//   on the first row and its precedence on the last row
//   each column of the 'all' field has the following rows:
// * preced_sep = a scalar, the precedence of the operator
// * ind_sep = a scalar, the index of the operator in the
//   examined statement
// * L = the end of the text
// ------------------------------------------------------------
// OUTPUT:
// * statements = a list of statements, dissected between
//   their string and non string components
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
 
 
ind_start=find_start(ind_leftpar,ind_rightpar,ind_all,preced,ind_i(1))
leftpar_after=ind_fuspar(:,ind_fuspar(1,:)>=ind_start(1) & ind_fuspar(3,:) ==1)
leftpar_first_after=leftpar_after(:,1)
equivalent_rightpar=ind_fuspar(:,ind_fuspar(1,:)>=ind_start(1) & ind_fuspar(4,:) == leftpar_first_after(4)-1)
ind_end=equivalent_rightpar(:,1)
 
if ~isempty(stripblanks(part(stat,ind_i(3):leftpar_first_after(1)-1))) | ind_end(1) < ind_i(1) then
// case when the left side of the operation does not start with a '(' or
// starts with a '(' but this '(' is closed before the operator
   ind_end=find_end(ind_leftpar,ind_rightpar,ind_all,preced,ind_i(1),ind_length($)-1)   // now enclose the found matrix between brackets
end
 
 
endfunction
