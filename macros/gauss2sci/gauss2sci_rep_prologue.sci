function [stat_i,type_stat_i,ind_length]=gauss2sci_rep_prologue(stat_i,type_stat_i)
 
// PURPOSE: Make first substitutions: $, gauss logical symbols,
// etc.
// ------------------------------------------------------------
// INPUT:
// * stat_i = a gauss statement
// ------------------------------------------------------------
// OUTPUT:
// * stat_i = the same statement but with logical symbols
//   transformed once
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
ind_length=zeros(1,size(stat_i,2)+1)
for j=1:size(stat_i,'*')
 
   if ~isempty(stat_i(j)) then
      stat_ij=stat_i(j)
 
      // tranform all global conditions into their numerical Scilab form
      // they have still to be supplemented by an 'and'
      stat_ij=strsubst_trueobj(stat_ij,'lt','<',' ',' ',%f,%t)
      stat_ij=strsubst_trueobj(stat_ij,'le','<=',' ',' ',%f,%t)
      stat_ij=strsubst_trueobj(stat_ij,'eq','==',' ',' ',%f,%t)
      stat_ij=strsubst_trueobj(stat_ij,'ne','~=',' ',' ',%f,%t)
      stat_ij=strsubst_trueobj(stat_ij,'gt','>',' ',' ',%f,%t)
      stat_ij=strsubst_trueobj(stat_ij,'ge','>=',' ',' ',%f,%t)
 
      stat_ij=strsubst(stat_ij,'.$<=',' .le ')
      stat_ij=strsubst(stat_ij,'.$<',' .lt ')
      stat_ij=strsubst(stat_ij,'.$==',' .eq ')
      stat_ij=strsubst(stat_ij,'.$/=',' .ne ')
      stat_ij=strsubst(stat_ij,'.$>=',' .ge ')
      stat_ij=strsubst(stat_ij,'.$>',' .gt ')
 
 
      stat_ij=strsubst(stat_ij,'/=','~=')
      stat_ij=strsubst(stat_ij,'$<','<')
      stat_ij=strsubst(stat_ij,'$==','==')
      stat_ij=strsubst(stat_ij,'$/=','~=')
      stat_ij=strsubst(stat_ij,'$>','>')
      stat_ij=strsubst(stat_ij,'$~','~')
 
      // tranform all el. by el. conditions into their literal form
      // they will be dealt at the end
      stat_ij=strsubst(stat_ij,'.<=',' .le ')
      stat_ij=strsubst(stat_ij,'.<',' .lt ')
      stat_ij=strsubst(stat_ij,'.==',' .eq ')
      stat_ij=strsubst(stat_ij,'./=',' .ne ')
      stat_ij=strsubst(stat_ij,'.>=',' .ge ')
      stat_ij=strsubst(stat_ij,'.>',' .gt ')
 
      stat_ij=strsubst(stat_ij,'[.','[:')
      stat_ij=strsubst(stat_ij,'.]',':]')
 
      stat_i(j)=stat_ij
   end
end
ind_length=[0 cumsum(length(stat_i))]
 
endfunction
