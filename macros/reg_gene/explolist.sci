function [l1,l3]=explolist(l1,l2)
 
// PURPOSE: splits the list l1 in 2 lists containing the
// elements that do (l3) or do not (l1) verify
// the conditions contained in list l2
// ------------------------------------------------------------
// INPUT:
// * l1 = the list to split
// * l2 =the list of conditions
// ------------------------------------------------------------
// OUTPUT:
// * l1 = the initial list without the elements verifying the
// conditions
// * l3 = the initial list with the elements verifying the
// conditions
// ------------------------------------------------------------
// NOTES:
// used by the following functions:
// ols(), olsc()
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
 
 
l3=list()
nl1=length(l1)
nl2=length(l2)
for i=nl1:-1:1
   t=l1(i)
   if typeof(t) == 'string' & max(size(t)) == 1 then
      j=1
      while j < nl2 & ~evstr(l2(j)) then
         j=j+1
      end
      if evstr(l2(j)) then
         l3($+1)=l1(i)
         l1(i)=null()
      end
   end
end
 
endfunction
 
