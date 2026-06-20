function v = stocv(s)
 
// PURPOSE: mimics gauss function stocv: converts a string to a
// character vector
// ------------------------------------------------------------
// INPUT:
// * s = string, to be converted to character vector
// ------------------------------------------------------------
// OUTPUT:
// * v = (N x 1) character vector, contains the contents of s
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
len=length(s)
nv=ceil(len/8)
nint=floor(len/8)
v=emptystr(nv,1)
for i=0:nint-1
  v(i+1)=part(s,i*8+[1:8])
end
v(nv)=part(s,8*max(nint,nv)-7:len)
 
endfunction
