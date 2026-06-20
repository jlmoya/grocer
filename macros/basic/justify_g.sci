function str=justify_g(str,leng,side)
 
// PURPOSE: add blanks to a string matrix to reach some
// predetermined length with left or right justification
// ------------------------------------------------------------
// INPUT:
// * str = a string matrix
// * leng = a scalar, the length to reach
// * side = a string, the type of justification ('l' or 'r')
// ------------------------------------------------------------
// OUTPUT:
// * str = the transformed string matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
[nrows,ncols]=size(str)
addmat=emptystr(nrows,ncols)
Lstr=length(str)
for j=1:nrows
   for k=1:ncols
       addmat(j,k)=ascii(32*ones(1,max(max(Lstr),leng)-Lstr(j,k)))
   end
end
 
if side == 'l' then
   str=str+addmat
else
   str=addmat+str
end
 
 
endfunction
