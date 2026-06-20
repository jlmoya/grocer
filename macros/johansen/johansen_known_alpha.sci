function [res]=johansen_known_alpha(res,nbrel,alpha,varargin)
 
// PURPOSE: in the Johansen procedure, impose and test that
// some columns of the alpha coefficients (the error
// corrections) are known
// ------------------------------------------------------------
// INPUT:
// * res = a johansen res tlist
// * nbrel = a scalar, the # cointegration relations
// * alpha = the known alpha matrix
// * varargin = arguments which can be:
//   . the string 'NBoot=n' where n is the number of bootstrap
//     draws (default: 999)
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
// ------------------------------------------------------------
// OUTPUT:
// res = a result tlist with all the fields of the input result
// tlist plus:
//   - res('nb of cointegration relations') = # of cointegration
//     relations used for the test
//   - res('test type')='some ec vectors imposed'
//   - res('test stat') = value of the statistical test
//   - res('bootstrap test pvalue') = the p-value of the test
//     statistic calculated with the standard bootstrap method
//   - res('fast double bootstrap test pvalue')= the p-value of
//     the test statistic calculated with the double bootstrap
//     method
//   - res('test nb of draws') = NBoot
//   - res('imposed ec vectors') = the matrix of imposed error
//     correction terms
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
 
// ser defaults
NBoot=999
prt=%t
max_nonzeros=res('max non zeros')
 
y=res('y')
namey=res('namey')
dy=res('dy')
exo=res('exo')
lagy=res('lagy')
nlagy=size(lagy,2)
nobs=res('nobs')
nlags=res('nlags')
ny=res('nvar')
evec_Ha=res('evec')
namexo_lt=res('namexo_lt')
eig=res('eig')
nalpha=min(size(alpha))
 
nargin=length(varargin)
for i=nargin:-1:1
   argi=varargin(i)
   if typeof(argi) == 'string' then
      argin=strsubst(argi,' ','')
 
      if part(argin,1:6) == 'NBoot=' then
         execstr(''+argin)
         varargin(i) =null()
      elseif argin == 'noprint' then
         prt=%f
         varargin(i) =null()
      end
   end
