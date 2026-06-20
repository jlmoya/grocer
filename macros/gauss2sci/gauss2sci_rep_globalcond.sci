function [statement,ind_op,ind_prev]=gauss2sci_rep_globalcond(statement,ind_leftpar,ind_rightpar,ind_prev)
 
// PURPOSE: transform Gauss miscellaneous functions
// ------------------------------------------------------------
// INPUT:
// * statement = a (1 x K) vector, stemming from a gauss
//   statement sperated between string and non string
//   components
// * type_statement = a (1 x K) vector, indicating if the
//   corresponding statement component is a string or not
// * ind_length = a (1 x (K+1)) vector, starting with 0 and
//   then indicating the cumulated length of the statement
//   components
// ------------------------------------------------------------
// OUTPUT:
// * statk = the same statement but with Scilab
//   definitions for conditionals
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_leftpar=ind_op('leftpar')
ind_rightpar=ind_op('rightpar')
ind_cond=[ind_op('doubleq'),ind_op('diff'),ind_op('sup'),ind_op('inf')]
 
for i=1:size(ind_cond,2)
 
   ind_condi=ind_cond(:,i)
   ind_leftparb=ind_leftpar(:,ind_leftpar(1,:) < ind_condi(1))
   ind_rightparb=ind_leftpar(:,ind_leftpar(1,:) > ind_condi(1))
 
   if size(ind_leftparb,2) ~= size(ind_rightparb,2) then
     // this is the simple case: the condition is encapsulated in
     // parentheses ; just find the opening parenthesis to add the
     // Scilab operator 'and'
      [ind_fuspar,count_par]=fusion_par(ind_leftpar,ind_rightpar)
 
      count_parbef=count_par(:,ind_fuspar(1,:) < ind_condi(1))
      ind_paraft=count_par(:,ind_fuspar(1,:) > ind_condi(1))
 
      ind1=find(count_parbef(:) == 0)+1
      ind_leftpari=ind_fuspar(1,ind1)
      ind_stat=ind_fuspar(2,ind1)
 
      statk=statement(ind_stat)
      statement(ind_stat)=part(statk,1:ind_leftpari-1)+...
         ' and'+part(statk,ind_leftpari:length(statk))
      ind_length(ind_stat+1:$)=ind_length(ind_stat+1:$)+4
      ind_leftpar(1,ind_leftpar(1,:) > ind_leftpari)=ind_leftpar(1,ind_leftpar(1,:) > ind_leftpari)+4
      ind_rightpar(1,ind_rightpar(1,:) > ind_leftpari)=ind_rightpar(1,ind_rightpar(1,:) > ind_leftpari)+4
      ind_cond(1,ind_cond(1,:) > ind_leftpari)=ind_cond(1,ind_cond(1,:) > ind_leftpari)+4
      ind_prev(1,ind_prev(1,:) > ind_leftpari)=ind_prev(1,ind_prev(1,:) > ind_leftpari)+4
 
   else
      // this is more difficult: find the operators that has greater
      // precedence that the condition symbol immediately before and after
      // it that is not encapsulated in parentheses or the expression if
 
      ind_before=ind_prev(:,ind_prev(1,:) < ind_condi(1))
      found=isempty(ind_before)
      while ~found then
         ind_leftparbl=ind_leftpar(:,ind_leftpar(1,:) < ind_before(1,$))
         ind_rightparbl=ind_rightpar(:,ind_rightpar(1,:) < ind_before(1,$))
         if size(ind_leftparbl,2) == size(ind_rightparbl,2) then
            found=%t
         else
            ind_before(:,$)=[]
            if isempty(ind_before) then
               found=%t
            end
         end
      end
      if isempty(ind_before) then
         statement(1)='and('+statement(1)
         ind_length(2)=ind_length(2)+4
      else
         ind1=ind_before(:,$)
         statement(ind1(2))=part(statement(ind1(2)),1:ind1(3))+'and('+...
                         part(statement(ind1(2)),ind1(3)+1:length(statement(ind1(2))))
         ind_length(ind1(2)+1)=ind_length(ind1(2)+1)+4
      end
 
      ind_after=ind_prev(:,ind_prev(1,:) > ind_condi(1))
      found=isempty(ind_after)
      while ~found then
         ind_leftparbl=ind_leftpar(:,ind_leftpar(:,1) > ind_after(:,1))
         ind_rightparbl=ind_rightpar(:,ind_rightpar(:,1) > ind_after(:,$))
 
         if size(ind_leftparbl,2) == size(ind_rightparbl,2) then
            found=%t
         else
            ind_before(:,1)=[]
            if isempty(ind_after) then
               found=%t
            end
         end
      end
 
      if isempty(ind_after) then
         statement($)=part(statement($),1:length(statement($))-1)+');'
         ind_length($)=ind_length($)+1
      else
         ind1=ind_after(:,1)
         statement(ind1(2))=part(statement(ind1(2)),1:ind1(1)-1)+') '+...
                         part(statement(ind1(2),1:ind1(1):length(statement(ind1(2)))))
         ind_length(ind1(2)+1:$)=ind_length(ind1(2)+1:$)+2
         ind_leftpar(1,ind_leftpar(1,:) > ind_leftpari)=ind_leftpar(1,ind_leftpar(1,:) > ind_leftpari)+2
         ind_rightpar(1,ind_rightpar(1,:) > ind_leftpari)=ind_rightpar(1,ind_rightpar(1,:) > ind_leftpari)+2
         ind_cond(1,ind_cond(1,:) > ind_leftpari)=ind_cond(1,ind_cond(1,:) > ind_leftpari)+2
         ind_prev(1,ind_prev(1,:) > ind_leftpari)=ind_prev(1,ind_prev(1,:) > ind_leftpari)+2
      end
   end
end
 
endfunction
