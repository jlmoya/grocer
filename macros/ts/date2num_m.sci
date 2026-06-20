function num=date2num_m(dat,varargin)
 
// PURPOSE: retrieve from a matrix of dates in string format
// their numerical representation
// ------------------------------------------------------------
// INPUT:
// dat = a matrix of dates strings
// ------------------------------------------------------------
// OUTPUT:
// num = the numerical representation of the dates
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002-2005
// http://grocer.toolbox.free.fr/grocer.html
 
[m,n]=size(dat)
num=ones(m,n)
for i=1:m
   for j=1:n
      num(i,j)=date2num(dat(i,j),varargin(:))
   end
end
 
endfunction
