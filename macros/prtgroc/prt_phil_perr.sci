function []=prt_phil_perr(res,out)
 
// PURPOSE: prints the results of an ols, white, lad,
// Newey-West''s HAC', 'olst', 'ridge' regression on
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
 
crit1=[res('cv_rho_1%') res('cv_rho_5%') res('cv_rho_10%') ]
testv1=res('rho')-crit1
test0='a unit root'
write(out,' ')
write(out,meth+' unit root test for variable: '+res('namey'))
select res('p')
case 0 then
   write(out,'with a constant term')
else
   write(out,'with a time term of order '+string(res('p')))
end
if prests then
   ch='and estimation period: '
   for i=1:size(boundsvarb,1)/2
      ch=ch+boundsvarb(2*i-1)+'-'+boundsvarb(2*i)+'  '
   end
   write(out,ch)
end
mat2print =['1% level' '5% level' '10% level' ; string(crit1)]
write(out,'rho test is equal to: '+string(res('rho')))
write(out,' ')
write(out,'this values should be compared to the following critical values:')
 
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
 
printsep(out)
 
endfunction
