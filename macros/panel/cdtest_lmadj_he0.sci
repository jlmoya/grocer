function [lm,pval]=cdtest_lmadj_he0(y,index,x)
 
// PURPOSE: Pesaran et alii bias-adjusted LM test of
//    cross-sectional dependence in heterogeneous panel data models
// ------------------------------------------------------------
// INPUT:
// * y = a (nobs x neqs) matrix of all of the individual's
//   observations vertically concatenated. This matrix must
//   include in the first column the dependent variable, the
//   independent variables must follow accordingly.
// * index = index vector that identifies each observation with
//   an individual
//   e.g. 1  (first 2 observations  for individual # 1)
//        1
//        2  (next  1 observation   for individual # 2)
//        3  (next  3 observations  for individual # 3)
//        3
//        3
// * x = matrix of exogenous variables
// ------------------------------------------------------------
// OUTPUT:
// * lm = test statistic
// * pval = statistic p-value
// ------------------------------------------------------------
// REFERENCE:
//  Pesaran M. Hashem, A. Ullah, T. Yamagata (2008), "A bias-adjusted
//   LM test of error cross-section independence",
//   Econometrics Journal, 11, pp. 105-127
// ------------------------------------------------------------
// Copyright: Emmanuel Michaux (2012)
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nobs,nx]=size(x);
uniq=unique(index)
nindiv=size(uniq,1);
nexo=nx+nindiv;
 
 
ni=sum(index(index==uniq(1)))/uniq(1);
for i=2:nindiv
  ni0=sum(index(index==uniq(i)))/uniq(i);
  if or(ni~=ni0) then
    error('LM-adj CD test can''t be performed on unbalanced panel database');
  end
  ni=[ni,ni0];
end
nt=nobs/nindiv;
 
 
I=eye(nt,nt);
eps=list();
M=list();
for i=1:nindiv
  id_i=find(index==uniq(i));
  [xpxi,xpxixp]=invxpx(x(id_i,:));
  bhat=xpxixp*y(id_i);
  yhat=x(id_i,:)*bhat;
  eps($+1)=y(id_i)-yhat;
 
  m=I-x(id_i,:)*xpxixp;
  M($+1)=m;
end
 
 
df=nt-nx;
num=(df-8)*(df+2)+24;
den=(df+2)*(df-2)*(df-4);
a2=3*(num/den)^2;
a1=a2-df^(-2)
 
 
lm=0;
for i=1:(nindiv-1)
  for j=(i+1):nindiv
    rho_ij=(eps(i)'*eps(j))^2/((eps(i)'*eps(i))*(eps(j)'*eps(j)));
 
    mu_ij=trace(M(i)*M(j))/df;
    ups_it=a1*(trace(M(i)*M(j)))^2+2*trace((M(i)*M(j))^2)*a2;
 
 
    lm=lm+(df*rho_ij-mu_ij)/ups_it;
  end
end
lm=sqrt(2/(nindiv*(nindiv-1)))*lm;
pval=1-cdfnor("PQ",lm,0,1);
 
 
endfunction
