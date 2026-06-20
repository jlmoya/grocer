function [idn,name_indiv]=nameid(id,name)
 
// PURPOSE: determine the unique elements in a vector and
// give them names (if the vector is made of numbers) or
// numbers (if the vector is made of strings)
// ------------------------------------------------------------
// INPUT:
// * id = a string vector
// * name = a string used for the default names
// ------------------------------------------------------------
// * idn = a real vector
// * name_indiv = the names of the individuals
// ------------------------------------------------------------
// Copyright: Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
 
id_number=%t
for i=1:size(id,1)
   if or(ascii(id(i)) < 46) | or(ascii(id(i)) >57) then
      id_number=%f
   end
end
 
if id_number then
   execstr('idn='+id)
   [B,ind]=gsort(idn','g','d')
   dB=[B(2:$)-B(1:$-1) ; 1]
   // eliminates the redundant values
   binv=B(dB ~= 0)
   // take the inverse of binv to obtain the increasing order
   indiv=binv($:-1:1)
   name_indiv='individual # '+string(indiv)
 
else
   idb=id
   i=1
   while size(idb,2) ~= 0 then
      name_indiv=[name_indiv ; idb(1)]
      indname=find(id == idb(1))
      id(indname)=string(i)
      idb(idb==idn(1))=[]
   end
   idn=[1:size(size(id,1))]
 
end
endfunction
