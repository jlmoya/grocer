function y = strindx(str_where,str_what,start)
 
// PURPOSE: mimics gauss function strindx: finds the index of
// one string within another string
// ------------------------------------------------------------
// INPUT:
// * str_where = string or scalar, the data to be searched
// * str_what = string or scalar, the substring to be searched
//   for in where.
// * start scalar, the starting point of the search in where
//   for an occurrence of what. The index of the first
//   character in a string is 1.
// ------------------------------------------------------------
// OUTPUT:
// * y scalar containing the index of the first occurrence of
//   what, within where, which is greater than or equal to
//   start. If no occurrence is found, it will be 0.
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
ind0=strindex(string(str_where),str_what)
ind=find(ind0>start)
y=ind0(ind)
 
endfunction
 
