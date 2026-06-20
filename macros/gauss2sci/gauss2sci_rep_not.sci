function [statement,ind_op,ind_length]=gauss2sci_rep_not(statement,type_stat,ind_op,ind_length)
 
// PURPOSE: Transform Gauss 'not' keywords into its Scilab
// translation
// ------------------------------------------------------------
// INPUT:
// * statement = a (1 x K) vector, stemming from a gauss
//   statement sperated between string and non string
//   components
// * type_statement = a (1 x K) vector, indicating if the
//   corresponding statement component is a string or not
// * ind_leftpar = a (2 x N) matrix, the first line indicates
//   the indexes of '(' in a statememnt, the second one the
//   index of the component where the parenthesis has been
//   found
// * ind_rightpar = a (2 x N) matrix, the same as ind_leftpar
//   for ')'
// * ind_length = a (1 x (K+1)) vector, starting with 0 and
//   then indicating the cumulated length of the statement
//   components
// ------------------------------------------------------------
// OUTPUT:
// * statement = the same statement but with Scilab
//   definitions for matrices
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
ind_not=ind_op('not')
ind_leftpar=ind_op('leftpar')
ind_rightpar=ind_op('rightpar')
for i=1:size(ind_not,2)
   [ind_start,ind_end,newleftpar,newrightpar]=gauss2sci_arg_after(statement,type_stat,'not',ind_not(i),ind_leftpar,ind_rightpar,ind_prev)
   start_stat=ind_start(2)
   end_stat=ind_end(2)
   if ind_start(2) == ind_end(2) then
   // all the expression is on the same part of the statement
      statement(start_stat)=part(statk,1:ind_not(i)-1)+'~and'+newleftpar+...
                   part(statk,ind_start(1):ind_end(1))+newrightpar+...
                   part(statk,ind_end(1)+1:length(statk))
    else
      statement(i)=part(statk,1:ind_not(i)-1)+'~and'+newleftpar+...
                        part(statk,ind_start(1):length(statk))
      statl=statement(end_stat)
      statement(statl)=part(statl,1:ind_end(1))+newrightpar+...
                       part(statl,ind_end(1)+1:length(statl))
   end
 
   ind_length(i+1:$)=ind_length(i+1:$)+length(newleftpar)+1
   ind_length(end_stat+1:$)=ind_length(end_stat+1:$)+length(newrightpar)
 
   ind_leftpar(:,ind_leftpar(:,1)>ind_obj(j))=ind_leftpar(:,ind_leftpar(:,1)>ind_obj(j))+length(newleftpar)+4
   ind_leftpar(:,ind_leftpar(:,1)>ind_end(1))=ind_leftpar(:,ind_leftpar(:,1)>ind_end(1))+length(newrightpar)
   ind_rightpar(:,ind_rightpar(:,1)>ind_obj(j))=ind_rightpar(:,ind_rightpar(:,1)>ind_obj(j))+length(newleftpar)+4
   ind_rightpar(:,ind_rightpar(:,1)>ind_end(1))=ind_rightpar(:,ind_rightpar(:,1)>ind_end(1))+length(newrightpar)
   if ~isempty(newleftpar) then
      ind_leftpar=[ind_leftpar(:,ind_leftpar(:,1)<ind_obj(j)) ; ind_start(1)+1 ; ind_leftpar(:,ind_leftpar(:,1)>ind_obj(j))]
      ind_rightpar=[ind_rightpar(:,ind_rightpar(:,1)<ind_end(1)) ; ind_end(1)+2 ; ind_rightpar(:,ind_rightpar(:,1)>ind_end(j))]
   end
end
 
ind_op('leftpar')=ind_leftpar
ind_op('rightpar')=ind_rightpar
 
endfunction
 
