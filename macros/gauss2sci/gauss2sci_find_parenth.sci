function [ind_leftpar,ind_rightpar,ind_fuspar]=gauss2sci_find_parenth(statk,ind_stat,ind_length,ind_leftpar,ind_rightpar,typepar,preced)
 
// PURPOSE: in a gauss translation, find the indexes of left and
// right parentheses of a statement component and add them to
// the corresponding list reltive to a whole statement
// ------------------------------------------------------------
// INPUT:
// * statk = a gauss statement component
// * ind_stat = the index of this gauss statement component
// * ind_length = a (1 x N) vector of integers, with 0 in the
//   first place, then the position where the parts of the
//   statement end
// * ind_leftpar = a (2 x N) matrix, the first line indicates
//   the indexes of '(' in a statememnt, the second one the
//   index of the component where the parenthesis has been
//   found
// * ind_rightpar = a (2 x N) matrix, the same as ind_leftpar
//   for ')'
// * ind_stat = the index of the component where the
//   parentheses are searched for
// * ind_length = a (1 x (K+1)) vector, starting with 0 and
//   then indicating the cumulated length of the statement
//   components
// ------------------------------------------------------------
// OUTPUT:
// * ind_leftpar = the original matrix extended with the
//   parentheses '(' found in the statement component
// * ind_rightpar = the original matrix extended with the
//   parentheses ')' found in the statement component
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
// find indexes of left parentheses
ind_leftpar_i=strindex(statk,typepar(1))
if ~isempty(ind_leftpar_i) then
   ind_leftpar_i=[ind_leftpar_i+ind_length(ind_stat) ; ...
                  ind_stat*ones(1,size(ind_leftpar_i,2));...
                  ind_leftpar_i+ind_length(ind_stat)+1 ;...
                  preced*ones(1,size(ind_leftpar_i,2))]
   ind_leftpar=[ind_leftpar ind_leftpar_i]
end
 
// find indexes of right parentheses
ind_rightpar_i=strindex(statk,typepar(2))
if ~isempty(ind_rightpar_i) then
   ind_rightpar_i=[ind_rightpar_i+ind_length(ind_stat) ; ...
                   ind_stat*ones(1,size(ind_rightpar_i,2));...
                  ind_rightpar_i+ind_length(ind_stat)+1 ;...
                  preced*ones(1,size(ind_rightpar_i,2))]
   ind_rightpar=[ind_rightpar ind_rightpar_i]
end
 
ind_fuspar=fusion_par(ind_leftpar,ind_rightpar)
 
endfunction
