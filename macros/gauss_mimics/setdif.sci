function v1=setdif(v1,v2,typ)
 
// PURPOSE: mimics gauss function setdif: returns the unique
// elements in one vector that are not present in a second
// vector
// ------------------------------------------------------------
// INPUT:
// * v1 = a (N x 1) vector
// * v2 = a (M x 1) vector
// * typ = a scalar, the type of data
//   0: character, case sensitive
//   1: numeric
//   2: character, case insensitive
// ------------------------------------------------------------
// OUTPUT:
// * v1 = (L x 1) vector of all unique values in v1 that are
//  not in v2
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
v1=gsort(unique(v1),'g','i')
v2=unique(v2)
v1s=v1
 
if typ == 2 then
   v1s=convstr(v1)
   v2=convstr(v2)
end
 
for j=size(v1s,'*'):-1:1
   if or(v1s(j) == v2) then
      v1(j)=[]
   end
end
 
 
 
endfunction
 
