function ind_start=find_start(ind_leftpar,ind_rightpar,ind_all,preced_sep,ind_sep)
 
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
// ------------------------------------------------------------
// OUTPUT:
// * statements = a list of statements, dissected between
//   their string and non string components
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_all_bef=ind_all(:,ind_all($,:)<preced_sep & ind_all(1,:)<ind_sep)
par_left_bef=ind_leftpar(:,ind_leftpar(1,:) < ind_sep)
par_right_bef=ind_rightpar(:,ind_rightpar(1,:) < ind_sep)
 
found=%f
 
while ~found then
   if ind_all_bef(1,$)+0 > max([par_left_bef(1,$);par_right_bef(1,$)])+0 then
      // there is an operator before the examined separator
      // and it is after the last parenthesis before the separator:
      // the operator marks the start of the expression
      found=%t
      ind_start=ind_all_bef(1:2,$)+[ind_all_bef(3,$)-ind_all_bef(1,$);0]
 
   elseif par_left_bef(1,$)+0 > par_right_bef(1,$)+0 then
      // there is a left parenthesis after the last operator
      // and right parenthesis: it marks the start of the expression
      found=%t
      ind_start=par_left_bef(1:2,$)+[1;0]
 
   elseif isempty(par_left_bef(1,$)) then
      // there is no operator, no parenthesis before the separator:
      // the expression starts at the start of the statement
      found=%t
      ind_start=[1;1]
 
   else
      // there is a right parenthesis after the last operator
      // and left parenthesis: find the corresponding opening
      // left parenthesis and remove the corresponding part
      ind_fuspar=fusion_par(par_left_bef,par_right_bef)
      [junk,ind]=find(ind_fuspar(1,:) == par_right_bef(1,$))
      [junk,ind]=find(ind_fuspar(4,:) == ind_fuspar(4,ind)+1 & ind_fuspar(3,:) ==1)
      ind_deb=ind_fuspar(1,ind($))
      par_left_bef(:,par_left_bef(1,:)>=ind_deb)=[]
      par_right_bef(:,par_right_bef(1,:)>=ind_deb)=[]
      ind_all_bef(:,ind_all_bef(1,:)>=ind_deb)=[]
 
   end
end
 
endfunction
