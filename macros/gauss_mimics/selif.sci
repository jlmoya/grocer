function matout=selif(matin,condition)
 
// PURPOSE: mimics gauss function selif
// ------------------------------------------------------------
// INPUT:
// * matin = a (p x q) matrix
// * condition = a (p x 1) vector of 0 and 1
// ------------------------------------------------------------
// OUTPUT:
// * matout = a (m x q) matrix with m <=p containing rows of
//   matin whose value in condition is set to 1
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
if size(matin,1) ~= size(condition,'*') then
   error('# of rows of input data non conformable')
end
 
matout=matin(condition == 1,:)
 
endfunction
 
