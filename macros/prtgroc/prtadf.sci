function prtadf(resadf,out)
 
// PURPOSE: prints the results of ADF test on the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
prtuniv(resadf,out)
write(out,' ')
write(out,'............................................')
write(out,'° t-value for variable '+resadf('namex')(1)+' should be compared to the following values:')
mat2print =['1% level' '5% level' '10% level' ;...
           string(resadf('1% level')) string(resadf('5% level')) string(resadf('10% level'))]
printmat(mat2print,out)
write(out,' ')
if resadf('tstat')(1) < resadf('1% level') then
   write(out,'conclusion: the null hypoyhesis of a unit root is rejected at a 1% level')
elseif resadf('tstat')(1) < resadf('5% level') then
   write(out,'conclusion: the null hypoyhesis of a unit root is accpeted at a 1% level, but rejected at a 1% level')
elseif resadf('tstat')(1) < resadf('10% level') then
   write(out,'conclusion: the null hypoyhesis of a unit root is accepted at a 5% level, but rejected at a 10% level')
else
   write(out,'conclusion: the null hypoyhesis of a unit root is accepted at a 10% level')
end
 
printsep(out)
 
 
endfunction
