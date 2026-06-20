function v=string2vec(s,sep)
 
// PURPOSE: gives the content of a database (simple but not
// elegant and, I presume, not efficient)
// ------------------------------------------------------------
// INPUT:
// * s =  a string
// * sep = a tring (the spearator between elements in the
//   string v)
// ------------------------------------------------------------
// OUTPUT:
// * v = a vector of strings
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
 
if isempty(s) then
   v=[]
else
   indsep=[0 strindex(s,sep) length(s)+1]
   n=size(indsep,2)-1
   v=emptystr(n,1)
   for i=1:n
      v(i)=part(s,indsep(i)+1:indsep(i+1)-1)
   end
end
 
endfunction
 
