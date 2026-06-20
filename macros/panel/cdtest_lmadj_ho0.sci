function [lm,pval]=cdtest_lmadj_ho0(y,index,x)
 
// PURPOSE: Baltagi et et alii bias-adjusted LM test of
//    cross-sectional dependence in homogeneous panel data models
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
//  Baltagi B. H., Q. Feng and C. Kao (2012), "A Lagrange Multiplier
//    test for cross-sectional dependence in a fixed effects panel
//    data model", Journal of Econometrics, 170, 164–177
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
 
// transformation of all the variables used
// the variables are expressed as deviations from the individual means
// so calculate first the individual means
xm=0*x;
ym=0*y;
ntypes=ones(nindiv,1);
 
for i=1:nindiv
  id_i=find(index==uniq(i));
  ntypei=size(id_i,2);
  ntypes(i)=ntypei;
  yi=y(id_i);
  meany=mean(yi);
  ym(id_i)=meany;
  xi=x(id_i,:);
  meanxi=mean(xi,1);
  xm(id_i,:)=ones(size(id_i,2),1).*.meanxi;
end
xnew=x-xm;
ynew=y-ym;
[xpxi,xpxixp]=invxpx(xnew)
bhat=xpxixp*y
eps=ynew-xnew*bhat;
eps=matrix(eps,ntypes(1),nindiv);
 
 
lm=0;
for i=1:(nindiv-1)
  for j=(i+1):nindiv
    rho_ij=(eps(:,i)'*eps(:,j))^2/((eps(:,i)'*eps(:,i))*(eps(:,j)'*eps(:,j)));
    lm=lm+(ntypes(1)*rho_ij-1);
  end
end
lm=sqrt(1/(nindiv*(nindiv-1)))*lm-nindiv/(2*ntypes(1)-1);
pval=1-cdfnor("PQ",lm,0,1);
 
 
endfunction
