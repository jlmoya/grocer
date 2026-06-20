function rba = banerji0(y,lead)
 
// PURPOSE: Randomization test to evaluate the leading profile of a
// series against another one
// Test the null H0 : leads not significant
//-------------------------------------------------------------------
// INPUT:
// . y    = a vector of difference in timing turns
// . lead = number of leads to test (default is 4)
//-------------------------------------------------------------------
// OUTPUT:
// rba a tlist results
// . rbar('signi')   = confidence for rejection of the null
//   hypothesis of lead not significant
// . rbar('sum_ini') = initial sum of time difference
// . rbar('lead')    = number of tested leads (default is 4))
//-------------------------------------------------------------------
// REFERENCE:
// A. Banerji (1999),"The lead profile and other non-parametric tools
//	to evaluate survey series as leading indicators" , 24e CIRET
//      Conference
//-------------------------------------------------------------------
//
// Copyright E. Michaux (2004)
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   lead = 3
else
   lead = lead-1
end
 
dim = size(y,1)
if dim > 1 then
   y = y'
end
n = size(y,2)
 
// creates tree
rtree= tree(n)
[i,j] = find(rtree==0)
for k =1:length(i)
   rtree(i(k),j(k)) = -1
end
 
signi=zeros(lead+1,1)
sini =zeros(lead+1,1)
 
for i =0:lead
   xlead = y - i
   x = gsort(xlead)
   x = x.*bool2s(x > 0) -x.*bool2s(x < 0)
 
   res = rtree*x'
 
   sini(i+1) = sum(xlead)
   R = sum(bool2s(res >= sini(i+1)))
   signi(i+1) = 100*(1-R/(2^n))
 
end
 
rba= tlist(['results';'meth';'signi';'sum_ini';'lead'],'Banerji test',signi,sini,lead)
endfunction
