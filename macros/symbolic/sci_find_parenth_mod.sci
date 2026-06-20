function [ind_leftpar,ind_rightpar,ind_fuspar]=sci_find_parenth_mod(statk)
 
// PURPOSE: in a string, find the indexes of left and
// right parentheses
// ------------------------------------------------------------
// INPUT:
// * statk = a string
// ------------------------------------------------------------
// OUTPUT:
// * ind_leftpar = a (3 x N) matrix, with:
//               - 1st row: the index of the left parentheses
//                 in the string
//               - 2nd row: the corresponding precedence (11)
//               - 3rd row: N times 1
// * ind_rightpar = a (3 x N) matrix, with:
//               - 1st row: the index of the right parentheses
//                 in the string
//               - 2nd row: the corresponding precedence (11)
//               - 3rd row: N times -1
// * ind_fuspar = the fusion of ind_leftpar and ind_rghtpar,
//   with a 4th row cumulating the signed index of the
//   parentheses (+1 for a left parenthesis, -1 for a right one)
// ------------------------------------------------------------
// Copyright Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
 
 
// find indexes of left parentheses
ind_leftpar=strindex(statk,'(')
ind_leftpar=[ind_leftpar ; 11*ind_leftpar ./ ind_leftpar ; ind_leftpar ./ ind_leftpar]
 
   // find indexes of right parentheses
ind_rightpar=strindex(statk,')')
ind_rightpar=[ind_rightpar ; 11*ind_rightpar ./ ind_rightpar ; -ind_rightpar ./ ind_rightpar]
 
ind_par=[ind_leftpar , ind_rightpar]
[junk,indexes]=gsort(ind_par(1,:),'g','i')
ind_fuspar=ind_par(:,indexes)
ind_fuspar=[ind_fuspar ; cumsum(ind_fuspar(3,:))]
 
endfunction
