function [bsdata,a] = mvblockboot(data,sb,B);
 
// PURPOSE: Compute multivariate block-bootstrap
//---------------------------------------------------
// INPUTS:
// . data 	= matrix of data
// . sb				= size ob blocks
// . B					= number of draws	
//---------------------------------------------------
// OUTPUT:
// . bsdata 	= resampled data
// . a			= corresponding columns
//---------------------------------------------------
// REFERENCES:
//	J. Berkovitz and Lutz Kilian (1996) "Recent Developments in
//		Bootstraping Time Series", Finance & Econommics Discussion Series
//		Federal Reserve Board n°45
//---------------------------------------------------
// Translated to Scilab by E. Michaux
// http://grocer.toolbox.free.fr/grocer.html
// from J. Matheron, Centre de Recherche, Banque de France
 
[t,k]=size(data);
data=[data;data(1:sb,:)];
s=ceil(t/sb);
Bs=rand(s,B);
indexes=zeros(t,B);
index=1;
 
mtlb_mode(%t)
for i=1:t
    if modulo(i,sb)==1
        indexes(i,:)=ceil(Bs(index,:)*t);
        index=index+1;
    else
        indexes(i,:)=indexes(i-1,:)+1;
    end
end
bsdata = matrix(data(indexes,:),t,k*B);
 
a = [1:k*B]';
a = matrix(a,B,k);
 
 
mtlb_mode(%f)
 
endfunction
 
