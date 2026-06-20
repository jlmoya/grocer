function [irf_low,irf_upp]=irf_bs(results,mres,IRF,S,ndraws,siz)
 
// PURPOSE: Calculates standard error of Impulse Response
// Function for VAR by means of the asymptotic formula
//-------------------------------------------------------------
// REFERENCES:
// * Hamilton, Time Series Analysis (1994)
// * Mittnik and Zadrozny, Asymptotic distibutions of Impulse
// Responses, Step Respones, and Variance Decomposition of
// Estimated Linear Dhynamic Modesl, Econometricas, vol61, n°4,
// Jul. 1993
// ------------------------------------------------------------
// INPUT:
// * results = results tlist returned by VAR
// * mres = decomposition method
// * P = matrix such that P*e = u
//       where u is the residual from the VAR regression
//             e is the residual to be shocked
// * IRF = ((S+1) x T) impulse response functions
// * PHI = (N*p x T) matrix of coefficients
// * S = # of periods
// * siz = size of the confidence band
//-------------------------------------------------------------
// OUTPUT:
// * irf_low = ((S+1) x T) lower range of impulse response
//                     confidence band
// * irf_upp = ((S+1) x T) upper range of impulse response
//                     confidence band
//-------------------------------------------------------------
// Copyright Eric Dubois 2002-2013
// http://grocer.toolbox.free.fr/grocer.html
 
N=results('nobs')
yall=results('yall')
nlag=results('nlag')
neqs=results('neqs')
bet=results('beta')
resid=results('resid')
x=results('x')
nobse=N-size(x,2)
z=x(:,nlag*neqs+1:$)
IRF_draws=zeros((S+1)*neqs,neqs*(ndraws+1))
IRF_draws(:,1:neqs)=IRF
irf_low=zeros(neqs*(S+1),neqs)
irf_upp=zeros(neqs*(S+1),neqs)
low1=floor(siz/2*(ndraws+1))
low2=ceil(siz/2*(ndraws+1))
upp1=floor((1-siz/2)*(ndraws+1))
upp2=ceil((1-siz/2)*(ndraws+1))
 
ind_rand=ceil(grand(N,ndraws,'unf',0,N))
for i=1:ndraws
   u_draw=resid(ind_rand(:,i),:)
   for j=1:N
      ylag=matrix(yall(j+nlag-1:-1:j,:)',1,neqs*nlag)
      yall(j+nlag,:)=[ylag , z(j,:)]*bet+u_draw(j,:)
   end
   ylag=mlagb(yall,nlag)
   [bet_i,xpxi]=ols0(yall(nlag+1:nlag+N,:),[ylag(nlag+1:nlag+N ,:) , z])
   resid_i=yall(nlag+1:nlag+N,:)-[ylag(nlag+1:nlag+N ,:) , z]*bet_i
   sigma_i=resid_i'*resid_i/nobse
 
   select mres
   case 'chol1' then
      P_i=chol(sigma_i)';
   case 'chol2' then
      P0_i    = chol(sigma_i)'
      Dsr = diag(diag(P0_i));
      P_i = inv(Dsr)*P0_i;
   else
      P_i = eye(neqs,neqs);
   end
 
   IRF_i=irf0(bet_i,S,neqs,nlag,P_i)
   IRF_draws(:,1+i*neqs:(i+1)*neqs)=IRF_i
 
end
 
for i=1:neqs*(S+1)
   for j=1:neqs
      IRF_i_j=gsort(IRF_draws(i,j+[0:ndraws-1]*neqs),'g','i')
      irf_low(i,j)=0.5*(IRF_i_j(low1)+IRF_i_j(low2))
      irf_upp(i,j)=0.5*(IRF_i_j(upp1)+IRF_i_j(upp2))
   end
end
 
endfunction
