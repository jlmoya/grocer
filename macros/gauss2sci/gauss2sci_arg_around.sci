function [ind_start1,ind_end1,ind_start2,ind_end2]=gauss2sci_arg_around(statement,type_stat,ind_length,ind_op,exp_name,ind_exp)
 
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
// * ind_exp = a (4 x 1) vector, gathering the index of the
//   start of function name and the corresponding statement
//   component
// * ind_prev = a (2 x 1) vector, gathering the index of the
//   start of operators having precedence over the function and
//   the corresponding statement component
// ------------------------------------------------------------
// OUTPUT:
// * ind_start1 =  a (2 x 1) vector, gathering the index of the
//   start of first input and the corresponding statement
//   component
// * ind_end1 =  a (2 x 1) vector, gathering the index of the
//   end of first input and the corresponding statement
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
 
ind_leftpar=ind_op('leftpar')
ind_rightpar=ind_op('rightpar')
 
ind_allop=ind_op('all')
ind_allop_be=ind_allop(:,ind_allop(1,:) < ind_exp(1))
ind_allop_be=ind_allop_be(:,ind_allop_be(4,:) <= ind_exp(4))
ind_leftparb=ind_leftpar(:,ind_leftpar(1,:) < ind_exp(1))
ind_rightparb=ind_rightpar(:,ind_rightpar(1,:) < ind_exp(1))
del_nparb=size(ind_leftparb,2)-size(ind_rightparb,2)
 
found=%f
n=size(ind_allop_be,2)
while ~found then
   if n == 0 then
	  found=%t
   else
      ind_leftparb2=ind_leftpar(:,ind_leftpar(1,:) < ind_allop_be(1,n))
      ind_rightparb2=ind_rightpar(:,ind_rightpar(1,:) < ind_allop_be(1,n))
      del_nparbetw=size(ind_leftparb2,2)-size(ind_rightparb2,2)
      if del_nparbetw >= del_nparb then
	     n=n-1
	  else
         found=%t
      end
   end
end
 
if n == 0 then
   ind_start1=[1;1]
   del_nparleft=del_nparb
else
   ind_start1=[ind_allop_be(1:2,n)]+[1 ; 0]
   del_nparleft=del_nparb-del_nparbetw
end
 
if ind_exp(1) == ind_length(ind_exp(2))+1 then
// the statement component starts with the expression
   ind_end1=ind_exp(1:2)-[1;1]
else
   ind_end1=[ind_exp(1)-1 ; ind_exp(2)]
end
 
if ind_exp(1)+length(exp_name) == ind_length(ind_exp(2)+1) then
// the statement component starts with the expression
   ind_start2=[ind_exp(1)+length(exp_name)+1;ind_exp(2)+1]
else
   ind_start2=[ind_exp(1)+length(exp_name); ind_exp(2)]
end
 
if del_nparleft > 0 then
	// the operator is encapsulated in parentheses:
	// find the closing parenthesis
   ind_fuspar=fusion_par(ind_leftpar,ind_rightpar)
   ind_fusparplus=ind_fuspar(:,ind_fuspar(1,:) >= ind_start1(1))
   ind_parorder=ind_fusparplus(4,1)
   ind_eqorder=ind_fuspar(:,ind_fuspar(4,:) == ind_parorder-1)
   ind_end2=ind_eqorder(1:2,1)
else
   ind_allop_af=ind_opall(ind_allop(1,:) > ind_exp(1))
   ind_allop_af=ind_allop_af(ind_allop(4,:) <= ind_exp(4))
   ind_leftparb=ind_leftpar(:,ind_leftpar(1,:) > ind_exp(1))
   ind_rightparb=ind_rightpar(:,ind_rightpar(1,:) > ind_exp(1))
   i=0
   n=size(ind_allop_af,2)
   found=(i == n)
   while ~found then
      i=i+1
      n_difpar=size(ind_rightparb(ind_rightparb(1,:) < ind_allop(1,i)),2)-...
               size(ind_leftparb(ind_leftparb(1,:) < ind_allop(1,i)),2)
      if n_difpar == 0 then
	     found=%t
	     ind_end2=ind_allop_af(1:2,i)
      end
   end
end
 
endfunction
