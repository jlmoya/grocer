function y = strsect(str,start,len);
 
// PURPOSE: mimics gauss function strsect: Extracts a substring
// of a string
// ------------------------------------------------------------
// INPUT:
// * str = string or scalar from which the segment is to be
//   obtained
// * sart = scalar, the index of the substring in str. The
//   index of the first character is 1
// * len = scalar, the length of the substring
// ------------------------------------------------------------
// OUTPUT:
// * y = string, the extracted substring, or a null string if
//   start is greater than the length of str
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
y = part(string(str),start+[0:len-1])
 
endfunction
 
