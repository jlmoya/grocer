function prt_varwithfac(res,out)
 
// PURPOSE: prints the results of dynamic factor estimation
// provided by the Kalman filter
// ------------------------------------------------------------
// INPUT:
// * res = the results typed list of a dynamic factor estimation
//   provided by the Kalman filter
// * out = the symobolic name of the file where the
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
 
write(out,' ')
if res('prests') then
   boundsvar=res('bounds')
   ch='estimation period: '
   for j=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*j-1)+'-'+boundsvar(2*j)
   end
   write(out,ch)
   dashes=strcat('-'+emptystr(1,length(ch)))
   write(out,dashes)
end
 
write(out,' ')
write(out,'log-likelihood: '+string(res('llike')))
write(out,'AIC criterium: '+string(res('AIC')))
write(out,'BIC criterium: '+string(res('BIC')))
 
write(out,' ')
write(out,'coefficients of the VAR')
write(out,'-----------------------')
write(out,' ')
 
prt_varcoeff(res,out)
prt_faccoeff(res,out)
printsep(out)
 
endfunction
 
