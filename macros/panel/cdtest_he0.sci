function [cdt,pval]=cdtest_he0(y,index,x)
 
// PURPOSE: Pesaran (2004) test of  cross-sectional dependence
//    in heterogeneous panel data models
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
// * cdt = test statistic
// * pval = statistic p-value
// ------------------------------------------------------------
// REFERENCE:
//  Pesaran, M. H. (2004). General diagnostic tests for cross section dependence in panels.
//      University of Cambridge, Faculty of Economics, Cambridge Working Papers in
//      Economics No. 0435.
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
    error('CD test can''t be performed on unbalanced panel database');
  end
  ni=[ni,ni0];
end
nt=nobs/nindiv;
 
eps=zeros(nt,nindiv)
for i=1:nindiv
  id_i=find(index==uniq(i));
  [xpxi,xpxixp]=invxpx(x(id_i,:));
  bhat=xpxixp*y(id_i);
  yhat=x(id_i,:)*bhat;
  eps(:,i)=y(id_i)-yhat;
end
 
rho=varcov0(eps);
rho=var2cor(rho);
cdt=sqrt(2/(nindiv*(nindiv-1)))*sum(triu(rho,1));
pval=1-cdfnor("PQ",cdt,0,1);
 
endfunction
