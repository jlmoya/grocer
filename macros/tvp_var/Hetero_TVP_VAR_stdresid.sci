function Hetero_TVP_VAR_stdresid(res_TVP,resid,pvalue,plt)
 
// PURPOSE: plots the time-varying standard deviations of
// residuals from a TVP VAR estimation
// ------------------------------------------------------------
// INPUT:
// * res_TVP = a 'heteroskedastic tvp var' result tlist
//   produced by a call to Hetero_TVP_VAR
// * resid = a vector of integers, collecting the indexes of
//   the residuals whose standard deviations the user wants to
//   graph
// * pvalue = a real between 0 and 1, the p-value of the
//   confidence band (1 minus the probability that the standard
//   deviation lies in the confidence band)
// ------------------------------------------------------------
// OUTPUT:
// nothing: results are graphed on graphic windows
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
 
 
nresid=size(resid,'*')
nobs=res_TVP('nobs')
sigt=[]
sigt_low=zeros(nobs,nresid)
sigt_med=sigt_low
sigt_up=sigt_low
 
db_sigt=res_TVP('.dat Sigmat')
k=0
for j=resid
   k=k+1
   sigt=[]
   for db=1:size(db_sigt,1)
      load(db_sigt(db))
      sigt=[sigt squeeze(Sigmat(:,j,:))]
   end
   ndraws=size(sigt,2)
   for i=1:nobs
      sigt(i,:)=gsort(sigt(i,:),'g','i')
      sigt_low(i,k)=sigt(i,floor(pvalue/2*ndraws))
      sigt_mean(i,k)=mean(sigt(i,:))
      sigt_up(i,k)=sigt(i,floor((1-pvalue/2)*ndraws))
   end
   if res_TVP('prests') then
      boundsvar=res_TVP('bounds')
      [b0,fq]=date2num_fq(boundsvar(1))
      b1=date2num(boundsvar(2))
      vec_bounds=b0:b1
      for m=2:size(boundsvar,1)/2
          vec_bounds=[vec_bounds , date2num(boundsvar(2*m-1)):date2num(boundsvar(2*m))]
      end
      scale=string(num2date(vec_bounds',fq))
   else
      scale=[1:nobs]'
   end
   pltseries0([ sigt_mean(:,k) sigt_low(:,k) sigt_up(:,k)],[],...
                    'standard deviation of the residuals of the '+res('namey')(j)+' equation',...
                    scale,k,'leg=mean;'+string(100*(1-pvalue))+'% confidence band','styleg=6','color=[1 2 2]','style=[1 2 2]')
end
 
endfunction
