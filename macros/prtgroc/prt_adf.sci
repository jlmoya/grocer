function []=prt_adf(res,out)
 
// PURPOSE: prints the results of an adf regression on
// the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list from an olsmod regression
// * out = the symbolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUTPUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
meth=res('meth')
nvar=res('nvar')
 
crit1=[res('1% level') res('5% level') res('10% level') ]
testv1=res('tstat')(1)-crit1
test0='a unit root'
prt_ols(res,out)
write(out,' ')
write(out,'............................................')
matspec(1)='(*) t-value for variable '+res('namex')(1)+...
       ' should be compared to the following values:'
write(out,matspec)
mat2print =['1% level' '5% level' '10% level' ; string(round(crit1*1000)/1000)]
 
printmat(mat2print,out)
write(out,' ')
 
if testv1(1) < 0 then
   write(out,'conclusion: the null hypothesis of '+test0+' is rejected even at a 1% level')
elseif testv1(2) < 0 then
   write(out,'conclusion: the null hypothesis of '+test0+' is accepted at a 1% level, but rejected at a 5% level')
elseif testv1(3) < 0 then
   write(out,'conclusion: the null hypothesis of '+test0+' is accepted at a 5% level, but rejected at a 10% level')
else
   write(out,'conclusion: the null hypothesis of '+test0+' is accepted even at a 10% level')
end
 
 
endfunction
