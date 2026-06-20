function [op,ind_nonempty]=add_par_op(op,ind_nonempty,type_par,preced,ind_left,ind_right)
 
ind_fuspar=op(type_par)
ind_fuspar_1=ind_fuspar(:,ind_fuspar(1,:) < ind_left(1))
ind_fuspar_2=[ind_left ; 1 ;ind_fuspar_1(4,$)+1]
ind_fuspar_3=ind_fuspar(:,ind_fuspar(1,:) >= ind_left(1) & ind_fuspar(1,:) < ind_right(1))
if ~isempty(ind_fuspar_3) then
   ind_fuspar_3(4,:)=ind_fuspar_3(4,:)+1
end
ind_fusparn=[ind_fuspar_1 ind_fuspar_2 ind_fuspar_3]
ind_fuspar_4=[ind_right ; -1 ;ind_fusparn(4,$)-1]
ind_fuspar_5=ind_fuspar(:,ind_fuspar(1,:) >= ind_right(1))
op(type_par)=[ind_fusparn ind_fuspar_4 ind_fuspar_5]
// add the parenthesis type to the list of non empty op fields
// and remove it if it is already present with function unique
ind_nonempty=unique([ind_nonempty preced+30 43])

ind_all=op('all')
ind_all_1=ind_all(:,ind_all(1,:) < ind_left(1))
ind_all_2=[ind_left ; ind_left(1)+1 ; preced]
ind_all_3=ind_all(:,ind_all(1,:) >= ind_left(1) & ind_all(1,:) < ind_right(1))
ind_all_4=[ind_right ; ind_right(1)+1 ; preced]
ind_all_5=ind_all(:,ind_all(1,:) >= ind_right(1))
op('all')=[ind_all_1 ind_all_2 ind_all_3 ind_all_4 ind_all_5] 
  
endfunction