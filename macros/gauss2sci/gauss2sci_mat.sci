function [statement,ind_length,op]=gauss2sci_mat(statement,type_statement,ind_length,op)
 
// PURPOSE: Translate gauss matrix definitions into Scilab
// ------------------------------------------------------------
// INPUT:
// * statement = a (1 x K) vector, stemming from a gauss
//   statement separated between string and non string
//   components
// * type_statement = a (1 x K) vector, indicating if the
//   corresponding statement component is a string or not
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
 
 
ind_comma=bool2s(part(statement($),length(statement($))) == ';')
ind_tilde=op('tilde')
ind_pipe=op('pipe')
ind_all=op('all')
ind_fusbrack_mat=[]
 
// finds the indexes of the matrices separators '~' and '|' and sort them
ind_fus=[ind_tilde ind_pipe]
[junk,indexes]=gsort([ind_fus(1,:)],'g','i')
ind_matsigns=ind_fus(:,indexes)
start=%t
ind_matsigns_suppr=[]
ind_fuspar=op('fuspar')
ind_leftpar=ind_fuspar(:,ind_fuspar(3,:) == 1)
ind_rightpar=ind_fuspar(:,ind_fuspar(3,:) == -1)
 
i=1
nsigns=size(ind_matsigns,2)
// deal with gauss parentheses indicating Scilab brackets:
// this is a sequence starting with a (, ending with a )
// and with matrices signs ('~' or '|') in between
while i <=nsigns
   ind_fuspar=op('fuspar')
   ind_i=ind_matsigns(:,i)
   ind_leftpar=ind_fuspar(:,ind_fuspar(3,:) == 1)
   ind_rightpar=ind_fuspar(:,ind_fuspar(3,:) == -1)
   ind_leftpar_bef=ind_leftpar(:,ind_leftpar(1,:)<ind_i(1))
 
   if isempty(ind_leftpar_bef) then
      i=i+1
 
   else
      ind_start=ind_leftpar_bef(:,$)
      ind_rightpar_aft=ind_rightpar(:,ind_rightpar(1,:)>ind_start(1))
      ind_end=ind_rightpar_aft(:,ind_rightpar_aft(4,:)==ind_start(4)-1)
 
      if ind_end(1) < ind_i(1) then
         i=i+1
 
      else
         ind=find(ind_matsigns(1,:)>ind_end(1))
         if isempty(ind) then
            i=nsigns+1
         else
            i=ind(1)
         end
 
         statement(ind_end(2))=part(statement(ind_end(2)),1:ind_end(1)-1-ind_length(ind_end(2)))+']'+...
             part(statement(ind_end(2)),ind_end(1)-ind_length(ind_end(2)):ind_length(ind_end(2)+1)-ind_length(ind_end(2)))
         ind_length(ind_end(2)+1:$)=ind_length(ind_end(2)+1:$)+1
         statement(ind_start(2))=part(statement(ind_start(2)),1:ind_start(1)-ind_length(ind_start(2)))+'['+...
                              part(statement(ind_start(2)),ind_start(1)+1-ind_length(ind_start(2)):...
                              ind_length(ind_start(2)+1)-ind_length(ind_start(2)))
         ind_length(ind_start(2)+1:$)=ind_length(ind_start(2)+1:$)+1
 
         op=shift_op(op,ind_nonempty,ind_end(1),1)
         op=shift_op(op,ind_nonempty,ind_start(1)+1,1)
 
         ind_matsigns_suppri=find(ind_matsigns(1,:) > ind_start(1) & ind_matsigns(1,:) < ind_end(1))
         nsuppr=size(ind_matsigns_suppri,2)
         i=i+nsuppr
         ind_matsigns_suppr=[ind_matsigns_suppr ind_matsigns_suppri]
 
         ind_matsigns(1,ind_matsigns(1,:)>ind_start(1))=ind_matsigns(1,ind_matsigns(1,:)>ind_start(1))+1
         ind_matsigns(1,ind_matsigns(1,:)>ind_end(1))=ind_matsigns(1,ind_matsigns(1,:)>ind_end(1))+1
 
         ind_fusbrack=op('fusbrack')
         ind_fusbrack_1=ind_fusbrack(:,ind_fusbrack(1,:)<ind_start(1))
         ind_fusbrack_3=ind_fusbrack(:,ind_fusbrack(1,:)>ind_start(1) & ind_fusbrack(1,:)<ind_end(1)+1)
         ind_fusbrack_5=ind_fusbrack(:,ind_fusbrack(1,:)>ind_end(1)+1)
         ind_fusbrack_2=[ind_start(1)+1 ; ind_start(2) ; 1 ; ind_fusbrack_1(4,$)+1 ]
         if ~isempty(ind_fusbrack_3) then
            ind_fusbrack_3(4,:)=ind_fusbrack_3(4,:)+1
         end
         ind_fusbrack=[ind_fusbrack_1 ind_fusbrack_2 ind_fusbrack_3]
         ind_fusbrack_4=[ind_end(1:2)+[1;0] ; -1 ;ind_fusbrack(4,$)-1]
         ind_fusbrack=[ind_fusbrack ind_fusbrack_4 ind_fusbrack_5]
         op('fusbrack')=ind_fusbrack
 
         ind_all=op('all')
         ind_all=[ind_all(:,ind_all(1,:)<ind_start(1)+1) [ind_start(1:2)+[1;0] ; ind_start(1)+2;12] ...
                     ind_all(:,ind_all(1,:)>ind_start(1) & ind_all(1,:) <= ind_end(1)) ...
                     [ind_end(1)+1; ind_end(2) ; ind_end(1)+2 ; 12] ind_all(:,ind_all(1,:)>ind_end(1))]
         op('all')=ind_all
 
 
      end
   end
