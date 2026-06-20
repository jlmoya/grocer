function [res]=johansen_beta_part(res,nbrel,H1,varargin)
 
// PURPOSE: in the Johansen procedure, impose and test
// restrictions on the cointegration relations (beta
// coefficients)
// ------------------------------------------------------------
// INPUT:
// * res = a johansen result tlist
// * nbrel = a scalar, the # cointegration relations
// * H1 = a (n x k) matrix doing making the passage from the
//   free coefficients to the restricted ones
// * varargin = arguments which can be:
//   . the string 'NBoot=n' where n is the number of bootstrap
//     draws (default: 999)
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
// ------------------------------------------------------------
// OUTPUT:
// res = a result tlist with all the fields of the input result
// tlist plus:
//   - res('nb of cointegration relations') = # of cointegration
//     relations used for the test
//   - res('test type')='common beta'
//   - res('test stat') = value of the statistical test
//   - res('bootstrap test pvalue') = the p-value of the test
//     statistic calculated with the standard bootstrap method
//   - res('fast double bootstrap test pvalue')= the p-value of
//     the test statistic calculated with the double bootstrap
//     method
//   - res('H1') = matrix that transforms the free parameters
//     parameters into the constrained ones
//   - res('test nb of draws')=NBoot
// ------------------------------------------------------------
// NOTE: uses the function johansen_eigen adapted from a
// programm by James LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
// ------------------------------------------------------------
// PRINTS: If the user has not given the argument 'noprint',
// the trace and max eignevalues statistics
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
NBoot=999
prt=%t
max_nonzeros=res('max non zeros')
crit=sqrt(%eps)
nitermax=500
 
nargin=length(varargin)
for i=nargin:-1:1
   argi=varargin(i)
   if typeof(argi) == 'string' then
      argin=strsubst(argi,' ','')
      if argin == 'noprint' then
         prt=%f
      elseif convstr(part(argin,1:6)) == 'nboot=' then
         execstr(argi)
      end
   end
end
 
y=res('y')
dy=res('dy')
exo=res('exo')
exo_st=res('exo_st')
lagy=res('lagy')
nlagy=size(lagy,2)
nobs=res('nobs')
nlags=res('nlags')
ny=res('nvar')
evec_Ha=res('evec')
exo_lt=res('exo_lt')
 
