function y = strput(substring,str,offset)
 
// PURPOSE: mimics gauss function strput: Lays a substring
// over a string
// ------------------------------------------------------------
// INPUT:
// * substring = string, the substring to be laid over the
//   other string
// * str = string, the string to receive the substring
// * offset = scalar, the offset in str to place substr. The
//   offset of the first byte is 1
// ------------------------------------------------------------
// OUTPUT:
// * y scalar containing the index of the first occurrence of
//   what, within where, which is greater than or equal to
//   start. If no occurrence is found, it will be 0.
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
if offset > length(str)+1 then
    error('Offset past end of string')
end
 
y=part(str,1:offset-1)+substring
 
endfunction
 
