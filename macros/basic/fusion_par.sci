function ind_fuspar=fusion_par(ind_leftpar,ind_rightpar)
 
// PURPOSE: given indexes of left and right parentheses, add a
// line signing them (+1 for left parentheses, -1 for right
// ones), make their fusion, sort them and adda line
// calculating the cumulated sign indexes
// ------------------------------------------------------------
// INPUT:
// * ind_leftpar = a (k x N) vector, with the index of left
//   parentheses on the first row
// * ind_rightpar = a (k x N) vector, with the index of right
//   parentheses on the first row
// ------------------------------------------------------------
// OUTPUT:
// * ind_fuspar = a ((k+2) x 2*N) matrix, with the sorted
//   fusion of indexes on the first row, complemented by a row
//   of the parentehses signs (+1 for the left ones, -1 for the
//   right ones) and a line of their cumulated signs
// ------------------------------------------------------------
// Copyright Eric Dubois 2010-2019
// http://grocer.toolbox.free.fr/grocer.html
 
// add a line of signs
if isempty(ind_leftpar) then
   ind_leftpar_augmented=[]
else
   ind_leftpar_augmented=[ind_leftpar(1:2,:) ; 0*ind_leftpar(1,:)+1]
end
if isempty(ind_rightpar) then
   ind_rightpar_augmented=[]
else
   ind_rightpar_augmented=[ind_rightpar(1:2,:) ; 0*ind_rightpar(1,:)-1]
end
// now sort them by their index
ind_par=[ind_leftpar_augmented ind_rightpar_augmented]
[junk,indexes]=gsort(ind_par(1,:),'g','i')
ind_fuspar=ind_par(:,indexes)
ind_fuspar=[ind_fuspar ; cumsum(ind_fuspar($,:),'c')]
 
endfunction
