function prtoutliers(nxo,xo,x,dates)
 
// PURPOSE: print outliers detection in the Bry-Boschan
// function
// ------------------------------------------------------------
// INPUTS:
// * nxo   = dates of replacement
// * xo    = serie of replaced values
// * x 	   = initial serie
// * dates = vector of dates
// ------------------------------------------------------------
// OUPUT: nothing
// ------------------------------------------------------------
// Compyright E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
out = %io(2)
write(out,'')
write(out,'Warning - outlier found')
mat2print = ['Dates' , 'Observed value' , 'Replacement value']
mat2print = [mat2print;dates(nxo) string(xo(nxo)) string(x(nxo))]
printmat(mat2print,out)
 
 
endfunction
