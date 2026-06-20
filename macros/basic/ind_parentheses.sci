function [ind_leftpar_aug,ind_rightpar_aug,ind_fuspar,count_par]=ind_parentheses(ind_leftpar,ind_leftpar)
  

ind_leftpar_augmented=[ind_leftpar ; 0*ind_leftpar(1,:)+1]
ind_rightpar_augmented=[ind_rightpar ; 0*ind_rightpar(1,:)-1]
ind_par=[ind_leftpar_augmented ind_rightpar_augmented]
[junk,indexes]=gsort(ind_par(1,:),'g','i')
ind_fuspar=ind_par(:,indexes)
count_par=cumsum(ind_fuspar,'c')

endfunction
