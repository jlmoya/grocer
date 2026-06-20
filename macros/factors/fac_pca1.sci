function res = fac_pca1(x,snum,pnum,baing,meth)
 
// PURPOSE: Static factor analysis with the selection of
// the number of factors according to Bai-Ng information
// criteria
//---------------------------------------------------------
// INPUT:
// . x = a matrix of data
// . snum = a vector of factors to keep (e.g. [1,...,k])
//    or the maximum number of factor to test (here k) if the Bai-Ng
//    information criteria is used
// . pnum = number of factors to keep for the printing of
//   results
// . baing  = 'Icp1', 'ICp2', 'ICp3' or 'no' type of Bai-Ng
//   criteria to use
// . meth  = 'stan' if the user wants to perform the
//   analysis on standardized variables
//---------------------------------------------------------
// OUTPUT:
// res a tlist with:
// . res('meth') = 'static factor'
// . res('x') = matrix of data
// . res('propor') = proportion of variance explain by each
//   factor (default is the first five factors)
// . res('loadings') = matrix of loadings (variables are in
//   rows) (default is the first five factors)
// . res('corr_x_f') = matrix of correlations between
//   variables and factors (default is the first five factors)
// . res('snum') = # of kept factors
// . res('pnum') = # of kept factors for results printing
// . res('yhat') = adjusted y
// . res('resid') = residual
// . res('meth') = 'stan' if data have been standardized;
//   'no' if not
// . res('fi') = i-th factor selected by the user (or Bai-Ng
//   information criteria), that is the factor with the i-th
//  contribution to total variance; the # of factors stored
//  in the tlist is either given by the user in option
// . res('bai_ng') = 'no' or 'Icp1', 'ICp2', 'ICp3'
// . res('ICpk') = vector of information criteria if
//  'bai_ng'~= 'no'
//---------------------------------------------------------
// REFERENCES:
// . Stock, J. H. and M. Watson,"Diffusion Indexes", NBER
//   Working Paper, n�6702
// . Bai, J., and S. Ng (2002): "Determining the Number of
//   Factors in Approximate Factor Models", Econometrica,
//   70(1), 191-221.
//---------------------------------------------------------
// E. Michaux 2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
[T,n]=size(x)
 
if max(snum) > pnum
  pnum = max(snum)
end
 
meanx=mean0(x,'r').*. ones(T,1)
sigx=1;
xnew=x-meanx
mat = xnew'*xnew/T
if part(meth,1:4) == 'stan' then
   sigx=sqrt(diag(mat))' .*. ones(T,1)
   xnew=xnew./sigx
   mat = var2cor(mat)
end
 
[gam,eigen] = spec(mat) // computes eigenvalues & eigenvectors of the correlation/covariance matrix
eigen =diag(eigen)
 
[eigen,k]=gsort(eigen) // sort in decreasing order
loadings=real(gam(:,k))
fac=xnew*loadings  // compute factors
vfac=diag(fac'*fac/T)
// normalize the factors and loadings
fac=fac ./ (ones(T,1) .*. sqrt(vfac)')
loadings=loadings .* (ones(n,1) .*. sqrt(vfac)')
 
propor = eigen/sum(eigen) 				// proportion of variance explained by each factor
corrxf = loadings .* (ones(1,n) .*. sqrt(1 ./ diag(mat)) ) // correlation between variables and factors
 
// Bai-Ng information criteria
IC=[]
if baing~='no' then
   eps=xnew'-loadings(:,1:max(snum))*fac(:,1:max(snum))'
   Veps=(1/(T*n))*sum(eps.^2)
   for k =1:max(snum)
      select baing
      case 'ICp1' then
         pen=k*((n+T)/(n*T))*log(n*T/(n+T))
      case 'ICp2' then
         pen=k*((n+T)/(n*T))*log(min(n,T))
      case 'ICp3' then
         pen=k*log(min(n,T))/min(n,T)
      else
         error('desired information criteria dones''t exist')
      end
      ICk=log(Veps)+pen
      IC=[IC;ICk]
   end
   [mn,mk]=min(IC)
   snum = 1:mk
end
 
fac = fac(:,snum) // bai-ng or user desired factor
loadings=loadings(:,snum)
propor = propor(1:pnum)
corrxf = real(corrxf(:,1:pnum))
 
for i=1:max(size(snum))
   s = snum(i)
   ncorrneg=sum(corrxf(:,s)<0)
   if ncorrneg > n/2 then
      // reverse the factor
      fac(:,i)=-fac(:,i)
      loadings(:,i)=-loadings(:,i)
      corrxf(:,i)=-corrxf(:,i)
   end
end
 
// rescale fitted values
yhat=(fac*loadings').*sigx+meanx
resid=x-yhat
 
// full-in results tlist
res = tlist(['results';'meth';'x';'propor';'loadings';'corr_x_f';...
     'snum';'pnum';'bai_ng';'factors';'yhat';'resid';'stan'],...
	  	'pca factor',x,propor,loadings,corrxf,snum,pnum,[],fac,yhat,resid,meth)
 
for i = 1:length(snum)
	 execstr('res(1)($+1) = ''f'+string(snum(i))+''' ')
	 execstr('res(''f'+string(snum(i))+''') = fac(:,'+string(i)+')')
end
 
if baing == 'no' then
  res('bai_ng') = 'no'
else
  res('bai_ng') = baing
  res(1)($+1) = 'ICpk'
  res('ICpk') =  ICk
end
 
endfunction
 
