function v1=setdifsa(v1,v2)
 
// PURPOSE: mimics gauss function setdifsa: returns the unique
// elements in one string vector that are not present in a
// second string vector
// ------------------------------------------------------------
// INPUT:
// * v1 = a (N x 1) vector
// * v2 = a (M x 1) vector
// ------------------------------------------------------------
// OUTPUT:
// * v1 = (L x 1) vector of all unique values in v1 that are
//  not in v2
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
v1=gsort(unique(v1),'g','i')
v1s=v1
v2s=unique(v2)
 
if typ == 2 then
   v1s=convstr(v1)
   v2s=convstr(v2)
end
 
for j=size(v1s,'*'):-1:1
   if or(v1s(j) == v2s) then
      v1(j)=[]
   end
end
 
 
 
endfunction
 
