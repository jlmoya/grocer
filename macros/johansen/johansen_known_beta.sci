function [res]=johansen_known_beta(res,nbrel,b,varargin)
 
// PURPOSE: in the Johansen procedure, impose and test
// some of the cointegration relations (beta
// coefficients)
// ------------------------------------------------------------
// INPUT:
// * res = a johansen res tlist
// * nbrel = a scalar, the # cointegration relations
// * b = a matrix, the imposed cointegration relations
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
//   - res('test type')='common beta'
//   - res('test stat') = value of the statistical test
//   - res('bootstrap test pvalue') = the p-value of the test
//     statistic calculated with the standard bootstrap method
//   - res('fast double bootstrap test pvalue')= the p-value of
//     the test statistic calculated with the double bootstrap
//     method
//   - res('test nb of draws')=NBoot
//   - res('b') = matrix of the known cointegrating parameters
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
 
// find a matrix orthogonal to b
bortho=orthog2vec(b)
 
// recover the matrices s00, s11, s01 to calculate the rho and lambda constrained
// (cf. Juselius p.183-184)
[flag,rho,r0t,r1t]=johansen_eigen_b(dy,exo,lagy,b)
if flag == 'not OK' then
   error('constraint not suitable')
end
[flag,lambda,d,evec]=johansen_eigen_bortho(r0t,r1t,b,bortho,nbrel)
 
eig=res('eig')(1:nbrel)
// statistics for the chosen number of cointegration relations
stat_test=nobs*(sum(log(1-lambda))+sum(log(1-rho))-sum(log(1-eig)))
 
// calculate unrestricted residuals
ba=ols0(dy,[lagy*evec_Ha(:,1:nbrel) exo])
nb=size(ba,1)
alpha=ba(1:nbrel,:)
gam=ba(nbrel+1:$,:)
resid=(dy-lagy*evec_Ha(:,1:nbrel)*alpha-exo*gam)
// calculate restricted coefficients of the short run dynamics
b0=ols0(dy,[lagy*evec(:,1:nbrel) exo])
alpha=b0(1:nbrel,:)
gam=b0(nbrel+1:$,:)
 
// withdraw residuals corresponding to dummies
resid=suppr_resid_dummies(resid,exo,max_nonzeros)
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
      dyn(t,:)=lt(t,:)*evec(:,1:nbrel)*alpha+exon(t,:)*gam+residn(t,:) ;
      lt(t+1,1:ny)=lt(t,1:ny)+dyn(t,:);
      exon(t+1,1:ny*nlags)=[dyn(t,:) exon(t,1:ny*(nlags-1))];
   end
 
   [flag1,an,evecn,lr1n,lr2n,pin]=johansen_eigen(dyn,exon(1:$-1,:),lt(1:$-1,:))
   [flag2,rhon,r0tn,r1tn]=johansen_eigen_b(dyn,exon(1:$-1,:),lt(1:$-1,:),b)
   [flag3,lambdan2,dn2,evecn2]=johansen_eigen_bortho(r0tn,r1tn,b,bortho,nbrel)
 
   if or([flag1 flag2 flag3] == 'not OK') then
      draws(drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
      drawi=drawi-1
   else
   // statistics for the chosen number of cointegration relations
      test_boot(drawi)=nobs*(sum(log(1-lambdan2))+sum(log(1-rhon))-sum(log(1-an(1:nbrel))))
 
      b2=ols0(dyn,[lt(1:$-1,:)*evecn(:,1:nbrel) exon(1:$-1,:)])
      alpha2=b2(1:nbrel,:)
      gam2=b2(nbrel+1:$,:)
      residn_b=(dyn-lt(1:$-1,:)*evecn(:,1:nbrel)*alpha2-exon(1:$-1,:)*gam2)*sqrt(nobs/(nobs-nb))
      residn_fb=residn_b(draws(NBoot+drawi,:),:)
 
      b2c=ols0(dyn,[lt(1:$-1,:)*evecn2(:,1:nbrel) exon(1:$-1,:)])
      alpha2c=b2c(1:nbrel,:)
      gam2c=b2c(nbrel+1:$,:)
 
      for t=1:nobs
         dyn(t,:)=lt(t,:)*evecn2(:,1:nbrel)*alpha2c+exon(t,:)*gam2c+residn_fb(t,:) ;
         lt(t+1,1:ny)=lt(t,1:ny)+dyn(t,:);
         exon(t+1,1:ny*nlags)=[dyn(t,:) exon(t,1:ny*(nlags-1))];
      end
 
      [flag1,an_fb,evec_fb,lr1_fb,lr2_fb,pi_fb]=johansen_eigen(dyn,exon(1:$-1,:),lt(1:$-1,:))
      [flag2,rhon_fb,r0tn_fb,r1tn_fb]=johansen_eigen_b(dyn,exon(1:$-1,:),lt(1:$-1,:),b)
      [flag3,lambdan2_fb,dn2_fb,evecn2_fb]=johansen_eigen_bortho(r0tn_fb,r1tn_fb,b,bortho,nbrel)
      if or([flag1 flag2 flag3] == 'not OK') then
         draws(NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
         drawi=drawi-1
      else
         test_boot2(drawi)=nobs*(sum(log(1-lambdan2_fb))+sum(log(1-rhon_fb))-sum(log(1-an_fb(1:nbrel))))
      end
   end
 
 
end
 
test_boot=gsort(test_boot,'g','i')
test_p=sum(test_boot > stat_test)/NBoot
test_boot2=gsort(test_boot2,'g','i')
Q_B=test_boot2(max(floor(NBoot-test_p*NBoot),1))
test_p2=sum(test_boot > Q_B)/NBoot
 
 
res('eig')=lambda
res('evec')=evec
res('alpha')=alpha
 
res(1)($+1)='nb of cointegration relations'
res(1)($+1)='test type'
res(1)($+1)='test stat'
res(1)($+1)='fast double bootstrap test pvalue'
res(1)($+1)='bootstrap test pvalue'
res(1)($+1)='b'
res(1)($+1)='test nb of draws'
res('nb of cointegration relations')=nbrel
res('test type')='known beta'
res('test stat')=stat_test
res('bootstrap test pvalue')=test_p
res('fast double bootstrap test pvalue')=test_p2
res('test nb of draws')=NBoot
res('b')=b
 
if prt then
   prtjohvec(res,nbrel)
   prt_johtest(res)
end
 
endfunction
 
