function prtquant(r,out)
 
// PURPOSE: prints the results of a quantile regression
// ------------------------------------------------------------
// INPUT:
// * r = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
 
write(out,'linear quantile regression estimation results');
write(out,' ')
if  r('weights') ~= 0 then
   write(out,'                     -- weighted analysis -- ');
   write(out,' ')
end;
 
n=r('nobs')
k=r('nvar')
write(out,'number of observations: '+string(n));
write(out,'number of variables: '+string(k));
write(out,' ')
 
parnm =[r('namex') ; 'constant']
omat =[ r('namex') , string(r('beta'))];
mat2prt = ['var. / tau' string(100*r('tau'))'+'%' ; ' '+emptystr(1,size(r('tau'),1)+1) ; omat];
printmat(mat2prt,out)
printsep(out)
 
endfunction
