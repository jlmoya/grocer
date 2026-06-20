function  [va,ve]=eigv(x)
 
// PURPOSE: mimics gauss function eigv
// ------------------------------------------------------------
// INPUT:
// * x = (N x N) matrix or K-dimensional array where the last
//   two dimensions are N x N
// ------------------------------------------------------------
// OUTPUT:
// * va = (N x 1) vector or K-dimensional array where the last
//   two dimensions are (N x 1), the eigenvalues of x.
// * ve = (N x N) vector or K-dimensional array where the last
//   two dimensions are (N x N), the eigenvectors of x.
// ------------------------------------------------------------
// NOTE:
// for arrays, the function can probably be made more
// efficient...
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
dims=size(x)
 
select size(dims,2)
 
case 2 then
   [ve,va]=spec(x)
   va=diag(va)
 
else
   ndims=size(dims,2)
   ve=x
   execstr('va=ones('+strcat(string(dims(1:ndims-1)),',')+',1)')
   str1=emptystr()
   str2=emptystr()
   str4=emptystr()
   for i=1:size(dims,'*')-2
      str1=str1+'for k'+string(i)+'=1:'+string(dims(i))+';'
      str2=str2+'k'+string(i)+','
      str4=str4+';end'
   end
   str=str1+'[vei,vai]=spec(matrix(x('+str2+':,:),dims($-1),dims($)));ve('+...
   str2+':,:)=vei;va('+str2+':)=diag(matrix(vai,dims($),dims($)));'+str4
   execstr(str)
 
end
 
endfunction
