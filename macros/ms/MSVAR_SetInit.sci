function param = MSVAR_SetInit(y_mat,x_mat,z_mat,nx,nz,T,M,var_opt,M_V,typmod,apriori,init_beta_id,init_beta_co,init_prob,init_var);
 
// PURPOSE: initialize a  choosen MS model following a typmod
// specification
// ------------------------------------------------------------
// INPUT:
// * ymat= (T x K) matrix of endogenous variables
// * xmat= (T x nx) matrix of non switching exogenous variables
// * zmat= (T x nz) matrix of switching exogenous variables
// * M = a scalar equal to the # of states
// * var_opt = a scalar equal to the type of the variance of
//   residuals
// * M_V = a scalar indicating whether the variance switches or
//   not
// * typmod = a scalar equal to the type of the model
// * apriori = a (T x 1) vector equal to an a priori datation
//   of the states
// ------------------------------------------------------------
// OUTPUT:
// * param = a (np x 1) vector of parameters
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
probs=zeros(T,M)
 
if ~isnan(apriori) then
   P=unique(grocer_MS_refdate)
   if size(P,'*') ~= M then
      error('a priori datation should have '+string(M)+' number of regimes')
   end
   for i=1:M
      probs(:,i)=bool2s(grocer_MS_refdate == P(i))
   end
 
else
   // estimate the model ignoring the regimes
   beta0=ols0(y_mat,[x_mat z_mat])
   resid=matrix(y_mat-[x_mat z_mat]*beta0,T,grocer_MS_K)
   ser=sqrt(diag(resid'*resid) ./ (T-nx-nz))
   for i=1:grocer_MS_K
      [junk,ind_res]=gsort(resid(:,i),'g','i')
 
      ind_1=round(0.5/M*T)
      for j=1:ind_1
         indn=ind_res(j)
         probs(indn,1)=probs(indn,1)+1
      end
      ind_2=round(1.5/M*T)
      for j=ind_1+1:ind_2
         indn=ind_res(j)
         probs(indn,1)=probs(indn,1)+1-(j-ind_1)/(ind_2-ind_1)
         probs(indn,2)=probs(indn,2)+(j-ind_1)/(ind_2-ind_1)
      end
 
      for k=2:M-1
         ind_1=ind_2+1
         ind_2=round((0.5+k)/M*T)
         for j=ind_1+1:ind_2
            indn=ind_res(j)
            probs(indn,k)=probs(indn,k)+1-(j-ind_1)/(ind_2-ind_1)
            probs(indn,k+1)=probs(indn,k+1)+(j-ind_1)/(ind_2-ind_1)
         end
      end
   end
 
   probs(:,M)=grocer_MS_K-sum(probs(:,1:M-1),'c')
   probs=probs/grocer_MS_K
end
 
sqrtprobs_col=sqrt(matrix(ones(grocer_MS_K,1) .*. probs,-1,1))
Y=(ones(M,1) .*. y_mat) .* sqrtprobs_col
sqrtprobs_X=sqrtprobs_col .*. ones(1,sum(nx)*M)
sqrtprobs_Z=sqrtprobs_col .*. ones(1,sum(nz))
X=[ [sqrtprobs_X .* (eye(M,M) .*. x_mat)] [sqrtprobs_Z .* (ones(M,1) .*. z_mat)] ]
 
beta1=ols0(Y,X)
 
if typeof(init_prob) == 'boolean' then
   PR_TR=zeros(M,M)
   for j=1:M
      for i=1:M
         PR_TR(i,j)=max(sum(probs(2:T,i).*probs(1:T-1,j))/sum(probs(1:T-1,j)),sqrt(%eps))
      end
      PR_TR(:,j)=PR_TR(:,j)/sum(PR_TR(:,j))
   end
   PR_TR=PR_TR(1:M-1,:)
else
   PR_TR=init_prob(1:M-1,:)
end
 
resid=Y-X*beta1
 
if typeof(init_beta_id) == 'boolean' then
   param=[vecr(log(PR_TR ./ (1-PR_TR))) ; beta1(1:sum(nx)*M)]
else
   param=[vecr(log(PR_TR ./ (1-PR_TR))) ; matrix(init_beta_id,-1,1)]
end
 
if M_V == 1 then
// variances do not switch
   if typeof(init_var) == 'boolean' then
      resid2=zeros(M*T,grocer_MS_K)
      for i=1:grocer_MS_K
         indexes=[T*(i-1)+1:T*i]
         for j=2:M
            indexes=[indexes , T*grocer_MS_K*(j-1)+[T*(i-1)+1:T*i]]
         end
         resid2(:,i)=resid(indexes)
      end
      var_cov=resid2'*resid2/T/M
 
      select var_opt
 
      case 1 then
      // heteroskedastik
         paramv=sqrt(diag(var_cov))
 
      case 2 then
      // homoskedastik
         paramv=sqrt(mean(diag(var_cov)))
 
      case 3 then
      // homoskedastik
         paramv=vech(var_cov^0.5)
 
      end
 
   elseif var_opt == 3 then
      paramv=vech(init_var^0.5)
 
   else
      paramv=sqrt(init_var)
 
   end
 
else
// variances switch
   paramv=[]
 
   if typeof(init_var) == 'boolean' then
      resid2=matrix(resid,T,grocer_MS_K*M)
      for i=1:M
         resid_i=resid2(:,(i-1)*grocer_MS_K+1:i*grocer_MS_K)
         var_cov_i=resid_i'*resid_i/sum(probs(:,i))
         select var_opt
 
         case 1 then
         // heteroskedastik
            paramv=[paramv ; sqrt(diag(var_cov_i))]
 
         case 2 then
         // homoskedastik
            paramv=[paramv ; sqrt(mean(diag(var_cov_i)))]
 
         case 3 then
         // unconstrained
            paramv=[paramv ; real(vech(real(var_cov_i)^0.5))]
 
         end
      end
 
   elseif var_opt == 3 then
      for i=1:M
         paramv=[paramv ; vech((init_var(:,(i-1)*grocer_MS_K+1:i*grocer_MS_K))^0.5)]
      end
 
   else
      paramv=sqrt(matrix(init_var,-1,1))
   end
 
end
 
 
if typeof(init_beta_co) == 'boolean' then
   param=[param ; paramv ; beta1(sum(nx)*M+1:$,:)]
else
   param=[param ; paramv ; matrix(init_beta_co,-1,1)]
end
 
endfunction
