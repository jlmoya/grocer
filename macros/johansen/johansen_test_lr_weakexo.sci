function [res]=johansen_test_lr_weakexo(res,nbrel,exo_lt_test,varargin)
 
// PURPOSE: in the Johansen procedure, test the long run weak
// exogenity of a subset of variables
// ------------------------------------------------------------
// * References:
// ------------------------------------------------------------
// INPUT:
// * res = a johansen res tlist
// * nbrel = a scalar, the # cointegration relations
// * exo_lt_test = the name of the exogenous variable
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
//   - res('test type')='long run weak exogeneity'
//   - res('test stat') = value of the statistical test
//   - res('bootstrap test pvalue') = the p-value of the test
//     statistic calculated with the standard bootstrap method
//   - res('fast double bootstrap test pvalue')= the p-value of
//     the test statistic calculated with the double bootstrap
//     method
//   - res('test nb of draws')=NBoot
//   - res('variables tested') = supposed weak exogenous
//     variables
//   - res('nb variables tested')=# of weak exogenous variables
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
 
nargin=length(varargin)
for i=nargin:-1:1
   argi=varargin(i)
   if typeof(argi) == 'string' then
      argin=strsubst(argi,' ','')
      str7=part(strsubst(argin,' ',''),1:7)
 
      if part(argin,1:6) == 'NBoot=' then
         execstr(''+argin)
         varargin(i) =null()
      elseif argin == 'noprint' then
         prt=%f
         varargin(i) =null()
      end
   end
end
 
 
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
 
lagya=lagy
ya=y
exoa=exo
nvar_tested=size(exo_lt_test,'*')
ind_colzero=[]
ind_colfree=1:ny
// calculate the eigen values under H0
for i=1:nvar_tested
   ind_colzero=[ind_colzero find(namey == exo_lt_test(i))]
end
ind_colfree(ind_colzero)=[]
H=zeros(nvar_tested,ny)
for i=1:size(ind_colfree,2)
   H(i,ind_colfree(i))=1
end
H_ortho=orthog2vec(H')'
 
r0t = dy-exo*ols0(dy,exo)
r1t = lagy-exo*ols0(lagy,exo)
Hbar=H'*inv(H*H')
H_ortho_bar=H_ortho'*inv(H_ortho*H_ortho')
 
 
[flag,lambda,evec_H0,lr1,lr2,pi,s00_a]=johansen_eigen(r0t*Hbar,r0t*H_ortho_bar,r1t)
 
//keep only the # of cointegration relations which allow the test
eig=eig(1:size(ind_colfree,2))
stat=nobs*(cumsum(log(1-lambda))-cumsum(log(1-eig)))
// vector of statistics for all number of cointegration relations
stat_test=stat(nbrel)
 
// calculate unrestricted residuals
b=ols0(dy,[lagy*evec_Ha(:,1:nbrel) exo])
alpha=b(1:nbrel,:)
gam=b(nbrel+1:$,:)
resid=(dy-lagya*evec_Ha(:,1:nbrel)*alpha-exoa*gam)*sqrt(nobs/(nobs-size(b,1)))
 
// calculate restricted coefficients of the short run dynamics
b1=ols0(dy*Hbar,[lagy*evec_H0(:,1:nbrel) exo dy*H_ortho_bar])
b2=ols0(dy*H_ortho_bar,exo)
alpha=b1(1:nbrel,:)*H
gam(:,ind_colfree)=b1(nbrel+1:$-nvar_tested,:)
gam(:,ind_colzero)=b2
 