end
ind_matsigns(:,ind_matsigns_suppr)=[]
 
while ~isempty(ind_matsigns) then
 
   ind_fuspar=op('fuspar')
   ind_leftpar=ind_fuspar(:,ind_fuspar(3,:) == 1)
   ind_rightpar=ind_fuspar(:,ind_fuspar(3,:) == -1)
   ind_all=op('all')
   ind_matsigns_1=ind_matsigns(1,1)
   ind_start=find_start(ind_leftpar,ind_rightpar,ind_all,67,ind_matsigns_1)
   ind_end=find_end(ind_leftpar,ind_rightpar,ind_all,67,ind_matsigns_1,ind_length($)-ind_comma)   // now enclose the found matrix between brackets
 
   statement(ind_end(2))=part(statement(ind_end(2)),1:ind_end(1)-ind_length(ind_end(2)))+']'+...
                         part(statement(ind_end(2)),ind_end(1)-ind_length(ind_end(2))+1:ind_length(ind_end(2)+1)-ind_length(ind_end(2)))
   op=shift_op(op,ind_nonempty,ind_end(1)+1,1)
   ind_length(ind_end(2)+1:$)=ind_length(ind_end(2)+1:$)+1
 
   statement(ind_start(2))=part(statement(ind_start(2)),1:ind_start(1)-1-ind_length(ind_start(2)))+'['+...
                           part(statement(ind_start(2)),ind_start(1)-ind_length(ind_start(2)):ind_length(ind_start(2)+1)-ind_length(ind_start(2)))
   op=shift_op(op,ind_nonempty,ind_start(1),1)
 
   ind_length(ind_start(2)+1:$)=ind_length(ind_start(2)+1:$)+1
   ind_end(1)=ind_end(1)+1
 
   ind_fusbrack=op('fusbrack')
   ind_fusbrack_1=ind_fusbrack(:,ind_fusbrack(1,:)<ind_start(1))
   ind_fusbrack_3=ind_fusbrack(:,ind_fusbrack(1,:)>=ind_start(1) & ind_fusbrack(1,:)<ind_end(1)+1)
   ind_fusbrack_5=ind_fusbrack(:,ind_fusbrack(1,:)>ind_end(1)+1)
   ind_fusbrack_2=[ind_start(1)+1 ; ind_start(2) ; 1 ; ind_fusbrack_1(4,$)+1 ]
   if ~isempty(ind_fusbrack_3) then
      ind_fusbrack_3(4,:)=ind_fusbrack_3(4,:)+1
   end
   ind_fusbrack=[ind_fusbrack_1 ind_fusbrack_2 ind_fusbrack_3]
   ind_fusbrack_4=[ind_end(1:2) ; -1 ;ind_fusbrack(4,$)-1]
   ind_fusbrack=[ind_fusbrack ind_fusbrack_4 ind_fusbrack_5]
 
   op('fusbrack')=ind_fusbrack
 
