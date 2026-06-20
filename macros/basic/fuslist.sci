function [vecout]=fuslist(listin)
 
// PURPOSE: make the fusion between the vectors of a list
// ------------------------------------------------------------
// INPUT:
// listin = the list of vectors to fusion
// ------------------------------------------------------------
// OUTPUT:
// * vecout= the fusion
// ------------------------------------------------------------
// NOTES:
// * each component of the list must be a (n,1) vector
// * Used by automatic() (and may have no other interesting
// use)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
sizelin=length(listin)
vecout=vec2col(listin(1))
for i=2:sizelin
   vecout=[vecout ; vec2col(listin(i))]
end
vecout=gsort(vecout,'g','i')
diffvec=vecout(2:$)-vecout(1:$-1)
eqvec= (diffvec==0)
vecout(eqvec)=[]
 
endfunction
 
