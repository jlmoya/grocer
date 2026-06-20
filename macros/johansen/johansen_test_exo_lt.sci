function [res]=johansen_test_exo_lt(res,nbrel,exo_lt_test,varargin)
 
// PURPOSE: in the Johansen procedure, test that an exogenous
// variable has been correctly included in the cointegrating
// vectors
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
//   - res('test type') = 'inclusion in the cointegration relation'
//   - res('test stat') = value of the statistical test
//   - res('bootstrap test pvalue') = the p-value of the test
//     statistic calculated with the standard bootstrap method
//   - res('fast double bootstrap test pvalue')= the p-value of
//     the teststatistic calculated with the double bootstrap
//     method
//   - res('variables tested') = name of the variables tested
//   - res('nb variables tested') = # of variables tested
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
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argin=strsubst(grocer_argi,' ','')
 
      if part(grocer_argin,1:6) == 'NBoot=' then
         execstr(grocer_argin)
         varargin(grocer_i) =null()
      elseif 'noprint' then
         prt=%f
         varargin(grocer_i) =null()
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
evec_H0=res('evec')
namexo_lt=res('namexo_lt')
 
lagya=lagy
ya=y
exoa=exo
nvar_tested=size(exo_lt_test,'*')
// calculate the eigen values under H0
for i=1:nvar_tested
   ind_exo_lt=find(namexo_lt==exo_lt_test(i))
   exoa=[exoa lagya(:,ny+ind_exo_lt)]
   lagya(:,ny+ind_exo_lt)=[]
end
[flag,lambda,evec_H0,lr1,lr2,pi,s00]=johansen_eigen(dy,exo,lagy)
[flag,lambda,evec_Ha,lr1,lr2,pi,s00_a]=johansen_eigen(dy,exoa,lagya)
 
// vector of statistics for all number of cointegration relations
stat=nobs*(log(det(s00))-log(det(s00_a))+cumsum((log(1-res('eig'))-log(1-lambda))))
// take the one corresponding to the chosen # of cointegration relations
stat_test=stat(nbrel)
 
// calculate unrestricted residuals
b=ols0(dy,[lagya*evec_Ha(:,1:nbrel) exoa])
alpha=b(1:nbrel,:)
gam=b(nbrel+1:$,:)
resid=(dy-lagya*evec_Ha(:,1:nbrel)*alpha-exoa*gam)*sqrt(nobs/(nobs-size(b,1)))
 
// calculate restricted coefficients of the short run dynamics
b=ols0(dy,[lagy*evec_H0(:,1:nbrel) exo])
alpha=b(1:nbrel,:)
gam=b(nbrel+1:$,:)
 
// withdraw residuals corresponding to dummies
[resid,nb_suppr_resid]=suppr_resid_dummies(resid,exo,max_nonzeros)
nbresid=size(resid,1)
 
// do (Nboot*2 x nobs) draws in a uniform law (the factor 2 because of the double boostrap)
draws=floor(grand(NBoot*2,nobs,'unf',1,nbresid+1))
 
// set starting values
yn=y;
lt0=[lagy ; zeros(1,nlagy)];
lta=[lagya ; zeros(1,size(lagya,2))];
exon0=[exo ; zeros(1,size(exo,2))];
exona=[exoa ; zeros(1,size(exoa,2))];
test_boot=[zeros(NBoot,1) ; stat_test];
test_boot2=[zeros(NBoot,1) ; stat_test];
 
dyn=zeros(nobs,ny)
//nexo_lt=size(exo_lt,2)
 
drawi=0
 
while drawi < NBoot
   drawi=drawi+1
   residn=resid(draws(drawi,:),:)
   // simulation of the model under H0
   for t=1:nobs
      dyn(t,:)=lt0(t,:)*evec_H0(:,1:nbrel)*alpha+exon0(t,:)*gam+residn(t,:) ;
      lt0(t+1,1:ny)=lt0(t,1:ny)+dyn(t,:);
      lta(t+1,1:ny)=lta(t,1:ny)+dyn(t,:);
      exon0(t+1,1:ny*nlags)=[dyn(t,:) exon0(t,1:ny*(nlags-1))];
      exona(t+1,1:ny*nlags)=[dyn(t,:) exona(t,1:ny*(nlags-1))];
   end
   [flag,an,evecn,lr1n,lr2n,pin,s00_an]=johansen_eigen(dyn,exona(1:$-1,:),lta(1:$-1,:))
   if flag == 'not OK' then
      draws(drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
      drawi=drawi-1
   else
      [flag,an2,evecn2,lr1n2,lr2n2,pin2,s00n]=johansen_eigen(dyn,exon0(1:$-1,:),lt0(1:$-1,:))
      if flag == 'not OK' then
         draws(drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
         drawi=drawi-1
      else
         stat=nobs*(log(det(s00n))-log(det(s00_an))+cumsum((log(1-an2)-log(1-an))))
         // take the one corresponding to the chosen # of cointegration relations
         test_boot(drawi)=stat(nbrel)
         b2=ols0(dyn,[lta(1:$-1,:)*evecn(:,1:nbrel) exona(1:$-1,:)])
         alpha2=b2(1:nbrel,:)
         gam2=b2(nbrel+1:$,:)
         residn_b=(dyn-lta(1:$-1,:)*evecn(:,1:nbrel)*alpha2-exona(1:$-1,:)*gam2)*sqrt(nobs/(nobs-size(b2,1)))
         residn_fb=residn_b(draws(NBoot+drawi,:),:)
         b2c=ols0(dyn,[lt0(1:$-1,:)*evecn2(:,1:nbrel) exon0(1:$-1,:)])
         alpha2c=b2c(1:nbrel,:)
         gam2c=b2c(nbrel+1:$,:)
 
         for t=1:nobs
            dyn_fb(t,:)=lt0(t,:)*evecn2(:,1:nbrel)*alpha2c+exon0(t,:)*gam2c+residn_fb(t,:) ;
            lt0(t+1,1:ny)=lt0(t,1:ny)+dyn_fb(t,:);
            lta(t+1,1:ny)=lta(t,1:ny)+dyn_fb(t,:);
            exon0(t+1,1:ny*nlags)=[dyn_fb(t,:) exon0(t,1:ny*(nlags-1))];
            exona(t+1,1:ny*nlags)=[dyn_fb(t,:) exona(t,1:ny*(nlags-1))];
         end
         [flag,a_fb,evec_fb,lr1_fb,lr2_fb,pi_fb,s00a_fb]=johansen_eigen(dyn_fb,exona(1:$-1,:),lta(1:$-1,:))
         if flag == 'not OK' then
            draws(NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
            drawi=drawi-1
         else
            [flag2,a_fb2,evec_fb2,lr1_fb2,lr2_fb2,pi_fb2,s00_fb2]=johansen_eigen(dyn_fb,exon0(1:$-1,:),lt0(1:$-1,:))
            if flag2 == 'not OK' then
               draws(NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nobs+1-nb_suppr_resid))
               drawi=drawi-1
            else
               stat=nobs*(log(det(s00_fb2))-log(det(s00a_fb))+cumsum((log(1-a_fb2)-log(1-a_fb))))
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
 
res(1)($+1)='nb of cointegration relations'
res(1)($+1)='test type'
res(1)($+1)='test stat'
res(1)($+1)='fast double bootstrap test pvalue'
res(1)($+1)='bootstrap test pvalue'
res(1)($+1)='variables tested'
res(1)($+1)='nb variables tested'
res(1)($+1)='test nb of draws'
 
res('nb of cointegration relations')=nbrel
res('test type')='inclusion in the cointegration relation'
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
