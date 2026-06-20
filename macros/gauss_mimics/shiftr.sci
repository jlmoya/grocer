function [matin]=shiftr(matin,shifts,val)
 
// PURPOSE: mimics gauss shiftr function
// ------------------------------------------------------------
// INPUT:
// * matin = input (mxn) matrix
// * shifts = (mx1) or (1xm) vector of shifting values
// * val = value to fill the holes
// ------------------------------------------------------------
// OUPTUT:
// * matin = (mxn) transformed matrix
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
 
[m,n]=size(matin)
for i=1:m
   s=shifts(i)
   heart=[1+s*(s>0):n+s*(s<=0)]
   matin(i,heart)=matin(i,heart-s)
   matin(i,1:s)=val
   matin(i,n+s+1:n)=val
end
 
endfunction
 
