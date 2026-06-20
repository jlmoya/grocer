function vsave = bintodec(binsave,nvar)
 
// PURPOSE: convert "base 2" codes for models into bit
//-------------------------------------------------------
// INPUT:
// * binsave = vector of numbered different visited models in binary codes
// * nvar = # of exogenous variable
//-------------------------------------------------------
// RETURNS:
// * vsave = matrix
//-------------------------------------------------------
// E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
 
nbinsave = size(binsave,1)
vsave = zeros(nbinsave,nvar)
 
for i = 1:nbinsave
	
	D = binsave(i)
	divisor = 0
	
	while divisor < nvar
		R = D-2*int(D/2)
 
		vsave(i,nvar-divisor)	= R
		D = int(D/2)
		divisor = divisor+1	
	end
 
end
 
 
endfunction
