function [statement,op,ind_length]=gauss2sci_rep_operations(statement,op,ind_length)
 
// PURPOSE: in a gauss translation, transform simple operations
// such as transposition or exponentioation
// ------------------------------------------------------------
// INPUT:
// * statement_elem = a gauss statement
// * op = a tlist with each field corresponding to an operator
//   op(i) = a (4 x p) matrix:
//   - first line: the positions of the operator
//   - second line: the statement number where the operator
//     appears
//   - third line: the position of the operator end
//   - fourth line: the precedence of the operator, as
//     indicated in the table of gauss manual (chapter 11-23
//     for gauss 10 version)
// ------------------------------------------------------------
// OUTPUT:
// * statement_elem = the transformed gauss statement
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
op_transpose=op('transp')
op_all=op('all')
 
for i=size(op_transpose,2):-1:1
   ind_i=op_transpose(:,i)
   ind_all=find(op_all(1,:)==ind_i(1))
   ind_stat=ind_i(2)
   stat=statement(ind_stat)
   end_stat_i=part(stat,ind_i(1)-ind_length(ind_i(2))+1:ind_length(ind_i(2)+1))
   length_i=ind_length(ind_i(2))
 
   if ind_all == size(op_all,2) then
      if ind_i(2) == size(statement,2) & stripblanks(end_stat_i) ~= ';' then
         // the transpose operator is the last one: it
        // is therefore before a variable name
         statement(ind_stat)=part(stat,1:ind_i(1)-length_i)+'*'+end_stat_i
         ind_length(ind_i(2)+1)=ind_length(ind_i(2)+1)+1
         ind_i(1)=ind_i(1)+1
         op=shift_op(op,ind_nonempty,ind_i(1),1)
         [op,ind_nonempty]=add_op(op,ind_nonempty,ind_i,'star')
      end
 
   else
      next_op=op_all(:,ind_all+1)
      if next_op(2) == ind_stat then
         if stripblanks(part(stat,[ind_i(1):next_op(1)-1]-length_i)) ~= '''' then
            // the transpose operator is not followed by another operator: it
            // is therefore before a variable name
            statement(ind_stat)=part(stat,1:ind_i(1)-length_i)+'*'+end_stat_i
            ind_length(ind_i(2)+1:$)=ind_length(ind_i(2)+1:$)+1
            ind_i(1)=ind_i(1)+1
            op=shift_op(op,ind_nonempty,ind_i(1),1)
           [op,ind_nonempty]=add_op(op,ind_nonempty,ind_i,'star')
 
         elseif part(stat,next_op(1)-length_i) == '('  then
         // the transpose operator is followed by a '(': add '*' in between
            statement(ind_stat)=part(stat,1:ind_i(1)-length_i)+'*'+end_stat_i
            ind_length(ind_i(2)+1)=ind_length(ind_i(2)+1)+1
            ind_i(1)=ind_i(1)+1
            op=shift_op(op,ind_nonempty,ind_i(1),1)
            [op,ind_nonempty]=add_op(op,ind_nonempty,ind_i,'star')
 
         end
      end
   end
end
 
ind_hat=op('hat')
ind_all=op('all')
 
for i=size(ind_hat,2):-1:1
   ind_hati_2=ind_hat(2,i)
   ind_hati_1=ind_hat(1,i)
   stat_hat=statement(ind_hati_2)
   op_afterhat=[ind_all(1:2,ind_all(1,:)>ind_hati_1) [ind_length($) ; size(statement,2)] ]
   stat_end=strsubst(part(stat_hat,[ind_hati_1:min(op_afterhat(1),ind_length(ind_hati_2+1))    ]-ind_length(ind_hati_2)),' ','')
 
   if stat_end == '^-' then
      ind_minus_1=op_afterhat(1,1)
      ind_minus_2=op_afterhat(2,1)
      statement(ind_minus_2)=part(stat_hat,1:ind_minus_1-1-ind_length(ind_minus_2))+'('+...
                  part(stat_hat,ind_minus_1:ind_length(ind_minus_2+1))
      op=shift_op(op,ind_nonempty,ind_minus_1+1,1)
      op_afterminus=op_afterhat(:,2:$)
 
      ind_length(ind_minus_2+1)=ind_length(ind_minus_2+1)+1
      ind_stat=op_afterminus(2,1)
      statement(ind_stat)=part(statement(ind_stat),1:op_afterminus(1,1)-ind_length(ind_stat))+...
                          ')'+part(statement(ind_stat),op_afterminus(1,1)+1-ind_length(ind_stat):ind_length(ind_stat+1))
      op=shift_op(op,ind_nonempty,op_afterminus(1,1)+1,1)
      ind_length(ind_stat+1)=ind_length(ind_stat+1)+1
   end
end
 
endfunction
