function prtms(r,out);
 
// PURPOSE: print a MS-VAR set of parameters in a readable form
// ------------------------------------------------------------
// INPUT:
// * r = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Adapted to Scilab by Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// from Gauss library MSVarlib 2.0
// Copyright (C) 2004 by Benoit BELLONE.
// http://bellone.ensae.net
// All rights reserved
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   out=%io(2)
end
 
meth=r('meth')
namex_id=r('namex_id')
namey=r('namey')
beta_id=r('beta_id')
beta_id_tstat=r('beta_id_tstat')
beta_id_p=r('beta_id_pvalue')
sigma=r('sigma')
n_x=r('n_x')
n_z=0
 
 
ptrans=r('ptrans')
K=r('nendo')
M=r('nb_states')
ptrans=r('ptrans')
ptrans_tstat=r('ptrans_tstat')
ptrans_pvalue=r('ptrans_pvalue')
nvar=size(r('coeff'),1)
 
write(out,meth+" estimation results")
write(out," ")
if r('prests') then
   ch='estimation period: '
   boundsvar=r('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
   write(out,ch)
end
write(out,'number of observations: '+string(r('nobs')))
write(out,'number of variables: '+string(nvar))
 
write(out,"Log likelihood: "+string(r('llike')))
write(out,"AIC: "+string(r('aic')))
write(out,"BIC: "+string(r('bic')))
write(out,"Hannan Quinn"+string(r('hq')))
 
write(out,"Degree of freedom: "+string(r('dll')));
write(out,' ')
write(out,' ')
 
write(out,"=================Matrix of markovian transition probabilities P[i,j]: ==================");
write(out,"=================                [tstat - p-value]                    =================");
write(out,' ')
mat2print=emptystr(M*3,M+1)
mat2print(3*[1:M]-2,2:M+1)=string(ptrans)
mat2print(3*[1:M]-1,2:M+1)='['+string(round(ptrans_tstat*100)/100)+' - '+string(ptrans_pvalue)+']'
 
printmat(mat2print,out)
write(out,' ')
write(out,"================= Ergodic probabilities :=================")
write(out,' ')
printmat(string(r('prob_st')),out)
write(out,' ')
write(out,"================= Coefficients ")
write(out,' ')
 
labels=['exogenous' 'coeff' 't-statistic' 'p value' ; emptystr(1,4)+' ']
 
if ~isempty(r('namex_co')) then
   namex_co=r('namex_co')
   beta_co=r('beta_co')
   beta_co_tstat=r('beta_co_tstat')
   beta_co_p=r('beta_co_pvalue')
   n_z=r('n_z')
 
   write(out,"============== All Regimes =============")
   write(out," ")
   n0=0
   mat2print=[]
   for i=1:K
      nz_i=n_z(i)
      if nz_i ~= 0 then
         mat2print=[mat2print ; '*** for endogenous: '+namey(i)+' ***' '' '' '' ;...
                labels; namex_co(n0+1:n0+nz_i) ...
                string(beta_co(n0+1:n0+nz_i)) ...
                string(beta_co_tstat(n0+1:n0+nz_i)) ...
                string(beta_co_p(n0+1:n0+nz_i)) ; emptystr(1,4)+' ']
         n0=n0+nz_i
      end
   end
   printmat(mat2print,out)
end
 
for j=1:M
   n0=0
   if sum(n_x) ~= 0 then
      write(out,"============== Regime "+string(j)+" =============")
      write(out,' ')
      mat2print=[]
      for i=1:K
         nx_i=n_x(i)
         mat2print=[mat2print ; '*** for endogenous: '+namey(i)+' ***' '' '' '' ;...
                    labels; namex_id(n0+1:n0+nx_i,1) ...
                    string(beta_id(n0+1:n0+nx_i,j)) ...
                    string(beta_id_tstat(n0+1:n0+nx_i,j)) ...
                    string(beta_id_p(n0+1:n0+nx_i,j)) ; emptystr(1,4)+' ']
         n0=n0+nx_i
      end
   end
   printmat(mat2print,out)
 
   ns=size(sigma,1)
   if r('switching V') ~= 1 then
      write(out,' ')
 
      write(out,"Variance-covariance matrix of residuals")
      write(out,"           [tstat - p-value]           ");
      mat2print=emptystr(K*3,K+1)
      mat2print(3*[1:K]-1,2:K+1)=string(r('sigma')(:,K*(j-1)+1:K*j))
      mat2print(3*[1:K],2:K+1)='['+string(round(r('sigma_tstat')(:,K*(j-1)+1:K*j)*100)/100)+' - '+string(r('sigma_pvalue')(:,K*(j-1)+1:K*j))+']'
 
      if K==1 then
         mat2print=[emptystr(3,1)+'          ' mat2print]
      end
 
      printmat(mat2print,out)
   end
   write(out,' ')
   write(out,' ')
end
 
if  r('switching V') == 1 then
   write(out,' ')
 
   write(out,"============== Variance-covariance matrix of residuals for all regimes ============== ")
   write(out,"==============                  [tstat - p-value]                      ==============");
   write(out,' ')
   mat2print=emptystr(K*3,K+1)
   mat2print(3*[1:K]-2,2:K+1)=string(r('sigma'))
   mat2print(3*[1:K]-1,2:K+1)='['+string(round(r('sigma_tstat')*100)/100)+' - '+string(r('sigma_pvalue'))+']'
 
  if K==1 then
      mat2print=[emptystr(3,1)+'          ' mat2print]
   end
 
   printmat(mat2print,out)
end
 
endfunction
 
