function [ind_start,ind_end,newleftpar,newrightpar]=gauss2sci_arg_after(statement,type_stat,exp_name,ind_exp,ind_leftpar,ind_rightpar,ind_prev)
 
// PURPOSE: find the start and end of the input for a function
// when start can be materialized by a '(' or not
// ------------------------------------------------------------
// INPUT:
// * statement = a (1 x K) vector, stemming from a gauss
//   statement sperated between string and non string
//   components
// * type_state = a (1 x K) vector, indicating if the
//   corresponding statement component is a string or not
// * exp_name = name of the function
// * ind_exp = a (2 x 1) vector, gathering the index of the
//   start of function name and the corresponding statement
//   component
// * ind_leftpar = a (2 x N) matrix, the first line indicates
//   the indexes of '(' in a statememnt, the second one the
//   index of the component where the parenthesis has been
//   found
// * ind_rightpar = a (2 x N) matrix, the same as ind_leftpar
//   for ')'
// * ind_prev = a (2 x 1) vector, gathering the index of the
//   start of operators having precedence over the function and
//   the corresponding statement component
// ------------------------------------------------------------
// OUTPUT:
// * ind_start =  a (2 x 1) vector, gathering the index of the
//   start of function input and the corresponding statement
//   component
// * ind_end =  a (2 x 1) vector, gathering the index of the
//   end of function input and the corresponding statement
//   component
// * newleftpar =
//   - [] if the function start materialized by a '('
//   - '(' if this is not the case
// * newrightpar =
//   - [] if the function start materialized by a '('
//   - ')' if this is not the case
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_exp1=ind_exp(1)
ind_exp2=ind_exp(2)
statk=statement(ind_exp2)
lengthk=ind_length(ind_exp2+1)-ind_length(ind_exp2)
ind_start=ind_exp1-ind_length(ind_exp2)+length(exp_name)
ind_start0=ind_start
found=%F
while ~found then
   if ind_start0 == lengthk then
      found=%t
   elseif part(statk,ind_start0) == ' ' then
      ind_start0=ind_start0+1
   else
      found=%t
   end
end
 
if part(statk,ind_start0) == '(' then
   // this is the simple case: the condition is encapsulated in
   // parentheses ; just find the opening parenthesis
   ind_leftparb=ind_leftpar(:,ind_leftpar(:,1) >= ind_start+ind_length(ind_exp2))
   ind_rightparb=ind_rightpar(:,ind_rightpar(:,1) >= ind_start+ind_length(ind_exp2))
   [ind_fuspar,count_par]=fusion_par(ind_leftparb,ind_rightparb)
   ind_zero=find(count_par==0)
   ind_end=ind_fuspar(1:2,ind_zero)
   newleftpar=[]
   newrightpar=[]
 
else
   // this is more difficult: find the operators that has greater
   // precedence that the condition symbol immediately before and after
   // it that is not encapsulated in parentheses or the expression if
 
   ind_after=ind_prev(:,ind_prev(1,:) > ind_exp1)
   found=isempty(ind_after)
   while ~found then
      ind_leftparbl=ind_leftpar(:,ind_leftpar(:,1) > ind_after(:,1))
      ind_rightparbl=ind_rightpar(:,ind_rightpar(:,1) > ind_after(:,$))
 
      if size(ind_leftparbl,2) == size(ind_rightparbl,2) then
         found=%t
      else
         ind_after(:,1)=[]
         if isempty(ind_after) then
            found=%t
         end
      end
   end
   if isempty(ind_after) then
      ind_end=[ind_length($)-1 ; size(statement,2)]
   else
      ind_end=ind_after(1:2,1)-[1 ; 0]
   end
   newleftpar='('
   newrightpar=')'
end
 
ind_start=[ind_start+ind_length(ind_exp2) ; ind_exp2]
 
endfunction
