function v=indnv(num_what,num_where)
 
// PURPOSE: mimics gauss function indcv: Checks one numeric
// vector against another and returns the indices of the
// elements of the first vector in the second vector
// ------------------------------------------------------------
// INPUT:
// * num_what = a (N x 1) numeric vector which contains the
//   elements to be found in vector str_where
// * num_where = a (M x 1) to be searched for matches to the
//   elements of num_what
// ------------------------------------------------------------
// OUTPUT:
// * v = a (N x 1) vector of integers containing the indices of
//   the corresponding element of num_what in num_where
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
if or([tyepof(num_what) tyepof(num_str)]) ~= 'constant' then
   error('indnv works only with numbers')
end
 
nwhat=size(num_what,'*')
v=zeros(nwhat,1)*%nan
for i=1:nwhat
   indi=find(num_where == num_what(i))
   if ~isempty(indi) then
     v(i)=indi(1)
   end
end
 
endfunction
 