// withdraw residuals corresponding to dummies
[resid,nb_suppr_resid]=suppr_resid_dummies(resid,exo,max_nonzeros)
nbresid=size(resid,1)
 
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
      dyn(t,:)=lagyn(t,:)*evec_H0(:,1:nbrel)*alpha+exon(t,:)*gam+residn(t,:) ;
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
      [flag,an2,evecn2,lr1n2,lr2n2,pin2,s00n]=johansen_eigen(r0t*Hbar,r0t*H_ortho_bar,r1t)
      if flag == 'not OK' then
         draws(drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
         drawi=drawi-1
      else
         an=an(1:size(ind_colfree,2))
         stat=nobs*(cumsum(log(1-an2))-cumsum(log(1-an)))
         test_boot(drawi)=stat(nbrel)
 
         b2=ols0(dyn,[lagyn(1:$-1,:)*evecn(:,1:nbrel) exon(1:$-1,:)])
         alpha2=b2(1:nbrel,:)
         gam2=b2(nbrel+1:$,:)
         residn_b=(dyn-lagyn(1:$-1,:)*evecn(:,1:nbrel)*alpha2-exon(1:$-1,:)*gam2)*sqrt(nobs/(nobs-size(b2,1)))
         residn_fb=residn_b(draws(NBoot+drawi,:),:)
 
         b2c1=ols0(dyn*Hbar,[lagyn(1:$-1,:)*evecn(:,1:nbrel) exon(1:$-1,:) dyn*H_ortho_bar])
         b2c2=ols0(dyn*H_ortho_bar,exo)
         alpha2c=b2c1(1:nbrel,:)*H
         gam2(:,ind_colfree)=b2c1(nbrel+1:$-nvar_tested,:)
         gam2(:,ind_colzero)=b2c2
 
         for t=1:nobs
            dyn_fb(t,:)=lagyn(t,:)*evecn(:,1:nbrel)*alpha2c+exon(t,:)*gam2+residn_fb(t,:) ;
            lagyn(t+1,1:ny)=lagyn(t,1:ny)+dyn_fb(t,:);
            exon(t+1,1:ny*nlags)=[dyn_fb(t,:) exon(t,1:ny*(nlags-1))];
         end
         [flag,a_fb,evec_fb,lr1_fb,lr2_fb,pi_fb,s00a_fb]=johansen_eigen(dyn_fb,exon(1:$-1,:),lagyn(1:$-1,:))
         if flag == 'not OK' then
            draws(NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
            drawi=drawi-1
         else
            a_fb=a_fb(1:size(ind_colfree,2))
            r0t = dyn_fb-exon(1:$-1,:)*ols0(dyn_fb,exon(1:$-1,:))
            r1t = lagyn(1:$-1,:)-exon(1:$-1,:)*ols0(lagyn(1:$-1,:),exon(1:$-1,:))
            [flag2,a_fb2,evec_fb2,lr1_fb2,lr2_fb2,pi_fb2,s00_fb2]=johansen_eigen(r0t*Hbar,r0t*H_ortho_bar,r1t)
            if flag2 == 'not OK' then
               draws(NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
               drawi=drawi-1
            else
               stat=nobs*(cumsum(log(1-a_fb2))-cumsum(log(1-a_fb)))
               test_boot2(drawi)=stat(nbrel)
            end
         end
      end
   end
 
end
 
test_boot=gsort(real(test_boot),'g','i')
test_p=sum(test_boot > stat_test)/NBoot
test_boot2=gsort(test_boot2,'g','i')
Q_B=real(test_boot2(max(floor(NBoot-test_p*NBoot),1)))
test_p2=sum(test_boot > Q_B)/NBoot
 
res('alpha')=alpha
res('evec')=evec_H0
 
res(1)($+1)='nb of cointegration relations'
res(1)($+1)='test type'
res(1)($+1)='test stat'
res(1)($+1)='fast double bootstrap test pvalue'
res(1)($+1)='bootstrap test pvalue'
res(1)($+1)='variables tested'
res(1)($+1)='nb variables tested'
res(1)($+1)='test nb of draws'
 
res('nb of cointegration relations')=nbrel
res('test type')='long run weak exogeneity'
res('test stat')=stat_test
res('bootstrap test pvalue')=test_p
res('fast double bootstrap test pvalue')=test_p2
res('variables tested')=exo_lt_test
res('nb variables tested')=nvar_tested
res('test nb of draws')=NBoot
 
if prt then
   prtjohvec(res,nbrel)
   prt_johtest(res)
end
 
endfunction
