function prtfac_kalm(res,out)
 
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
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin] = argn(0)
if nargin == 1 then
   out=%io(2)
end
 
H=res('H')
ARF=res('ARF')
MAF=res('MAF')
stdARF=res('stdARF')
stdMAF=res('stdMAF')
stdH=res('stdH')
stdQ=res('stdQ')
stdR=res('stdR')
stdary=res('stdary')
 
nbfac=length(ARF)
Q=res('Q')
C=res('C')
R=res('R')
nr=size(R,1)
 
ary=res('ary')
nary=size(ary(1),'*')
for i=2:length(ary)
   nary=nary+size(ary(i),'*')
end
nphi=sum(res('p0'))+sum(res('q0'))+nary
 
namey=res('namey')
std=res('std')
tstat=res('tstat')
nvar=size(namey,1)
write(out,' ')
write(out,'log-likelihood: '+string(res('llike')))
write(out,'AIC criterium: '+string(res('aic')))
write(out,'BIC criterium: '+string(res('bic')))
 
if nbfac == 1 then
 
   narf=size(ARF(1),'*')
   write(out,' ')
   write(out,'dynamic of the factor')
   write(out,'*********************')
   write(out,' ')
   mat2print = ['Parameter' 'Estimate'  'Std. Dev.' 't-test']
   if narf ~= 0 then
      mat2print = [mat2print ; 'AR('+string(1:narf)'+')' string([ARF(1) stdARF(1) ARF(1) ./ stdARF(1)]) ]
   end
 
   nmaf=size(MAF(1),'*')
   if nmaf then
      mat2print = [mat2print ; 'MA('+string(1:nmaf)'+')' string([MAF(1) stdMAF(1) MAF(1) ./ stdMAF(1)] )]
   end
   printmat(mat2print,out)
 
   write(out,' ')
   write(out,'loadings')
   write(out,'********')
   write(out,' ')
 
   mat2print = ['variable' 'Estimate'  'Std. Dev.' 't-test' ;...
   namey string([H(:,1) stdH (H(:,1) ./ stdH)])]
   printmat(mat2print,out)
 
else
 
   nH=0
   for i=1:nbfac
      ARFi=ARF(i)
      stdARFi=stdARF(i)
      narfi=size(ARF(i),'*')
      write(out,' ')
      write(out,'dynamic of factor # '+string(i))
      write(out,'*********************')
      write(out,' ')
      mat2print = ['Parameter' 'Estimate'  'Std. Dev.' 't-test']
      if narfi ~= 0 then
         mat2print = [mat2print ; 'AR('+string(1:narfi)'+')' string([ARFi stdARFi (ARFi ./ stdARFi)]) ]
      end
 
      MAFi=MAF(i)
      stdMAFi=stdMAF(i)
      nmafi=size(MAF(i),'*')
      if nmafi then
         mat2print = [mat2print ; 'MA('+string(1:nmafi)'+')' string([MAFi stdMAFi (MAFi ./ stdMAFi )])]
      end
      printmat(mat2print,out)
 
      write(out,' ')
      write(out,'loadings for factor # '+string(i))
      write(out,'********')
      write(out,' ')
 
      mat2print = ['variable' 'Estimate'  'Std. Dev.' 't-test' ;...
      namey string([H(:,1+nH) stdH((i-1)*nbfac+[1:nvar]) (H(:,1+nH) ./ stdH((i-1)*nbfac+[1:nvar]))])]
      printmat(mat2print,out)
      nH=nH+narfi+nmafi
   end
 
 
 
end
 
write(out,' ')
write(out,'AR part of the residuals')
write(out,'************************')
write(out,' ')
 
indQ=[]
for i=1:nvar
   aryi=ary(i)
   if ~isempty(aryi) then
      indQ=[indQ ; i]
      naryi=size(aryi,1)
      write(out,'variable: '+string(namey(i)))
      mat2print = ['parameter' 'Estimate'  'Std. Dev.' 't-test' ;...
      'AR('+string(1:naryi)'+')' string([aryi stdary(i) (aryi ./ stdary(i))]) ]
      printmat(mat2print,out)
      write(out,' ')
   end
end
 
indR=1:nvar
indR(indQ)=[]
 
write(out,' ')
write(out,'variance of the residuals')
write(out,'*************************')
write(out,' ')
 
vareps=zeros(nvar,1)
stdeps=zeros(nvar,1)
vareps(indQ)=diag(Q(1+nbfac:$,1+nbfac:$))
vareps(indR)=diag(R)
stdeps(indQ)=stdQ(nbfac:$)
stdeps(indR)=stdR
tstateps=vareps ./ stdeps
 
mat2print = ['variable' 'Estimate'  'Std. Dev.' 't-test' ;...
namey string([vareps stdeps tstateps])]
printmat(mat2print,out)
 
printsep(out)
 
endfunction
 
