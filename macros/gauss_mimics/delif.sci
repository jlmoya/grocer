function matin=delif(matin,condition)
 
// PURPOSE: mimic Gauss function delif: deletes from a matrix
// the rows deleted are those for which there is a 1 in
// the corresponding row of condition
// ------------------------------------------------------------
// INPUT:
// * matin = a (p x q) matrix
// * condition = a (p x 1) vector of 0 and 1
// ------------------------------------------------------------
// OUTPUT:
// * matin = a (m x q) matrix with m <=p with rows of
//   matin whose value in condition is set to 1 have been
//   removed
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
if size(matin,1) ~= size(condition,'*') then
   error('# of rows of input data non conformable')
end
 
matin(condition,:)=[]
 
endfunction
 
