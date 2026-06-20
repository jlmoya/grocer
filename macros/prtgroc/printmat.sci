function []=printmat(mat,out,v);
 
// PURPOSE: prints a matrix with aligned columns
// ------------------------------------------------------------
// INPUT:
// * mat = the matrix to print
// * out = the symobolic name of the file where the
//              results are printed
// * v = a vector of lines where only the first term will be
//   used and will not be counted to align the first column
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// NOTES:
// * used by the following functions:
// prtuniv(),kpss()
// ------------------------------------------------------------
// Copyright: INRIA/Eric Dubois 2002-2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
n_lines=size(mat,1)
if nargin == 2 then
   v=[]
end
 
w=1:n_lines
w(v)=[]
L=max(length(mat(w,:)),'r') ;
t=emptystr(n_lines,1) ;
 
// each line is filled with the concatenation of the corresponding
// columns
for k=1:size(mat,2)
  t(w)=t(w)+part(mat(w,k),1:L(k)+2) ;
end
 
// lines which are outside the alignement are filled with the first
// term of the corresponding line in matrix mat
t(v)=mat(v,1)
 
write(out,t,'(a)')
 
endfunction
