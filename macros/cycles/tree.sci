function rtree =tree(n)
 
// PURPOSE: compute any possible boolean for n variable
//---------------------------------------------------------
// INPUT:
// . n = the number of variables
//---------------------------------------------------------
// OUPUT:
// rtree = matrix containing all boolean
//---------------------------------------------------------
// E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Taken from J. Ph Chancelier (2004), "Scilab une introduction - Version 1.0"
 
 
rtree=ones(2^n,n)
for i=1:n
	 rtree(:,i) = ones(2^(i-1),1).*.([1;0].*.ones(2^(n-i),1))
end
 
endfunction
