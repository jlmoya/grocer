function [res]=est_BB(res,mat_cal,puis,nbqua,nblatent,nbstates,nojump,initparam,indrows,grocer_opt_optim,grocer_hdelta)
 
// PURPOSE: estimation of the standard hmm model on qualitative
// variables
// ------------------------------------------------------------
// INPUT:
// * res = a result tlist
// * mat_cal = a (T x k) data matrix
// * puis = a (k x 1) vector, the interval between non NA values
//   for each coded variable
// * nbqua = a (2 x 1) vector:
//           - nbqua(1) = # of quantiles used to divide the data
//           - nbqua(2) = useless (for the moment...)
// * nblatent = # of latent variables (1 or 2)
// * nbstates = # of latent states (if # of sates is 1)
// * nojump = a boolean indicating whether the latent state is
//            prevented from jumping from a state to non
//            adjacent states
// * initparam =
//   - 0 for the standard intial parameters
//   - 1 for a variant
//   - a (nvar x 1) vector of intial aprameters given by the
//     user
// * indrows = a (N x 1) vector of non NA indexes
// ------------------------------------------------------------
// OUTPUT:
// * res = a results tlist with:
//   - res('meth') = 'ms turning point'
//   - res('y') = original data
//   - res('nobs') = # of observations
//   - res('nvar') = # of variables
//   - res('coded y') = data transformed by the coding
//   - res('nb quantiles') = # of quantiles used by the coding
//    (if the kernel method has been used)
//   - res('nb latent') = # of latent state variable
//   - res('nb states') = # of states
//   - res('nojump') = a boolean indicating whether the latent
//     state is allowed to jump from a state to another non
//     contiguous one
//   - res('param') = vector of estimated parameters
//   - res('std') = vector of associated standard errors
//   - res('tstat') = vector of associated Steudent stats
//   - res('llike') = log-likelihood
//   - res('grad') = gradient at the solution
//   - res('transition probabilities') = matrix of transition
//     probabilities (if there is only 1 state latent variable)
//   - res('conditional probabilities') = matrix of conditional
//     probabilities (if there is only 1 state latent variable)
//   - res('filtered probabilities') = matrix of filtered state
//     probabilities
//   - res('smoothed probabilities') = matrix of smoothed state
//     probabilities
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adapted from a Gauss programm by J. Bardaji
// and F. Tallet
 
 
// Starting values
nvar=res('nvar')
var_inno=0
 
eps=0.001
 
select initparam
case 0 then
   if nojump then
      paramini=[(0.5*(1+2*eps)-eps)/(1-0.5*(1+2*eps)+eps) ;...
      (0.33*(1+3*eps)-eps)/(1-0.66*(1+3*eps)+2*eps)*ones(nbstates-2,1);...
      (0.33*(1+3*eps)-eps)/(1-0.66*(1+3*eps)+2*eps)*ones(nbstates-2,1);
      (0.5*(1+2*eps)-eps)/(1-0.5*(1+2*eps)+eps) ]
 
   else
      aux1=(0.1*(1+nbstates*eps)-eps)*ones(nbstates-1,nbstates)
      for i=1:nbstates-1
         aux1(i,i)=(1-0.1*(nbstates-1))*(1+nbstates*eps)-eps
      end
      PZ0=aux1 .* (1 ./(1- sum(aux1,'r')).*. ones(nbstates-1,1))
      paramini=matrix(PZ0,-1,1)
 
   end
 
   aux2=(0.1*(1+nbqua(1)*eps)-eps)*ones(nbqua(1)-1,nbstates)
   for i=1:nbqua(1)-1
      aux2(i,i)=(1-0.1*(nbqua(1)-1))*(1+nbqua(1)*eps)-eps
    end
   PX_c=aux2 .* (1 ./ (1- sum(aux2,'r')) .*. ones(nbqua(1)-1,1))
 
   paramini=[paramini; matrix(ones(nvar,1) .*. PX_c,nvar*nbstates*(nbqua(1)-1),1)];
 
   if var_inno==1 then
      paramini=[paramini;0*ones(nvar+1,1);0*ones(nvar+1,1)]
   end
else
   paramini=initparam
end
 
[PZ_ini,PX_cond_ini]=Write_matrices_1latent(paramini);
 
