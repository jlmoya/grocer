function res=ologit1(y,x,param,optim_func,opt_optim)
 
// PURPOSE: evaluate logit log-likelihood
// ------------------------------------------------------------
// INPUT:
// * param = (k x 1) parameter vector
// * y = (n x 1) dependent variable vector taking ncat integer
//   values
// * x = (n x m) explanatory variables matrix
// ------------------------------------------------------------
// OUTPUT:
// res = a res tlist with:
// - res('meth') = 'ordered logit'
// - res('y') = (nobs x ncat) matrix of data
// - res('x') = (nobs x nx) matrix of data
// - res('nobs') = number of observations
// - res('nvar') = number of variables
// - res('ncat') = number of categories of dependent variable
//                       (including the reference category j = 0)
// - res('beta') = (nvar*ncat x 1) vector of beta coefficients:
//                      [beta_1 ; beta_2 ; ... ; beta_ncat] under
//                      normalization beta_0 = 0
// - res('yhat') = (nobs x ncat) matrix of fitted values
//                       probabilities: [P_0 P_1 ... P_(ncat-1)]
//                       where P_j = [P_1j ; P_2j ; ... ; P_nobsj]
// - res('r2mf') = McFadden pseudo-R^2
// - res('rsqr') = Estrella pseudo-R^2
// - res('llike') = unrestricted log likelihood
// - res('grad') = gradient vector at solution
// - res('lratio') = LR test statistic against intercept-only model (all
//                       bets=0), distributed chi-squared with (nvar-1)*ncat
//                       degrees of freedom
// - res('covb') = (nvar*ncat x nvar*ncat) covariance matrix
//                       of coefficients
// - res('tstat') = (nvar*ncat x 1) vector of t-statistics
// - res('pvalue') = (nvar*ncat x 1) vector of corresponding p-values
//-----------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
 
deff('[f,g,ind]=grocer_ologit(theta,ind,y,x)',...
['[f0,g0]=ologit_like(theta,y,x)';'f=-f0';'g=-g0'])
deff('[f]=grocer_ologit0(theta,y,x)',...
['f=-ologit_like0(theta,y,x)'])
 
select optim_func
case 'optim' then
   execstr('[f,theta,g] = optim(list(grocer_ologit,y,x)'+...
   +opt_optim('optim ineq')+',param'+opt_optim('optim')+')')
 
case 'optimg' then
   [f,theta,g] = optimg(list(grocer_ologit0,y,x),list(grocer_ologit,y,x),param,...
   opt_optim('optim'),opt_optim('nelmead'),opt_optim('convg'));
 
else
   error('not an available optimisation method:' +optim_func)
end
 
nobs=size(y,1)
// find the values taken by y
valy=unique(y)
nvaly=size(valy,1)
like0=0
for i=1:nvaly
   ni=sum(y==valy(i))
   like0=like0+ni*log(ni/nobs)
// restricted likelihood
end
 
// McFadden pseudo-R2
r2mf=1-abs(f)/abs(like0)
// Estrella R2
term0 = (2/nobs)*like0
term1 = 1/(abs(f)/abs(like0))^term0
rsqr=1-term1
// LR-ratio test against intercept model
lratio=2*(-f-like0)
 
[llike,gra,F]=ologit_like(theta,y,x)
P=F(:,2:$)-F(:,1:$-1)
 
res=tlist(['results';'meth';'y';'x';'nobs';'nvar';'ncat';...
'beta';'yhat';'r2mf';'rsqr';'llike';'grad';'lratio';'condindex'],...
'ordered logit',y,x,nobs,size(theta,1),nvaly,theta,P,r2mf,rsqr,...
-f,-g,lratio,bkwols(x))
res = hessologit(res);
 
endfunction
