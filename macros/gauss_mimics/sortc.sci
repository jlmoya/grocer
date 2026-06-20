function mat=sortc(mat,val)
 
// PURPOSE: function that mimics gauss function sortc: sorts a
// matrix according to the value of one of its columns
// ------------------------------------------------------------
// INPUT:
// * mat = a (nxp) matrix
// * val = a scalar, the column number used for the sort
// ------------------------------------------------------------
// OUPTUT:
// * mat = a (nxp) vector
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
[nr,nc]=size(mat)
if val < 1 | val > nc then
   error(string(val)+' is not an available column in'+string(mat))
end
 
[v,indv]=gsort(mat(:,val),'g','i')
mat=mat(indv,:)
 
endfunction
 
