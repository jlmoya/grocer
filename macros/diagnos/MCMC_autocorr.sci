function autocorr=MCMC_autocorr(data,nautocorr)
 
// PURPOSE: computes data autocorrelation at given orders
// ------------------------------------------------------------
// INPUT:
// * data = a matrix or hypermatrix, with the last dimension
//   pertaining to the draws
// * nautocor = a vector of integer, the aucorrelation orders to
//   examine
// ------------------------------------------------------------
// OUTPUT:
// autocorr = a list of n autocorrelations
// ------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
 
sizedat=size(data)
ndraws=sizedat($)
nvar=size(sizedat,2)-1
str_colons=strcat(emptystr(nvar,1)+':',',')
str_ones=strcat(emptystr(nvar,1)+'1',',')
autocorr=list()
nautcorr=vec2row(nautocorr)
 
if nvar == 2 then
   for i=nautocorr
      execstr('autocorr_i=%nan*ones('+strcat(string(sizedat(1:$-1)),',')+')')
      for j=1:sizedat(1)
      // with dims=3 the size of the matrix can be huge, which may lead to
      // summations exceeding the stack size; therefore I split the problem
      // into smaller ones, at the expense of speed
         data_j=squeeze(data(j,:,:))
         dm_bar=sum(data_j(:,i+1:ndraws),2)/(ndraws-i)
         lagdm_bar=sum(data_j(:,1:ndraws-i),2)/(ndraws-i)
 
         var_dm=sum(data_j(:,i+1:ndraws).^2,2)/(ndraws-i)-dm_bar.^2
         var_lagdm=sum(data_j(:,1:ndraws-i).^2,2)/(ndraws-i)-lagdm_bar.^2
         cov_data=sum(data_j(:,i+1:ndraws).*data_j(:,1:ndraws-i),2)/(ndraws-i)-(dm_bar .* lagdm_bar)
 
         ind_nonzero=find(var_dm ~= 0 & var_lagdm ~=0)
         autocorr_i(j,ind_nonzero)=(cov_data(ind_nonzero) ./ sqrt(var_dm(ind_nonzero).*var_lagdm(ind_nonzero)))'
      end
      autocorr($+1)=autocorr_i
   end
 
else
   for i=nautocorr
      execstr('dm_bar=sum(data('+str_colons+',i+1:ndraws),nvar+1)/(ndraws-i)')
      execstr('lagdm_bar=sum(data('+str_colons+',1:ndraws-i),nvar+1)/(ndraws-i)')
 
      execstr('var_dm=sum(data('+str_colons+',i+1:ndraws).^2,nvar+1)/(ndraws-i)-dm_bar.^2')
      execstr('var_lagdm=sum(data('+str_colons+',1:ndraws-i).^2,nvar+1)/(ndraws-i)-lagdm_bar.^2')
 
      execstr('cov_data=sum(data('+str_colons+',i+1:ndraws).*data('+str_colons+',1:ndraws-i),nvar+1)/(ndraws-i)-(dm_bar .* lagdm_bar)')
 
      ind_nonzero=find(var_dm ~= 0 & var_lagdm ~=0)
      autocorr_i(ind_nonzero)=cov_data(ind_nonzero) ./ sqrt(var_dm(ind_nonzero).*var_lagdm(ind_nonzero))
      autocorr($+1)=autocorr_i
   end
end
 
endfunction
