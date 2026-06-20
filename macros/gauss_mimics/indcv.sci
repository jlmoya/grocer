function v=indcv(str_what,str_where)
 
// PURPOSE: mimic gauss function indcv: checks one character
// vector against another and returns the indices of the
// elements of the first vector in the second vector
// ------------------------------------------------------------
// INPUT:
// * str_what = a (N x 1) character vector which contains the
//   elements to be found in vector str_where
// * str_where = a (M x 1) to be searched for matches to the
//   elements of str_what
// ------------------------------------------------------------
// OUTPUT:
// * v = a (N x 1) vector of integers containing the indices of
//   the corresponding element of str_what in str_where
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
nwhat=size(str_what,'*')
v=zeros(nwhat,1)
for i=1:nwhat
   v(i)=find(str_where == str_what(i))
end
 
endfunction
 
