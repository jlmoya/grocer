function res = fac_pca2(x,snum,pnum,baing,meth)
 
// PURPOSE: Static factor analysis with the selection of
// the number of factors according to Bai-Ng information
// criteria
//---------------------------------------------------------
// INPUT:
// . x = a matrix of data
// . snum = 1:n with n the # of factors to keep or maximum
//    number of factors to test if one the Bai-Ng
//    information criteria is used
// . pnum = number of factors to keep for the printing of
//   results
// . baing  = 'Icp1', 'ICp2', 'ICp3' or 'no' type of Bai-Ng
//   criteria to use
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
//   Working Paper, n°6702
// . Bai, J., and S. Ng (2002): "Determining the Number of
//   Factors in Approximate Factor Models", Econometrica,
//   70(1), 191-221.
//---------------------------------------------------------
// E. Michaux 2007
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
[T,n]=size(x)
[gam,eigen] = spec(x'*x)
[eigen,k] = gsort(diag(eigen)) // sort in decreasing order
gam = gam(:,k)
loadings = sqrt(n)*gam
fac = x*loadings/sqrt(n)
propor = eigen/sum(eigen) 				// proportion of variance explain by each factor
 
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
 
loadings= loadings(:,snum)
fac = fac(:,snum) // bai-ng or user desired factor
propor = propor(1:pnum)
 
for i=1:snum($)
   nloadneg=sum(loadings<0)
   if nloadneg > n/2 then
      // reverse the factor
      fac(:,i)=-fac(:,i)
      loadings(:,i)=-loadings(:,i)
   end
end
 
yhat=fac*loadings'
resid=x-yhat
 
// full-in results tlist
res = tlist(['results';'meth';'x';'propor';'loadings';...
     'snum';'pnum';'bai_ng';'yhat';'resid'],...
	  	'pca factor',x,propor,loadings,snum,pnum,[],yhat,resid)
 
for i = 1:length(snum)
	 execstr('res(1)($+1) = ''f'+string(snum(i))+''' ')
	 execstr('res(''f'+string(snum(i))+''') = fac(:,'+string(i)+')')
end
 
endfunction
