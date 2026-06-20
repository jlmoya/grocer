function [statk,op,ind_length]=gauss2sci_rep_matfunc(statk,op,ind_nonempty,ind_length)
 
// PURPOSE: in a gauss translation, transform function
// working on matrices
// ------------------------------------------------------------
// INPUT:
// * statk = a gauss statement
// * op = a tlist with each field corresponding to an operator
//   op(i) = a (4 x p) matrix:
//   - first line: the positions of the operator
//   - second line: the statement number where the operator
//     appears
//   - third line: the position of the operator end
//   - fourth line: the precedence of the operator, as
//     indicated in the table of gauss manual (chapter 11-23
//     for gauss 10 version)
// * ind_nonempty = vector of non empty operator fields
// * ind_length = a (1 x (K+1)) vector, starting with 0 and
//   then indicating the cumulated length of the statement
//   components
// ------------------------------------------------------------
// OUTPUT:
// * statk = the transformed gauss statement
// * op = the transformed operators tlist
// * ind_length = the transformed vector of cumulated lengths
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
// start with % since I need the index of the parentheses
ind_all=op('all')
ind_percent_def=op('percent')
 
for i=size(ind_percent_def,2):-1:1
   ind_percent_i=ind_percent_def(1,i)
   ind_fuspar=op('fuspar')
   ind_leftpar=ind_fuspar(:,ind_fuspar(3,:) == 1)
   ind_rightpar=ind_fuspar(:,ind_fuspar(3,:) == -1)
   ind_start=find_start(ind_leftpar,ind_rightpar,ind_all,75,ind_percent_i)
   ind_end=find_end(ind_leftpar,ind_rightpar,ind_all,75,ind_percent_i,length(statk)-1)
   statk=part(statk,1:ind_start(1)-1)+'modulo(round('+part(statk,ind_start(1):ind_percent_i-1)...
         +'),'+part(statk,ind_percent_i+1:ind_end(1))+')'+part(statk,ind_end(1)+1:length(statk))
   [op,ind_nonempty]=remove_op(op,ind_nonempty,ind_percent_i,'percent')
   op=shift_op(op,ind_nonempty,ind_end(1),1)
   ind_length(ind_end(2)+1:$)=ind_length(ind_end(2)+1:$)+1
   op=shift_op(op,ind_nonempty,ind_percent_i,1)
   ind_length(ind_percent_def(2,i)+1:$)=ind_length(ind_percent_def(2,i)+1:$)+1
   op=shift_op(op,ind_nonempty,ind_start(1),13)
   ind_length(ind_start(2)+1:$)=ind_length(ind_start(2)+1:$)+13
   ind_fuspar=op('fuspar')
   ind_fuspar_1=ind_fuspar(:,ind_fuspar(1,:) < ind_start(1))
   ind_fuspar_2=ind_fuspar(:,ind_fuspar(1,:) >= ind_start(1)+13 & ind_fuspar(1,:) < ind_percent_i(1)+13)
   ind_fuspar_3=ind_fuspar(:,ind_fuspar(1,:) >= ind_percent_i(1)+13 & ind_fuspar(1,:) <= ind_end(1)+15)
   ind_fuspar_4=ind_fuspar(:,ind_fuspar(1,:) > ind_end(1)+15)
   ind_all_1=ind_all(:,ind_all(1,:) < ind_start(1))
   ind_all_2=ind_all(:,ind_all(1,:) >= ind_start(1)+13 & ind_all(1,:) < ind_percent_i(1)+13)
   ind_all_3=ind_all(:,ind_all(1,:) >= ind_percent_i(1)+13 & ind_all(1,:) <= ind_end(1)+15)
   ind_all_4=ind_all(:,ind_all(1,:) > ind_end(1)+15)
   if ~isempty(ind_fuspar_2) then
      ind_fuspar_2(4,:)=ind_fuspar_2(4,:)+2
   end
   if ~isempty(ind_fuspar_2) then
      ind_fuspar_3(4,:)=ind_fuspar_3(4,:)+1
   end
   ind_last1=ind_fuspar_1(4,$)
   ind_fuspar_1b=[ind_start(1)+6 ind_start(1)+12 ; ind_start(2) ind_start(2) ; 1 1 ; ind_last1+1 ind_last1+2]
   ind_fusparn=[ind_fuspar_1 ind_fuspar_1b ]
   ind_fuspar_2b=[ind_percent_def(1:2,i)+[13;0] ; -1 ; ind_fusparn(2,$)+1]
   ind_fusparn=[ind_fusparn ind_fuspar_2b ind_fuspar_3]
   ind_fuspar_3b=[ind_end(1:2)+[15;0] ; -1 ; ind_fusparn(4,$)-1]
   op('fuspar')=[ind_fusparn ind_fuspar_3b ind_fuspar_4]
   op('all')=[ind_all_1 ind_fuspar_1b ind_all_2 ind_fuspar_2b ind_all_3 ind_fuspar_3b ind_all_4]
   [op,ind_nonempty]=add_op(op,ind_nonempty,ind_percent_i+[14;1;0;-64],'comma')
