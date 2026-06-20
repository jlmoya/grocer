function str = datestr(d)
 
// PURPOSE: mimic Gauss function datestr: deletes from a matrix
// the rows deleted are those for which there is a 1 in
// the corresponding row of condition
// ------------------------------------------------------------
// INPUT:
// * d = (4 x 1) vector, like the date function returns. If
//   this is 0, the date function will be called for the
//   current system date
// ------------------------------------------------------------
// OUTPUT:
// * str = 8 character string containing current date in the
//   form: mo/dy/yr
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
 
y='0'+string(d(1))
l=length(y)
str=string(d(2))+'/'+string(d(3))+'/'+part(y,l-1:l)
 
 
endfunction