end
alpha_bar=alpha*inv(alpha'*alpha)
alpha_ortho=orthog2vec(alpha)
alpha_ortho_bar=alpha_ortho*inv(alpha_ortho'*alpha_ortho)
 
r0t = dy-exo*ols0(dy,exo)
r1t = lagy-exo*ols0(lagy,exo)
 
r0t_s=r0t*alpha_bar-[r1t r0t*alpha_ortho_bar]*ols0(r0t*alpha_bar,[r1t r0t*alpha_ortho_bar])
[flag,lambda,evec_H0,lr1,lr2,pi,s00_a]=johansen_eigen(r0t*alpha_ortho_bar,[],r1t)
 
cumeig=cumsum(log(1-eig))
cumlamb=cumsum(log(1-lambda))
stat_test=nobs*(log(det(s00_a))+cumlamb(nbrel-nalpha)+log(det(r0t_s'*r0t_s/nobs))-log(det(r0t'*r0t/nobs))-cumeig(nbrel))
 
// calculate unrestricted residuals
ba=ols0(dy,[lagy*evec_Ha(:,1:nbrel) exo])
nb=size(ba,1)
alpha_a=ba(1:nbrel,:)
gam=ba(nbrel+1:$,:)
resid=(dy-lagy*evec_Ha(:,1:nbrel)*alpha_a-exo*gam)
 
// calculate restricted coefficients of the short run dynamics
psi=ols0(r0t*alpha_ortho_bar,r1t*evec_H0(:,1:nbrel-nalpha))
delta=ols0(r0t*alpha_bar,[r1t r0t*alpha_ortho_bar])
omega=delta($-ny+nalpha+1:$,:)
beta1=delta(1:$-ny+nalpha,:)-evec_H0(:,1:nbrel-nalpha)*psi*omega
 
gam=ols0(dy-lagy*(beta1*alpha'+evec_H0(:,1:nbrel-nalpha)*psi*alpha_ortho'),exo)
 
// withdraw residuals corresponding to dummies
[resid,nb_suppr_resid]=suppr_resid_dummies(resid,exo,max_nonzeros)
nbresid=size(resid,1)
resid=resid*sqrt(nbresid/(nbresid-nb))
 
// do (Nboot*2 x nobs) draws in a uniform law (the factor 2 because of the double boostrap)
draws=floor(grand(NBoot*2,nobs,'unf',1,nbresid+1))
 
// set starting values
yn=y;
lagyn=[lagy ; zeros(1,nlagy)];
exon=[exo ; zeros(1,size(exo,2))];
test_boot=[zeros(NBoot,1) ; stat_test];
test_boot2=[zeros(NBoot,1) ; stat_test];
dyn=zeros(nobs,ny)
drawi=0
 
while drawi < NBoot
   drawi=drawi+1
   residn=resid(draws(drawi,:),:)
   // simulation of the model under H0
   for t=1:nobs
      dyn(t,:)=lagyn(t,:)*(beta1*alpha'+evec_H0(:,1:nbrel-nalpha)*psi*alpha_ortho')+exon(t,:)*gam+residn(t,:) ;
      lagyn(t+1,1:ny)=lagyn(t,1:ny)+dyn(t,:);
      exon(t+1,1:ny*nlags)=[dyn(t,:) exon(t,1:ny*(nlags-1))];
   end
   [flag,an,evecn,lr1n,lr2n,pin,s00_an]=johansen_eigen(dyn,exon(1:$-1,:),lagyn(1:$-1,:))
   if flag == 'not OK' then
      draws(drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
      drawi=drawi-1
   else
      r0t = dyn-exon(1:$-1,:)*ols0(dyn,exon(1:$-1,:))
      r1t = lagyn(1:$-1,:)-exon(1:$-1,:)*ols0(lagyn(1:$-1,:),exon(1:$-1,:))
      r0t_s=r0t*alpha_bar-[r1t r0t*alpha_ortho_bar]*ols0(r0t*alpha_bar,[r1t r0t*alpha_ortho_bar])
      [flag,an2,evecn2,lr1n2,lr2n2,pin2,s00n]=johansen_eigen(r0t*alpha_ortho_bar,[],r1t)
      if flag == 'not OK' then
         draws(drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
         drawi=drawi-1
      else
         cumeig=cumsum(log(1-an))
         cumlamb=cumsum(log(1-an2))
         stat=nobs*(log(det(s00n))+cumlamb(nbrel-nalpha)+log(det(r0t_s'*r0t_s/nobs))-log(det(r0t'*r0t/nobs))-cumeig(nbrel))
         test_boot(drawi)=stat
 
         b2=ols0(dyn,[lagyn(1:$-1,:)*evecn(:,1:nbrel) exon(1:$-1,:)])
         alpha2=b2(1:nbrel,:)
         gam2=b2(nbrel+1:$,:)
         residn_b=(dyn-lagyn(1:$-1,:)*evecn(:,1:nbrel)*alpha2-exon(1:$-1,:)*gam2)*sqrt(nobs/(nobs-size(b2,1)))
         residn_fb=residn_b(draws(NBoot+drawi,:),:)
 
         // calculate restricted coefficients of the short run dynamics
         psi_fb=ols0(r0t*alpha_ortho_bar,r1t*evecn2(:,1:nbrel-nalpha))
         delta_fb=ols0(r0t*alpha_bar,[r1t r0t*alpha_ortho_bar])
         omega_fb=delta_fb($-ny+nalpha+1:$,:)
         beta1_fb=delta(1:$-ny+nalpha,:)-evecn2(:,1:nbrel-nalpha)*psi_fb*omega_fb
 
         gam_fb=ols0(dyn-lagyn(1:$-1,:)*(beta1_fb*alpha'+evecn2(:,1:nbrel-nalpha)*psi_fb*alpha_ortho'),exon(1:$-1,:))
 
         for t=1:nobs
            dyn(t,:)=lagyn(t,:)*(beta1_fb*alpha'+evecn2(:,1:nbrel-nalpha)*psi_fb*alpha_ortho')+exon(t,:)*gam_fb+residn_fb(t,:) ;
            lagyn(t+1,1:ny)=lagyn(t,1:ny)+dyn(t,:);
            exon(t+1,1:ny*nlags)=[dyn(t,:) exon(t,1:ny*(nlags-1))];
         end
         [flag,a_fb,evec_fb,lr1_fb,lr2_fb,pi_fb,s00a_fb]=johansen_eigen(dyn,exon(1:$-1,:),lagyn(1:$-1,:))
         if flag == 'not OK' then
            draws(NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
            drawi=drawi-1
         else
            r0t = dyn-exon(1:$-1,:)*ols0(dyn,exon(1:$-1,:))
            r1t = lagyn(1:$-1,:)-exon(1:$-1,:)*ols0(lagyn(1:$-1,:),exon(1:$-1,:))
            r0t_s=r0t*alpha_bar-[r1t r0t*alpha_ortho_bar]*ols0(r0t*alpha_bar,[r1t r0t*alpha_ortho_bar])
            [flag2,a_fb2,evec_fb2,lr1_fb2,lr2_fb2,pi_fb2,s00_fb2]=johansen_eigen(r0t*alpha_ortho_bar,[],r1t)
            if flag2 == 'not OK' then
               draws(NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
               drawi=drawi-1
            else
               cumeig=cumsum(log(1-a_fb))
               cumlamb=cumsum(log(1-a_fb2))
               stat=nobs*(log(det(s00_fb2))+cumlamb(nbrel-nalpha)+log(det(r0t_s'*r0t_s/nobs))-log(det(r0t'*r0t/nobs))-cumeig(nbrel))
               test_boot2(drawi)=stat
            end
         end
      end
   end
 
end
 
test_boot=gsort(real(test_boot),'g','i')
test_p=sum(test_boot > real(stat_test))/NBoot
test_boot2=gsort(test_boot2,'g','i')
Q_B=real(test_boot2(max(floor(NBoot-test_p*NBoot),1)))
test_p2=sum(test_boot > Q_B)/NBoot
 
res(1)($+1)='nb of cointegration relations'
res(1)($+1)='test type'
res(1)($+1)='test stat'
res(1)($+1)='fast double bootstrap test pvalue'
res(1)($+1)='bootstrap test pvalue'
res(1)($+1)='imposed ec vectors'
res(1)($+1)='test nb of draws'
 
res('nb of cointegration relations')=nbrel
res('test type')='some ec vectors imposed'
res('test stat')=stat_test
res('bootstrap test pvalue')=test_p
res('fast double bootstrap test pvalue')=test_p2
res('imposed ec vectors')=alpha
res('test nb of draws')=NBoot
 
res('alpha')=[alpha alpha_ortho*psi']
res('evec')=[beta1 evec_H0(:,1:nbrel-nalpha)]
 
if prt then
   prtjohvec(res,nbrel)
   prt_johtest(res)
end
 
endfunction
