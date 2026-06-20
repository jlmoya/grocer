function []=prt_ers(res,out)
 
// PURPOSE: prints the results of an ers regression on
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
 
write(out,' ')
if meth ~= 'ers' then
   error('arg 1 is not an ''ers'' results tlist')
end
 
write(out,meth+' estimation results for dependent variable: '+res('namey'))
if res('trend') == 0 then
   txt='with constant'
else
   txt='with constant + trend'
end
write(out,'model '+txt)
nchars=length(meth+' estimation results for endogenous: '+res('namey'))
stars=strcat(emptystr(1,nchars)+'*')
write(out,stars)
write(out,' ')
 
prtuniv_block1(res,out)
prtuniv_R2(res,meth,nvar,out)
write(out,'standard error of the regression: '+string(res('ser')))
write(out,'sum of squared residuals: '+string(res('sigu')))
write(out,'DW(0) ='+string(res('dw')))
write(out,'Belsley, Kuh, Welsch Condition index: '+string(res('condindex')))
 
prtuniv_coeffs(res,out)
 
write(out,' ')
write(out,'............................................')
p=res('test p-value')
matspec(1)='* approximate p-value for ERS test is: '+string(p)
write(out,'* approximate p-value for ERS test is: '+string(p))
write(out,' ')
txt='conclusion: the null hypothesis of non stationarity is '
if p < 0.01 then
   write(out,txt+'rejected even at a 1% level')
elseif p < 0.05 then
   write(out,txt+'accepted at a 1% level, but rejected at a 5% level')
elseif p < 0.1 then
   write(out,txt+'accepted at a 5% level, but rejected at a 10% level')
else
   write(out,txt+'accepted at even a 10% level')
end
write(out,' ')
format(10)
 
printsep(out)
 
 
endfunction
