function []=prt_kpss(res,out)
 
// PURPOSE: prints the results of a 'kpss' regression on
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
 
crit1=[res('1% level') res('5% level') res('10% level') ]
testv1=crit1-res('test_value')
test0='stationarity'
write(out,' ')
write(out,'KPSS stationarity test for variable: '+res('namey'))
select res('p')
case 0 then
   write(out,'with a constant term')
case 1 then
   write(out,'with a time term')
end
if prests then
   ch='and estimation period: '
   for i=1:size(boundsvarb,1)/2
      ch=ch+boundsvarb(2*i-1)+'-'+boundsvarb(2*i)+'  '
   end
   write(out,ch)
end
 
write(out,'is equal to: '+string(res('test_value')))
write(out,'this values should be compared to the following critical values:')
mat2print =['1% level' '5% level' '10% level' ; string(crit1)]
printmat(mat2print,out)
 
endfunction