[nrowH1,ncolH1]=size(H1)
niter=1
r0t = dy-exo*ols0(dy,exo)
r1t = lagy-exo*ols0(lagy,exo)
s00 = r0t'*r0t/nobs
s11 = r1t'*r1t/nobs
s10 = r1t'*r0t/nobs
sig = pinv(H1'*s11*H1)*H1'*s10*pinv(s00)*s10'*H1;
[du,lambda]=spec(sig)
[lambda,ind_lambda]=gsort(real(diag(lambda)),'r','d')
beta1=H1*real(du(:,ind_lambda(1)))
 
[flag,logL_new,beta1,beta2]=johansen_iter_beta_part(r0t,r1t,s00,s11,s10,H1,beta1)
if flag == 'not OK' then
   error('eigenvalues have become meaningless')
end
eig=res('eig')(1:nbrel)
// statistics for the chosen number of cointegration relations
stat_test=-2*logL_new-nobs*sum(log(1-eig))
// calculate unrestricted residuals
ba=ols0(dy,[lagy*evec_Ha(:,1:nbrel) exo])
nb=size(ba,1)
alpha=ba(1:nbrel,:)
gam=ba(nbrel+1:nb,:)
resid=(dy-lagy*evec_Ha(:,1:nbrel)*alpha-exo*gam)
// calculate restricted coefficients of the short run dynamics
b0=ols0(dy,[lagy*[beta1 beta2] exo])
alpha=b0(1:nbrel,:)
gam=b0(nbrel+1:$,:)
 
// withdraw residuals corresponding to dummies
[resid,nb_suppr_resid]=suppr_resid_dummies(resid,exo,max_nonzeros)
nbresid=size(resid,1)
resid=resid*sqrt(nbresid/(nbresid-nb))
 
// do (Nboot*2 x nobs) draws in a uniform law (the factor 2 because of the double bootstrap)
draws=floor(grand(NBoot*2,nobs,'unf',1,nbresid+1))
 
// set starting values
yn=y;
lt=[lagy ; zeros(1,nlagy)];
exon=[exo ; zeros(1,size(exo,2))];
test_boot=[zeros(NBoot,1) ; stat_test];
test_boot2=[zeros(NBoot,1) ; stat_test];
 
dyn=zeros(nobs,ny)
nexo_lt=size(exo_lt,2)
 
drawi=0
 
while drawi < NBoot
   drawi=drawi+1
   residn=resid(draws(drawi,:),:)
   // simulation of the model under H0
   for t=1:nobs
      dyn(t,:)=lt(t,:)*[beta1 beta2]*alpha+exon(t,:)*gam+residn(t,:) ;
      lt(t+1,1:ny)=lt(t,1:ny)+dyn(t,:);
      exon(t+1,1:ny*nlags)=[dyn(t,:) exon(t,1:ny*(nlags-1))];
   end
   r0t = dyn-exon(1:$-1,:)*ols0(dyn,exon(1:$-1,:))
   r1t = lt(1:$-1,:)-exon(1:$-1,:)*ols0(lt(1:$-1,:),exon(1:$-1,:))
   s00 = r0t'*r0t/nobs
   s11 = r1t'*r1t/nobs
   s10 = r1t'*r0t/nobs
 
   [flag1,an,evecn,lr1n,lr2n,pin]=johansen_eigen(dyn,exon(1:$-1,:),lt(1:$-1,:))
   [flag2,logL_newn,beta1n,beta2n]=johansen_iter_beta_part(r0t,r1t,s00,s11,s10,H1,beta1)
 
   if or([flag1 flag2] == 'not OK') then
      draws(drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
      drawi=drawi-1
   else
   // statistics for the chosen number of cointegration relations
      test_boot(drawi)=-2*logL_newn-nobs*sum(log(1-an(1:nbrel)))
 
      b2=ols0(dyn,[lt(1:$-1,:)*evecn(:,1:nbrel) exon(1:$-1,:)])
      alpha2=b2(1:nbrel,:)
      gam2=b2(nbrel+1:$,:)
      residn_b=(dyn-lt(1:$-1,:)*evecn(:,1:nbrel)*alpha2-exon(1:$-1,:)*gam2)*sqrt(nobs/(nobs-nb))
      residn_fb=residn_b(draws(NBoot+drawi,:),:)
 
      b2c=ols0(dyn,[lt(1:$-1,:)*[beta1n beta2n] exon(1:$-1,:)])
      alpha2c=b2c(1:nbrel,:)
      gam2c=b2c(nbrel+1:$,:)
 
      for t=1:nobs
         dyn(t,:)=lt(t,:)*[beta1n beta2n]*alpha2c+exon(t,:)*gam2c+residn_fb(t,:) ;
         lt(t+1,1:ny)=lt(t,1:ny)+dyn(t,:);
         exon(t+1,1:ny*nlags)=[dyn(t,:) exon(t,1:ny*(nlags-1))];
      end
 
      r0t = dyn-exon(1:$-1,:)*ols0(dyn,exon(1:$-1,:))
      r1t = lt(1:$-1,:)-exon(1:$-1,:)*ols0(lt(1:$-1,:),exon(1:$-1,:))
      s00 = r0t'*r0t/nobs
      s11 = r1t'*r1t/nobs
      s10 = r1t'*r0t/nobs
      [flag1,an_fb,evec_fb,lr1_fb,lr2_fb,pi_fb]=johansen_eigen(dyn,exon(1:$-1,:),lt(1:$-1,:))
      [flag2,logL_newn_fb,beta1n_fb,beta2n_fb]=johansen_iter_beta_part(r0t,r1t,s00,s11,s10,H1,beta1n)
      if or([flag1 flag2] == 'not OK') then
         draws(NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
         drawi=drawi-1
      else
         test_boot2(drawi)=-2*logL_newn_fb-nobs*sum(log(1-an_fb(1:nbrel)))
      end
   end
 
 
end
 
test_boot=gsort(test_boot,'g','i')
test_p=sum(test_boot > stat_test)/(NBoot+1)
test_boot2=gsort(test_boot2,'g','i')
Q_B=test_boot2(max(floor(NBoot-test_p*NBoot),1))
test_p2=sum(test_boot > Q_B)/(NBoot+1)
 
 
res('eig')=lambda
res('evec')=[beta1 beta2]
res('alpha')=alpha
 
res(1)($+1)='nb of cointegration relations'
res(1)($+1)='test type'
res(1)($+1)='test stat'
res(1)($+1)='fast double bootstrap test pvalue'
res(1)($+1)='bootstrap test pvalue'
res(1)($+1)='test nb of draws'
res(1)($+1)='H1'
res('nb of cointegration relations')=nbrel
res('test type')='partial restrictions on beta'
res('test stat')=stat_test
res('bootstrap test pvalue')=test_p
res('fast double bootstrap test pvalue')=test_p2
res('test nb of draws')=NBoot
res('H1')=H1
 
if prt then
   prtjohvec(res,nbrel)
   prt_johtest(res)
end
 
endfunction
 