end
 
[statk,op,ind_length]=gauss2sci_op2foo(statk,op,ind_length,'matmul','matmul(',80,2)
[statk,op,ind_length]=gauss2sci_op2foo(statk,op,ind_length,'matdiv','matdiv(',80,2)
[statk,op,ind_length]=gauss2sci_op2foo(statk,op,ind_length,'slash','div(',80,1)
 
 
ind_nostring=find(type_statement == 'nostring')
for elem=ind_nostring
   start=ind_length(elem)
   statk_elem=convstr(statk(elem))
   before_f=[' ' ; ';' ; '=' ; '+' ; '-' ; '*' ; '/' ; '~' ; '|' ; ...
   '  ('; '[';'^';'>';'<';'^']
    after_f=[' ' ; ';' ; '+' ; '-' ; '*' ; '/' ; '~' ; '|' ; ')'; ...
    ']';'^';'>';'<';'.']
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'pi','%pi',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
 
   before_f=[' ' ; ';' ; '=' ; '+' ; '-' ; '*' ; '/' ; '~' ; '|' ; ...
   '('; '[';'^';'>';'<';'^']
   after_f=[' ' ; '(' ;'[' ]
 
//   [statk_elem,op,ind_length]=keep_arg(statk_elem,'intrsct',1:2,before_f,after_f)
//   [statk_elem,op,ind_length]=keep_arg(statk_elem,'union',1:2,before_f,after_f)
 
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'arccos','acos',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'arcsin','asin',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'balance','balanc',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'chrs','ascii',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'diag','diag_gauss',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'eig','spec',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
 
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'fmod','modulo',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'format','format_gauss',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'intrsect','intersect',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'intrsectsa','intersect',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'log','log10',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'ln','log',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'lowmat','tril',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'qr','qr_gauss',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'qqr','qr',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'qqre','qr',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'qtyr','qtyre',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'reshape','reshape_gauss',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'strlen','length',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'svd1','svd',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'trunc','fix',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'uniqindxsa','uniqindx',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'upmat','triu',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'vech','vech_gauss',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   [statk_elem,op,ind_length]=gauss2sci_strsub_trueobj(statk_elem,'unique','unique_gauss',before_f,after_f,%t,op,ind_nonempty,ind_length,elem)
   statk(elem)=statk_elem
 
   [true_eye,ind_eye_def,statk_elem]=findobject(statk(elem),'eye',before_f,after_f,%t)
   for i=size(ind_eye_def,1):-1:1
      ind_eye_i=ind_eye_def(i)
      ind_fuspar=op('fuspar')
      ind_fusparb=ind_fuspar(:,ind_fuspar(1,:)>ind_eye_i)
      ind_start=ind_fusparb(:,1)
      ind_rightpar=ind_fusparb(:,ind_fusparb(4,:)==ind_start(4)-1)
      ind_end=ind_rightpar(:,1)-ind_length(elem)
      if ind_end(2) == ind_start(2) then
         statk(elem)=part(statk(elem),1:ind_end(1)-1)+','+...
                     part(statk(elem),ind_start(1)+1-ind_length(elem):ind_end(1))+...
                     part(statk(elem),ind_end(1)+1:length(statk(elem)))
         sup=ind_end(1)-ind_start(1)
         for j=ind_nonempty
             opj=op(j)
             opj_before=opj(:,opj(1,:)<ind_end(1))
             opj_after=opj(:,opj(1,:)>=ind_end(1))
             if ~isempty(opj_after) then
                opj_after(1,:)=opj_after(1,:)+sup
                opj_after(3,:)=opj_after(3,:)+sup*and(j~=[41;42])
             end
             opj_1_sup=opj_before(:,opj_before(1,:)>ind_start(1))
             if isempty(opj_1_sup) then
                op(j)=[opj_before opj_after]
             else
                opj=[opj_before [opj_1_sup(1,:)+sup;opj_1_sup(2,:);opj_1_sup(3,:)+sup*and(j~=[41;42]);opj_1_sup(4,:)] ...
                     opj_after]
                op(j)=opj
 
             end
 
         end
         opj=op('comma')
         opj_before=opj(:,opj(1,:)<ind_end(1))
         opj_after=opj(:,opj(1,:)>ind_end(1))
         opj=[opj_before [ind_end(1)+ind_length(elem)-1;elem;ind_end(1)+ind_length(elem);11] opj_after]
         op('comma')=opj
         ind_length(ind_end(2)+1:$)=ind_length(ind_end(2)+1:$)+sup
 
      end
    end
 
end
 
 
endfunction