write(%io(2),'      Entry parameters:','(a)')
disp(paramini')
write(%io(2),' ','(a)')
write(%io(2),'      Transition matrix P(Zt;Zt-1) : ','(a)')
disp(PZ_ini)
write(%io(2),' ','(a)')
 
write(%io(2),'      Conditional observation matrix P(Xq=i;Zt=j) : ','(a)')
disp(PX_cond_ini)
write(%io(2),' ','(a)')
write(%io(2),' ','(a)')
 
nbparam=size(paramini,1)
 
if isempty(grocer_opt_optim('optim ineq')) then
   grocer_opt_optim('optim ineq')=',''b'',zeros(nbparam,1),%inf*ones(nbparam,1),'
end
execstr('[minusllike,paramfin,grad]=optim(ms_quali_fcn2min'+...
grocer_opt_optim('optim ineq')+'paramini'+grocer_opt_optim('optim')+')')
 
[PZ_tran,PX_cond]=Write_matrices_1latent(paramfin);
 
[P_smoothed,P_filtered]=ms_quali_smooth(mat_cal,paramfin)
 
param=paramfin
Write_matrices=Write_matrices_1latent0
if nojump then
   param(1:nbstates-1)=diag(PZ_tran(1:nbstates-1,1:nbstates-1))
   for i=2:nbstates-1
      param(nbstates+i-2)=PZ_tran(i-1,i)
   end
   endPZ=2*nbstates-2
   param(endPZ)=PZ_tran(nbstates-1,nbstates)
 
else
   aux=PZ_tran(1:nbstates-1,:)
   param(1:nbstates*(nbstates-1))=aux(:)
   endPZ=nbstates*(nbstates-1)
end
 
aux=PX_cond
aux(nbqua(1)*[1:nvar],:)=[]
param(endPZ+1:$)=aux(:)
paramlow=[eps/(1+nbstates*eps)*ones(endPZ,1);eps/(1+nbqua(1)*eps)*ones((nbqua(1)-1)*nvar*nbstates,1)]
paramhigh=[(1+eps)/(1+nbstates*eps)*ones(endPZ,1);(1+eps)/(1+nbqua(1)*eps)*ones((nbqua(1)-1)*nvar*nbstates,1)]
param_c=find(param-sqrt(%eps)-paramlow <0 | param+sqrt(%eps)-paramhigh > 0)
 
[std,var]=se_param(param,param_c,nvar,grocer_hdelta)
 
res('param')=param
res('std')=std
res('llike')=-minusllike
res('grad')=-grad
res('transition probabilities')=PZ_tran
res('conditional probabilities')=PX_cond
fp=res('filtered probabilities')
fp(indrows,:)=P_filtered'
res('filtered probabilities')=fp
sp=res('smoothed probabilities')
sp(indrows,:)=P_smoothed'
res('smoothed probabilities')=sp
ind=floor(nbstates/2)
fi=res('filtered indicator')
fi(indrows)=(sum(P_filtered(nbstates-ind+1:nbstates,:),'r')-sum(P_filtered(1:ind,:),'r'))'
res('filtered indicator')=fi
si=res('smoothed indicator')
si(indrows)=(sum(P_filtered(nbstates-ind+1:nbstates,:),'r')-sum(P_filtered(1:ind,:),'r'))'
res('smoothed indicator')=si
 
for i=1:size(param_c,2)
   j=param_c(i)
   n=size(var,1)
   var=[var(1:j-1,1:j-1) zeros(j-1,1) var(1:j-1,j:n) ;
   zeros(1,n+1) ; var(j:n,1:j-1) zeros(n-j+1,1) var(j:n,j:n)]
end
 
if nojump then
   PZ_std=diag(std(1:nbstates))
   PZ_std(2,1)=PZ_std(1,1)
   for i=2:nbstates-1
      PZ_std(i-1,i)=std(nbstates+i-1)
      PZ_std(i+1,i)=sqrt(PZ_std(i,i)^2+PZ_std(i-1,i)^2+2*var(i,nbstates+i-1))
   end
   PZ_std(nbstates-1,nbstates)=PZ_std(nbstates,nbstates)
   indvect=2*nbstates-2
 
else
 
   PZ_std=%nan*zeros(nbstates,nbstates);
   PZ_std(1:nbstates-1,1:nbstates)=matrix(std(1:nbstates*(nbstates-1)),nbstates-1,nbstates)
   indvect=nbstates*(nbstates-1)
   for i=1:nbstates
      v=var((nbstates-1)*(i-1)+[1:nbstates-1],(nbstates-1)*(i-1)+[1:nbstates-1])
      PZ_std(nbstates,i)=sqrt(sum(v))
   end
   PZ_std(PZ_std == 0) = %nan
end
 
res('PZ_std')=PZ_std
vect=matrix(std(indvect+1:$),nvar*(nbqua(1)-1),nbstates)
indv=1:nbqua(1)*nvar
indv(nbqua(1)*[1:nvar])=[]
 
PX_cond_std=PX_cond*0
PX_cond_std(indv,:)=vect
for i=1:nvar
   for j=1:nbstates
      if PX_cond(i*nbqua(1),j)-sqrt(%eps)-paramlow(1) <0 | PX_cond(i*nbqua(1),j)+sqrt(%eps)-paramhigh(1) > 0 then
         PX_cond_std(i*nbqua(1),j)=%nan
      else
         v=var(indvect+(j-1)*(nbqua(1)-1)*nvar+(i-1)*(nbqua(1)-1)+[1:nbqua(1)-1],...
         indvect+(j-1)*(nbqua(1)-1)*nvar+(i-1)*(nbqua(1)-1)+[1:nbqua(1)-1])
         PX_cond_std(i*nbqua(1),j)=sqrt(sum(v))
      end
   end
end
PX_cond_std(PX_cond_std == 0) = %nan
res('PX_cond_std')=PX_cond_std
 
 
endfunction
 
