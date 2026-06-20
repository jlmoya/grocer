function [statement,op,ind_length]=gauss2sci_add_brackets(statement,op,ind_length)
    
ind_fusbrack=op('fusbrack')
ind_leftbrack=ind_fusbrack(:,ind_fusbrack(3,:)==1)
ind_rightbrack=ind_fusbrack(:,ind_fusbrack(3,:)==-1)

for i=size(ind_leftbrack,2):-1:1
// deal with extractions from a matrix:
// change the '[' into '(' whithout change on the operator tlist
//   ind_fusbrack=op('fusbrack')
//   ind_leftbrack=ind_fusbrack(:,ind_fusbrack(3,:)==1)
//   ind_rightbrack=ind_fusbrack(:,ind_fusbrack(3,:)==-1)
   ind_i=ind_leftbrack(:,i)
   ind_stati=ind_i(2)
   statement(ind_stati)=part(statement(ind_stati),1:ind_i(1)-1-ind_length(ind_stati))+'('+...
            part(statement(ind_stati),ind_i(1)+1-ind_length(ind_stati):length(statement(ind_stati)))

   ind_i=ind_rightbrack(:,i)
   ind_stati=ind_i(2)
   statement(ind_stati)=part(statement(ind_stati),1:ind_i(1)-1-ind_length(ind_stati))+')'+...
            part(statement(ind_stati),ind_i(1)+1-ind_length(ind_stati):length(statement(ind_stati)))

// if there is a blank in the list of indexes, then 
// it is necessary to add the matrices symbol '[' and ']'
   ind_start=ind_leftbrack(1,i)
   ind_after=ind_fusbrack(:,ind_fusbrack(1,:)>=ind_start)
   ind_end=find(ind_after(4,:) == ind_fusbrack(4,1)-1)
   ind_end=ind_after(:,ind_end(1))
   stat_j=ind_leftbrack(2,i)
   start_j=ind_leftbrack(1,i)-ind_length(ind_leftbrack(2,i))
   stat_k=ind_end(2)
   start_k=ind_end(1)-ind_length(ind_end(2))
   stat_aux=part(strcat(statement),ind_start+1:ind_end(1)-1)

   list_arg=extract_arg(stat_aux,',','(',')',''"')
   length_arg=length(list_arg)
   ind_arg_end=ind_start(1)+cumsum(length_arg +[0 ;0*length_arg(2:$)+1])
   ind_arg_start=[ind_start(1)+1 ;ind_arg_end(1:$-1)+2]
   for i=size(list_arg,1):-1:1
      argi=stripblanks(list_arg(i))
      if ~isempty(strindex(argi,' ')) then
         diff1=ind_arg_start(i)-ind_length
         ind_stat=find(diff1<0)-1
         ind_stat=ind_stat(1)
         statement(ind_stat)=part(statement(ind_stat),1:ind_arg_start(i)-1-ind_length(ind_stat))+'['+...
                             part(statement(ind_stat),[ind_arg_start(i):ind_arg_end(i)]-ind_length(ind_stat))+']'+...
                             part(statement(ind_stat),[ind_arg_end(i)+1:ind_length(ind_stat+1)]-ind_length(ind_stat))
         ind_length(ind_stat+1)=ind_length(ind_stat+1)+2
         op=shift_op(op,ind_nonempty,ind_arg_start(i),1)
         op=shift_op(op,ind_nonempty,ind_arg_end(i)+1,1)
         // deal the added brackets as parentheses (this is what they are implictely in Gauss
         // this avoids to retransform them into parentheses in gauss2sci_rep_all
         [op,ind_nonempty]=add_par_op(op,ind_nonempty,'fuspar',11,[ind_arg_start(i);ind_stat],[ind_arg_end(i)+1;ind_stat])
      end
   end
 
end



endfunction