function ind_end=find_end(ind_leftpar,ind_rightpar,ind_all,preced_sep,ind_sep,L)
 
// PURPOSE: find the start index of an expression of the kind:
// lhs separator rhs
// ------------------------------------------------------------
// INPUT:
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
 
ind_all_aft=ind_all(:,ind_all(4,:)<preced_sep & ind_all(1,:)>ind_sep)
par_left_aft=ind_leftpar(:,ind_leftpar(1,:) > ind_sep)
par_right_aft=ind_rightpar(:,ind_rightpar(1,:) > ind_sep)
 
found=%f
while ~found then
   if max(L+1-[ind_all_aft(1,1);L+1]) > max(L+1-[par_left_aft(1,1);par_right_aft(1,1);L+1]) then
      // there is an operator after the examined separator
      // and it is before the first parenthesis after the separator:
      // the operator marks the start of the expression
      found=%t
      ind_end=ind_all_aft(1:2,1)-[1;0]
 
   elseif max(L+1-[par_right_aft(1,1);L+1]) > max(L+1-[par_left_aft(1,1);L+1]) then
      // there is a right parenthesis before the last operator
      // and before any left parenthesis: it marks the end of the expression
      found=%t
      ind_end=par_right_aft(1:2,1)-[1;0]
 
   elseif isempty(par_right_aft) then
      // there is no operator, no parenthesis before the separator:
      // the expression ends at the end of the statement
      found=%t
      ind_end=[L;size(statement,2)]
 
   else
      // there is a left parenthesis before the last operator
      // and left parenthesis: find the corresponding closing
      // right parenthesis and remove the corresponding part
      ind_fuspar=fusion_par(par_left_aft,par_right_aft)
      [junk,ind]=find(ind_fuspar(1,:) == par_left_aft(1,1))
      [junk,ind]=find(ind_fuspar(4,:) == ind-1 & ind_fuspar(3,:) == -1)
      ind_end2=ind_fuspar(1,ind(1))
      par_left_aft(:,par_left_aft(1,:)<=ind_end2)=[]
      par_right_aft(:,par_right_aft(1,:)<=ind_end2)=[]
      ind_all_aft(:,ind_all_aft(1,:)<=ind_end2)=[]
 
   end
end
 
 
endfunction
