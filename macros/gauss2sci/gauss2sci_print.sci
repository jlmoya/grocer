function [statement,type_statement,op,ind_nonempty,ind_length]=gauss2sci_print(statement,type_statement,op,ind_nonempty,ind)
 
// PURPOSE: transform a Gauss print command into a call
// to Grocer function print_gauss
// ------------------------------------------------------------
// INPUT:
// * statement = a statement
// * type_statement = a string vector of 'string' and 'nostring'
//   indicating the type of the statement components
// * ind = index of the print keyword
// ------------------------------------------------------------
// OUTPUT:
// * statement = the transformed statement
// * type_statement = the transformed type vector of statements
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
ntypes=size(statement,2)
ind_length=[0 cumsum(length(statement))]
 
for i=ntypes-1:-1:2
   if type_statement(i) == 'string' then
      if strsubst(statement(i+1),' ','') ~= ';' then
         statement(i+1)=','+statement(i+1)
         length_i=ind_length(i+1)
         op=shift_op(op,ind_nonempty,length_i+1,1)
         op_comma=op('comma')
         op_all=op('all')
         op('comma')=[op_comma(:,op_comma(1,:) <= length_i) [length_i+1 ; i+1 ; length_i+2 ; 11] op_comma(:,op_comma(1,:) >= length_i)]
         op('all')=[op_all(:,op_all(1,:) <= length_i) [length_i+1 ; i+1 ; length_i+2 ; 11] op_all(:,op_all(1,:) >= length_i)]
         ind_length(i+2:ntypes)=ind_length(i+2:ntypes)+1
      end
   else
      statement(i)=statement(i)+','
         length_i=ind_length(i+1)
         op=shift_op(op,ind_nonempty,length_i+1,1)
         op_comma=op('comma')
         op_all=op('all')
         op('comma')=[op_comma(:,op_comma(1,:) <= length_i) [length_i+1 ; i+1 ; length_i+2 ; 11] op_comma(:,op_comma(1,:) >= length_i)]
         op('all')=[op_all(:,op_all(1,:) <= length_i) [length_i+1 ; i+1 ; length_i+2 ; 11] op_all(:,op_all(1,:) >= length_i)]
         ind_length(i+2:ntypes)=ind_length(i+2:ntypes)+1
 
   end
end
 
ind_slash=op('slash')
list_keyw_2=['on' ;'m0' ; 'm1'; 'm2'; 'm3'; 'a1' ;'a2'; 'b2'; 'b3' ;'sa' ]
list_keyw_2b=['rd' ; 're' ; 'ro' ;'rz' ;'ld' ; 'le' ; 'lo' ;'lz' ]
list_keyw_3=['off' ; 'mb1' ; 'mb2'; 'mb3'; 'ma1' ;'ma2' ; 'mat' ; 'str']
list_keyw_3b=[list_keyw_2b+'s' ; list_keyw_2b+'c' ; list_keyw_2b+'t' ; list_keyw_2b+'n' ]
last_slash=%t
 
