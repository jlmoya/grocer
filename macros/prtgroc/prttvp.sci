function []=prttvp(res,out)
 
// PURPOSE: prints the results of a time-varying regression on
// the file out
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
tvpmeth=res('tvpmeth')
namex=res('namex')
nobs=res('nobs')
nvar=res('nvar')
write(out,' ')
write(out,res('meth')+' estimation results for dependent     variable: '+res('namey'))
if res('prests') then
   ch='estimation period: '
   boundsvar=res('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
   write(out,ch)
end
 
write(out,'number of observations: '+string(nobs))
write(out,'number of variables: '+string(nvar))
write(out,'log-likelihood: '+string(res('like')))
write(out,[' '])
 
if tvpmeth == '2' | tvpmeth == '2a' then
   write(out,'estimation of initial parameters')
   mat2print=['variable' 'coefficient' 't-statistic' 'p value']
   d=string(res('priorb0'))
   t=res('tpriorb0')
   for i=1:nvar
      p=string((1-cdfnor("PQ",abs(t(i)),0,1))*2)
      mat2print=[mat2print ; namex(i) ...
      d(i) string(t(i)) p]
   end
   printmat(mat2print,out)
end
 
write(out,[' '])
write(out,'variances of the observation equation: '+string(res('R')))
write(out,'(t-stat)                             : ('+string(res('tR'))+')')
write(out,[' '])
write(out,'variances of the state equation: ')
 
if tvpmeth == '1' | tvpmeth == '2' then
   mat2print=['variable' 'variance' 't-statistic' 'p value']
   d=string(diag(res('Q')))
   t=diag(res('tQ'))
   for i=1:nvar
      p=string((1-cdfnor("PQ",abs(t(i,i)),0,1))*2)
      mat2print=[mat2print ; namex(i) ...
      d(i) string(t(i,i)) p]
   end
else
   mat2print=['variable\variable' namex']
   for i=1:nvar
      mat2print=[mat2print ; namex(i) string(res('Q')(i,:)) ;
                 ' ' '('+string(res('tQ')(i,:))+')' ;
                 ' ' ' '+emptystr(1,nvar)]
   end
end
 
printmat(mat2print,out)
 
write(out,' ')
if tvpmeth == '1a' | tvpmeth == '2a' then
   write(out,'(t-stat between parentheses)')
end
 
if res('prests') then
   d=[]
   b=res('bounds')
   for j=1:size(res('bounds'),1)/2
       d=[d ; num2date([date2num(b(2*j-1)):date2num(b(2*j))]',date2fq(b(1))) ]
   end
else
   d=[1:res('nobs')]'
end
 
write(out,' ')
write(out,'variable coefficients')
for j=1:ceil(nvar/4)
   mat2print=[' ' namex(4*j-3:min(4*j,nvar))' ; ...
      string(d) string(res('betas')(:,4*j-3:min(4*j,nvar)))]
   printmat(mat2print,out)
   printsep(out)
end
 
 
endfunction
