function res=pfixed0(y,index,x,z)
 
// PURPOSE: performs Fixed Effects Estimation for Panel Data
// (for balanced or unbalanced data) using the within-groups
//     estimation procedure.
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
// * z = optional matrix of exogenous variables, dummy
//   variables.
// ------------------------------------------------------------
// OUTPUT: res a result tlist whixh arguments can be
/// * res('bhat') = beta
//  * res('iintc') = individual fixed effects
//  * res('const') = matrix of indiviual constant
//  * res('xmean') = matrix of exogeneous variables means
//  * res('ymean') = matrix of endogeneous variables means
//  * res('yhat') = estimated y
//  * res('resid') = residuals
// ------------------------------------------------------------
// Copyright: Eric Dubois (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adpated from Matlab programs
// Written by:
// Carlos Alberto Castro
// National Planning Department
// Bogota, Colombia
// Email: ccastro@dnp.gov.co
 
//****************************************************************************************
// NOTE: James P. LeSage provided corrections on the creation and use of the index
//       vector used to identify the individual's observations.
// and Eric Dubois added his own ones
//****************************************************************************************
 
[nargout,nargin]=argn(0)
if nargin < 4 then
   z=[]
end
[nobs,nz] = size(z);
[nobs,nx] = size(x);
uniq=unique(index)
 
nindiv = size(uniq,1);
nexo=nx+nindiv+nz
const=zeros(nobs,nindiv)
 
// transformation of all the variables used
// the variables are expressed as deviations from the individual means
// so calculate first the individual means
xm=0*x
zm=0*z
ym=0*y
xm0=zeros(nindiv,nx)
zm0=zeros(nindiv,nz)
ym0=zeros(nindiv,1)
ntypes=ones(nindiv,1)
 
for i = 1:nindiv
  id_i=find(index == uniq(i))
  ntypei=size(id_i,2)
  ntypes(i)=ntypei
  yi=y(id_i)
  meany=mean(yi)
  ym(id_i) = meany
  ym0(i) = meany
  xi = x(id_i,:)
  meanxi=mean(xi,1)
  xm(id_i,:) = ones(size(id_i,2),1) .*. meanxi
  xm0(i,:)=meanxi
  if nz then
     zi = z(id_i,:)
     meanzi=mean(zi,1)
     zm(id_i,:) = meanzi
     zm0(i,:)=meanzi
  end
  const(id_i,i)=1
end
 
xnew=[x-xm,z-zm]
[xpxi,xpxixp]=invxpx(xnew)
bhat=xpxixp*y
 
// individual intercepts and their variance calculated
// by the mean of the Frish-Vaugh theorem
iintc = ym0-[xm0 zm0]*bhat
 
// fited variable and errors
yhat = [x z const]*[bhat ; iintc];
resid=y-yhat;
 
res=tlist(['results';'meth';'yhat';'beta';'fixed';'resid';'ymean';'xmean';'zmean';'const'],...
'pfixed0',yhat,bhat,iintc,resid,ym,xm,zm,const)
 
endfunction
 
 
