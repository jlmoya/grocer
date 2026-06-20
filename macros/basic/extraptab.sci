function [critical]=extraptab(tab,n)
 
// PURPOSE: from a table (implicitly of stats...) filled for
// some values for the # of observations, calculate the
// corresponding values for n observations
// ------------------------------------------------------------
// INPUT:
// * tab = a (pxq) table where
//   - the first row is not used (it is supposed to be filled
//     with the size levels
//   - each row has the form [n v1 ... vn] where n is a # of
//     observations (filled from the lowest to the highest in
//     col 1, starting from row 2, since row 1 is not used)
// * n = a scalar (the # of observations for which critical are
//   calculated by extrapolation)
// ------------------------------------------------------------
// OUTPUT:
// critical = a (1xq) vector of critical values for all sizes
// present in the table tab
// ------------------------------------------------------------
 
[nr,nc]=size(tab)
// extrapolate the table to the lowest and highest values to
// ease the extrapolation
tab(1,:)=[1 tab(2,2:nc)]
tab=[tab ; max(tab(nr,1),n) tab(nr,2:nc) ]
 
place=size(find(tab(:,1)<n),2)
delta=tab(place+1,1)-tab(place,1)
critical=tab(place,2:nc)*(1-(n-tab(place,1))/delta)+...
         tab(place+1,2:nc)*(n-tab(place,1))/delta
 
endfunction
 
