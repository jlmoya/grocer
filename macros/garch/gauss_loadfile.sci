function mat=gauss_loadfile(filein)
 
// PURPOSE: laod an ascci file containing only numbers into a
// real vector
// ------------------------------------------------------------
// INPUT:
// * filein = an ascci file
// ------------------------------------------------------------
// OUTPUT:
// * mat = (N x 1) vector, containing the data
// ------------------------------------------------------------
// Copyright Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
fd=mopen(filein,'r')
data=mgetl(fd)
execstr('mat='+'['+data(1)+']')'
for i=2:size(data,1)
   mat=[mat ; evstr(data(i))']
end
 
endfunction
