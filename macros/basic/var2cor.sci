function [c]=var2cor(s)
 
// PURPOSE: transform a covariance matrix in a correlation
// matrix
// ------------------------------------------------------------
// INPUT:
// s = (n x n) covariance matrix
// ------------------------------------------------------------
// OUTPUT:
// c = (n x n) correlation matrix
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
d=sqrt(diag(s))
m=d*d'
c=s./m
 
endfunction
 