//   ind_fusbrack_mat1=ind_fusbrack_mat(:,ind_fusbrack_mat<ind_start(1))
//   ind_fusbrack_mat3=ind_fusbrack_mat(:,ind_fusbrack_mat=ind_start(1) & ind_fusbrack_mat(1,:)<ind_end(1))
//   if ~isempty(ind_fusbrack_mat3) then
//      ind_fusbrack_mat3=ind_fusbrack_mat3+1
//   end
//   ind_fusbrack_mat5=ind_fusbrack_mat(:,ind_fusbrack_mat(1,:)>=ind_end(1))
//   if ~isempty(ind_fusbrack_mat5) then
//      ind_fusbrack_mat5=ind_fusbrack_mat5+1
//   end
//   ind_fusbrack_mat=[ind_fusbrack_mat1 ind_start(1)+1 ind_fusbrack_mat3 ind_end(1) ind_fusbrack_mat5]
 
   ind_all=op('all')
   ind_all=[ind_all(:,ind_all(1,:)<ind_start(1)) [ind_start(1:2) ; ind_start(1)+1;12] ...
               ind_all(:,ind_all(1,:)>ind_start(1) & ind_all(1,:) <= ind_end(1)) ...
               [ind_end(1)+1; ind_end(2) ; ind_end(1)+2 ; 12] ind_all(:,ind_all(1,:)>ind_end(1)+1)]
   op('all')=ind_all
 
   ind_matsigns(1,ind_matsigns(1,:)>ind_end(1))=ind_matsigns(1,ind_matsigns(1,:)>ind_end(1))+1
   ind_matsigns(:,ind_matsigns(1,:)>ind_start(1) & ind_matsigns(1,:)<ind_end(1))=[]
 
end
 
 
statement=strsubst(statement,'~',',')
statement=strsubst(statement,'|',';')
statement=strsubst(statement,',=','~=')
 
endfunction
 
//         ind_fusbrack=op('fusbrack')
//      ind_fusbrack_1=ind_fusbrack(:,ind_fusbrack(1,:)<ind_start(1))
//      ind_fusbrack_3=ind_fusbrack(:,ind_fusbrack(1,:)>=ind_start(1) & ind_fusbrack(1,:)<ind_end(1))
//      ind_fusbrack_5=ind_fusbrack(:,ind_fusbrack(1,:)>=ind_end(1))
//      ind_fusbrack_2=[ind_start(1)+1 ; ind_start(2) ; 1 ; ind_fusbrack_1(4,$)+1 ]
//      if ~isempty(ind_fusbrack_3) then
//         ind_fusbrack_3(4,:)=ind_fusbrack_3(4,:)+1
//      end
//      ind_fusbrack=[ind_fusbrack_1 ind_fusbrack_2 ind_fusbrack_3]
//      ind_fusbrack_4=[ind_end(1:2) ; -1 ;ind_fusbrack(4,$)-1]
//      ind_fusbrack=[ind_fusbrack ind_fusbrack_4 ind_fusbrack_5]
//
//      op('fusbrack')=ind_fusbrack
 
//      ind_fusbrack_mat1=ind_fusbrack_mat(:,ind_fusbrack_mat<ind_start(1))
//      ind_fusbrack_mat3=ind_fusbrack_mat(:,ind_fusbrack_mat=ind_start(1) & ind_fusbrack_mat(1,:)<ind_end(1))
//      if ~isempty(ind_fusbrack_mat3) then
//          ind_fusbrack_mat3=ind_fusbrack_mat3+1
//      end
//      ind_fusbrack_mat5=ind_fusbrack_mat(:,ind_fusbrack_mat(1,:)>=ind_end(1))
//      if ~isempty(ind_fusbrack_mat5) then
//          ind_fusbrack_mat5=ind_fusbrack_mat5+1
//      end
//      ind_fusbrack_mat=[ind_fusbrack_mat1 ind_start(1)+1 ind_fusbrack_mat3 ind_end(1) ind_fusbrack_mat5]
//
//      ind_all=op('all')
//      ind_all=[ind_all(:,ind_all(1,:)<=ind_start(1)) [ind_start(1)+1; ind_start(2);ind_start(1)+2;12] ...
//               ind_all(:,ind_all(1,:)>ind_start(1) & ind_all(1,:) < ind_end(1)) ...
//               [ind_end(1:2);ind_end(1)+1;12] ind_all(:,ind_all(1,:)>ind_end(1))]
//      op('all')=ind_all
//
//     ind_parsup=ind_fuspar(:,ind_fuspar(1,:) >= ind_start(1))
//   ind_end=ind_parsup(:,ind_parsup(4,:) == ind_parsup(4,1)-1)
//   ind_end=ind_end(:,1)
//   ind_between=ind_parsup(:,2:$)
//   ind_between=ind_between(:,ind_between(1,:) < ind_end(1))
//   ind_leftbetween=ind_between(:,ind_between(3,:) == 1)
//   ind_matsigns_suppri=find(ind_matsigns(1,:) > ind_start(1) & ind_matsigns(1,:) < ind_end(1))
//   for j=1:size(ind_leftbetween,2)
//      ind_closing=ind_between(:,ind_between(4,:) == ind_leftbetween(4,j)-1)
//      ind_matsigns_suppri(:,ind_matsigns(1,:) > ind_leftbetween(1,1) & ind_matsigns(1,:) < ind_closing(1,1))=[]
//   end
//   if ~isempty(ind_matsigns_suppri)
//
//      ind_matsigns_suppr=[ind_matsigns_suppr ind_matsigns_suppri]
//
//
