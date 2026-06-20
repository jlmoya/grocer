function [bcpf,bctf] = enf1p(bcp,bct,x,M)
 
// PURPOSE: makes sure that a peak to peak or a trough
// to trough cycle lasts at least M periods, respectively
//----------------------------------------------------------------
// INPUTS:
// . bcp : vector of peak indexes
// . bct : vecto of trough indexes
// . x   : original time series
//----------------------------------------------------------------
// OUTPUTS:
// . bcpf : new vector of peak indexes
// . bctf : new vector of trough indexes
//----------------------------------------------------------------
//
// Translated to Scilab by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Adapted from Gauss proprams of M. Watson & D. Harding by Julien Matheron
// Banque de France, centre de recherche, Sept. 2002
 
 
if isempty(bcp)|isempty(bct) then
	 bctf = []; bcpf = [];
   return
end
 
i = 2;
while i<=size(bcp,1)
 
	if bcp(i,1)-bcp(i-1,1) < M then
		s = zeros(size(bcp,1),1);
		d1 = bcp(i-1,1);
		d2 = bcp(i,1);
		if x(d1,1) > x(d2,1) then
			s(i,1) = 1;
		else
			s(i-1,1) = 1;
		end
 
		bcp = bcp(s==0);
	end
	i=i+1;
end
[bcp,bct] = alter2(bcp,bct,x);
 
i = 2;
while i<=size(bct,1)
	if bct(i,1)-bct(i-1,1) < M then
		s = zeros(size(bct,1),1);
		d1 = bct(i-1,1);
		d2 = bct(i,1);
		if x(d1,1) < x(d2,1) then
			s(i,1) = 1;
		else
			s(i-1,1) = 1;
		end
 
		bct = bct(s==0);
	end
	i=i+1;
end
[bcpf,bctf] = alter2(bcp,bct,x);
 
 
endfunction
