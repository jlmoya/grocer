function [res]=johansen_common_beta(res,nbrel,H,varargin)
 
// PURPOSE: in the Johansen procedure, impose and test
// common restrictions on the cointegration relations (beta
// coefficients)
// ------------------------------------------------------------
// INPUT:
// * res = a johansen res tlist
// * nbrel = a scalar, the # cointegration relations
// * H = a (n x k) matrix doing making the passage from the
//   free parameters to the constrained ones
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
//   - res('H') = matrix that transforms the free parameters
//     into the constrained ones
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
 
// ser defaults
NBoot=999
prt=%t
max_nonzeros=res('max non zeros')
 
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
 
y=res('y')
dy=res('dy')
exo=res('exo')
lagy=res('lagy')
nlagy=size(lagy,2)
nobs=res('nobs')
nlags=res('nlags')
ny=res('nvar')
evec_Ha=res('evec')
exo_lt=res('exo_lt')
// calculate the eigen values under H0
[flag,lambda,evec,lr1,lr2,pi]=johansen_eigen(dy,exo,lagy*H)
 
nb_restrictions=size(H,1)-size(H,2)
if nb_restrictions > nlagy-nbrel then
   error('you have imposed more restrictions ('+string(nb_restrictions)+') than the maximum available ('+string(nlagy-nbrel))
else
   res_eig=res('eig')(1:nbrel)
   // vector of statistics for the given number of cointegration relations
   stat_test=nobs*sum((log(1-lambda(1:nbrel))-log(1-res_eig)))
end
 
// calculate unrestricted residuals
b=ols0(dy,[lagy*evec_Ha(:,1:nbrel) exo])
alpha=b(1:nbrel,:)
gam=b(nbrel+1:$,:)
resid=(dy-lagy*evec_Ha(:,1:nbrel)*alpha-exo*gam)*sqrt(nobs/(nobs-size(b,1)))
 
// calculate restricted coefficients of the short run dynamics
b=ols0(dy,[lagy*H*evec(:,1:nbrel) exo])
alpha=b(1:nbrel,:)
gam=b(nbrel+1:$,:)
 
// withdraw residuals corresponding to dummies
[resid,nb_suppr_resid]=suppr_resid_dummies(resid,exo,max_nonzeros)
nbresid=size(resid,1)
 
// do (Nboot*2 x nobs) draws in a uniform law (the factor 2 because of the double boostrap)
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
      dyn(t,:)=lt(t,:)*H*evec(:,1:nbrel)*alpha+exon(t,:)*gam+residn(t,:) ;
      lt(t+1,1:ny)=lt(t,1:ny)+dyn(t,:);
      exon(t+1,1:ny*nlags)=[dyn(t,:) exon(t,1:ny*(nlags-1))];
   end
   [flag,an,evecn,lr1n,lr2n,pin]=johansen_eigen(dyn,exon(1:$-1,:),lt(1:$-1,:))
   if flag == 'not OK' then
      draws(drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
      drawi=drawi-1
   else
      [flag,an2,evecn2,lr1n2,lr2n2,pin2]=johansen_eigen(dyn,exon(1:$-1,:),lt(1:$-1,:)*H)
      if flag == 'not OK' then
         draws(drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
         drawi=drawi-1
      else
         stat=nobs*sum((log(1-an2(1:nbrel))-log(1-an(1:nbrel))))
         test_boot(drawi)=stat
         b2=ols0(dyn,[lt(1:$-1,:)*evecn(:,1:nbrel) exon(1:$-1,:)])
         alpha2=b2(1:nbrel,:)
         gam2=b2(nbrel+1:$,:)
         residn_b=(dyn-lt(1:$-1,:)*evecn(:,1:nbrel)*alpha2-exon(1:$-1,:)*gam2)*sqrt(nobs/(nobs-size(b2,1)))
         residn_fb=residn_b(draws(NBoot+drawi,:),:)
         b2c=ols0(dyn,[lt(1:$-1,:)*H*evecn2(:,1:nbrel) exon(1:$-1,:)])
         alpha2c=b2c(1:nbrel,:)
         gam2c=b2c(nbrel+1:$,:)
 
         for t=1:nobs
            dyn_fb(t,:)=lt(t,:)*H*evecn2(:,1:nbrel)*alpha2c+exon(t,:)*gam2c+residn_fb(t,:) ;
            lt(t+1,1:ny)=lt(t,1:ny)+dyn_fb(t,:);
            exon(t+1,1:ny*nlags)=[dyn_fb(t,:) exon(t,1:ny*(nlags-1))];
         end
         [flag,a_fb,evec_fb,lr1_fb,lr2_fb,pi_fb]=johansen_eigen(dyn_fb,exon(1:$-1,:),lt(1:$-1,:))
         if flag == 'not OK' then
            draws(NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
            drawi=drawi-1
         else
            [flag2,a_fb2,evec_fb2,lr1_fb2,lr2_fb2,pi_fb2]=johansen_eigen(dyn_fb,exon(1:$-1,:),lt(1:$-1,:)*H)
            if flag2 == 'not OK' then
               draws(NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
               drawi=drawi-1
            else
               stat=nobs*sum((log(1-a_fb2(1:nbrel))-log(1-a_fb(1:nbrel))))
               test_boot2(drawi)=stat
            end
         end
      end
   end
 
 
end
 
test_boot=gsort(test_boot,'g','i')
test_p=sum(test_boot > stat_test)/NBoot
test_boot2=gsort(test_boot2,'g','i')
Q_B=test_boot2(max(floor(NBoot-test_p*NBoot),1))
test_p2=sum(test_boot > Q_B)/NBoot
 
res('eig')=lambda
res('evec')=H*evec
res('lr1')=lr1
res('lr1')=lr2
res('alpha')=alpha
 
res(1)($+1)='nb of cointegration relations'
res(1)($+1)='test type'
res(1)($+1)='test stat'
res(1)($+1)='fast double bootstrap test pvalue'
res(1)($+1)='bootstrap test pvalue'
res(1)($+1)='H'
res(1)($+1)='test nb of draws'
 
res('nb of cointegration relations')=nbrel
res('test type')='common beta'
res('test stat')=stat_test
res('bootstrap test pvalue')=test_p
res('fast double bootstrap test pvalue')=test_p2
res('H')=H
res('test nb of draws')=NBoot
 
if prt then
   prtjohvec(res,nbrel)
   prt_johtest(res)
end
 
endfunction