for i=size(ind_slash,2):-1:1
 
   ind_slash_i=ind_slash(:,i)
   ind_slash_i_1=ind_slash_i(1)
   j=ind_slash_i(2)
   stat_j=statement(j)
   length_j=ind_length(j)
   ind_j_slash=ind_slash_i_1-length_j
   post_slash=part(stat_j,ind_j_slash+1:length(stat_j))
   stripb_postflash=stripblanks(post_slash)
   length_keyw=length(post_slash) // note: this is the length of the keyw only if it is the end of the statement part
 
   if stripb_postflash == 'flush' then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+5,3)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[length_keyw+3;1;0;-69],'comma')
      if type_statement(j+1) == 'nostring' then
         statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1) ...
                , '''/'+post_slash+''''','+statement(j+1) , statement(j+2:$)]
         type_statement=[type_statement(1:j) "string" type_statement(j+1:$)]
         op=shift_op2(op,ind_nonempty,ind_slash_i_1+length_keyw+3,1)
      else
         statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1) ...
               , '''/'+post_slash+''''',' , statement(j+1) , statement(j+2:$)]
         type_statement=[type_statement(1:j) , "string" , "nostring" , type_statement(j+1:$)]
         op=shift_op2(op,ind_nonempty,ind_slash_i_1+length_keyw+3,2)
      end
 
   elseif or(stripb_postflash == [list_keyw_2 ; list_keyw_2b]) then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+2,3)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[length_keyw+3;1;0;-69],'comma')
      if type_statement(j+1) == 'nostring' then
         statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1) ...
                , '''/'+post_slash+'''' , comma_after+statement(j+1) , statement(j+2:$)]
         type_statement=[type_statement(1:j) , "string" , type_statement(j+1:$)]
         op=shift_op2(op,ind_nonempty,ind_slash_i_1+length_keyw+3,1)
      else
         statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1) ...
                , '''/'+post_slash+''''',' , statement(j+1) , statement(j+2:$)]
         type_statement=[type_statement(1:j) "string" "nostring" type_statement(j+1:$)]
         op=shift_op2(op,ind_nonempty,ind_slash_i_1+length_keyw+3,2)
      end
 
   elseif or(stripb_postflash == [list_keyw_3  ; list_keyw_3b]) then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+2,3)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[length_keyw+3;1;0;-69],'comma')
      if type_statement(j+1) == 'nostring' then
         statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1)+first_comma ...
                , '''/'+post_slash+'''' ','+statement(j+1) , statement(j+2:$)]
         type_statement=[type_statement(1:j) , "string" , type_statement(j+1:$)]
         op=shift_op2(op,ind_nonempty,ind_slash_i_1+length_keyw+3,1)
      else
         statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1)+first_comma ...
                , '''/'+post_slash+''''',' , statement(j+1) , statement(j+2:$)]
         type_statement=[type_statement(1:j) , "string" , "nostring" , type_statement(j+1:$)]
         op=shift_op2(op,ind_nonempty,ind_slash_i_1+length_keyw+3,2)
      end
 
   elseif part(post_slash,1:6) == 'flush ' then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+5,4)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[8;1;0;-69],'comma')
      op=shift_op2(op,ind_nonempty,ind_slash_i_1+8,2)
      statement=[statement(1:j-1),  part(stat_j,1:ind_j_slash-1) ...
                 , '''/flush'''','+part(stat_j,ind_j_slash+5:length(stat_j)) , statement(j+1:$)]
      type_statement=[type_statement(1:j) "string" "nostring" type_statement(j+1:$)]
 
   elseif part(post_slash,1:6) == 'flush,' then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+5,3)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[8;1;0;-69],'comma')
      op=shift_op2(op,ind_nonempty,ind_slash_i_1+8,1)
      statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1) ...
                 , '''/flush'''',' , part(stat_j,ind_j_slash+5:length(stat_j)) , statement(j+1:$)]
      type_statement=[type_statement(1:j) , "string" , type_statement(j+1:$)]
 
   elseif or(part(post_slash,1:2) == list_keyw_2) & part(post_slash,3) == ' ' then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+5,3)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[5;1;0;-69],'comma')
      op=shift_op2(op,ind_nonempty,ind_slash_i_1+5)
      statement=[statement(1:j-1) part(stat_j,1:ind_j_slash-1) ...
               , '''/'+part(post_slash,1:2)+''''','+part(stat_j,ind_j_slash+3:length(stat_j)) , statement(j+1:$)]
      type_statement=[type_statement(1:j) , "string" , type_statement(j+1:$)]
 
   elseif or(part(post_slash,1:2) == list_keyw_2) & part(post_slash,3) == ',' then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+5,2)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[5;1;0;-69],'comma')
      op=shift_op2(op,ind_nonempty,ind_slash_i_1+5,2)
      statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1) ...
                , '''/'+part(post_slash,1:2)+'''' part(stat_j,ind_j_slash+3:length(stat_j)) , statement(j+1:$)]
      type_statement=[type_statement(1:j) , "string" "nostring" , type_statement(j+1:$)]
 
   elseif or(part(post_slash,1:2) == list_keyw_2b) & part(post_slash,3) == ' ' then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+5,3)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[5;1;0;-69],'comma')
      op=shift_op2(op,ind_nonempty,ind_slash_i_1+5,1)
      statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1) ...
                , '''/'+part(post_slash,1:2)+'''' ','+part(stat_j,ind_j_slash+3:length(stat_j)) , statement(j+1:$)]
      type_statement=[type_statement(1:j) "string" type_statement(j+1:$)]
 
   elseif or(part(post_slash,1:2) == list_keyw_2b) & part(post_slash,3) == ',' then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+5,2)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[5;1;0;-69],'comma')
      op=shift_op2(op,ind_nonempty,ind_slash_i_1+5,2)
      statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1) ...
                , '''/'+part(post_slash,1:2)+''''','+part(stat_j,ind_j_slash+3:length(stat_j)) , statement(j+1:$)]
      type_statement=[type_statement(1:j) , "string" , "nostring" , type_statement(j+1:$)]
 
   elseif or(part(post_slash,1:3) == [list_keyw_3 ; list_keyw_3b]) & part(post_slash,3) == ' ' then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+5,2+ind_comma)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[6;1;0;-69],'comma')
      op=shift_op2(op,ind_nonempty,ind_slash_i_1+6,1)
      statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1) ...
               ,  '''/'+part(post_slash,1:2)+''''','+part(stat_j,ind_j_slash+4:length(stat_j)) , statement(j+1:$)]
      type_statement=[type_statement(1:j) "string" type_statement(j+1:$)]
 
   elseif or(part(post_slash,1:3) == [list_keyw_3 ; list_keyw_3b]) & part(post_slash,3) == ',' then
      [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_slash_i_1,'slash')
      op=shift_op(op,ind_nonempty,ind_slash_i_1+5,2)
      [op,ind_nonempty]=add_op(op,ind_nonempty,ind_slash_i+[6;1;0;-69],'comma')
      op=shift_op2(op,ind_nonempty,ind_slash_i_1+6,2)
      statement=[statement(1:j-1) , part(stat_j,1:ind_j_slash-1) ...
                , '''/'+part(post_slash,1:2)+''''','+part(stat_j,ind_j_slash+4:length(stat_j)) , statement(j+1:$)]
      type_statement=[type_statement(1:j) "string" "nostring" type_statement(j+1:$)]
 
   end
end
 
ind_length=[0 cumsum(length(statement))]
[statement,ind_length,op]=gauss2sci_mat(statement,type_statement,ind_length,op) // transforms some matrix functions
 
statement(1)=part(statement(1),1:ind+4)+'_gauss('+part(statement(1),ind+5:length(statement(1)))
statement($)=part(statement($),1:length(statement($))-1)+');'
op=shift_op(op,ind_nonempty,ind,7)
ind_fuspar=op('fuspar')
ind_fuspar_1=ind_fuspar(:,ind_fuspar(1,:)<ind)
ind_fuspar_2=[ind+11 ; 1 ; 1; ind_fuspar_1(4,$)+1]
ind_fuspar_3=ind_fuspar(:,ind_fuspar(1,:)>ind)
if ~isempty(ind_fuspar_3) then
   ind_fuspar_3(4,:)=ind_fuspar_3(4,:)+1
end
ind_fuspar_4=[sum(length(statement))-1 ; size(statement,2) ; -1 ;0]
op('fuspar')=[ind_fuspar_1 ind_fuspar_2 ind_fuspar_3 ind_fuspar_4]
 
endfunction
