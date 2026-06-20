function result=johansen_bootstrap(result,NBoot,dy,lagy,exo,exo_lt,evec,alpha,gam,nobs,grocer_max_nonzeros)
    
// calculate unrestricted residuals
// do (Nboot*2 x nobs) draws in a unifrom law (the factor 2 because of the double boostrap
resid=(dy-lagy*evec*alpha-exo*gam)*sqrt(nobs/(nobs-size(b,1)))
resid=suppr_resid_dummies(resid,exo(:,ny*grocer_k+1:$),grocer_max_nonzeros)
nbresid=size(resid,1)
draws=floor(grand(grocer_NBoot*2,nobs,'unf',1,nbresid+1))
yn=y;
lt=[lagy ; zeros(1,nlagy)];
nexo=size(exo,2)
exon=[exo ; zeros(1,nexo)];
lr1_boot=[zeros(grocer_NBoot,ny) ; lr1'];
lr2_boot=[zeros(grocer_NBoot,ny) ; lr2'];
lr1_boot2=[zeros(grocer_NBoot,ny) ; lr1'];
lr2_boot2=[zeros(grocer_NBoot,ny) ; lr2'];
lr1_p=zeros(ny,1)
lr2_p=zeros(ny,1)
lr1_p2=zeros(ny,1)
lr2_p2=zeros(ny,1)
 
dyn=zeros(nobs,ny)
nexo_lt=size(exo_lt,2)
for i=1:ny
   z=[lagy*evec(:,1:i-1) exo]
   nz=size(z,2)
   if nz == 0 then
      resid=dy
   else
      b=ols0(dy,[lagy*evec(:,1:i-1) exo])
      resid=(dy-z*b)*sqrt(nobs/(nobs-size(b,1)))
   end
   resid=suppr_resid_dummies(resid,exo(:,ny*grocer_k+1:$),grocer_max_nonzeros)
   nbresid=size(resid,1)
   drawi=0

   while drawi < grocer_NBoot
      drawi=drawi+1
      residn=resid(draws(drawi,:),:)
      for t=1:nobs
         if nz == 0 then
            dyn(t,:)=residn(t,:) ;         
         else
            zt=[lt(t,:)*evec(:,1:i-1) exon(t,:)]
            dyn(t,:)=zt*b+residn(t,:) ;
         end
         lt(t+1,1:ny)=lt(t,1:ny)+dyn(t,:);
         exon(t+1,1:ny*grocer_k)=[dyn(t,:) exon(t,1:ny*(grocer_k-1))];
      end
      [flag,an,evecn,lr1n,lr2n,pin]=johansen_eigen(dyn,exon(1:nobs,:),lt(1:nobs,:))
      if flag == 'not OK' then
         draws(drawi,:)=floor(grand(1,nobs,'unf',1,nbresid+1))
         drawi=drawi-1
      else
         lr1_boot(drawi,i)=lr1n(i)
         lr2_boot(drawi,i)=lr2n(i)
         b2=ols0(dyn,[lt(1:nobs,:)*evecn exon(1:nobs,:)])
         alpha2=b2(1:ny,:)
         gam2=b2(ny+1:$,:)
         residn_b=(dyn-lt(1:nobs,:)*evecn*alpha2-exon(1:nobs,:)*gam2)*sqrt(nobs/(nobs-size(b,1)))
         residn_fb=residn_b(draws(grocer_NBoot+drawi,:),:)
 
         b2c=ols0(dyn,[lt(1:nobs,:)*evecn(:,1:i-1) exon(1:nobs,:)])
         alpha2c=b2c(1:i-1,:)
         gam2c=b2c(i:$,:)
 
         for t=1:nobs
            if nz == 0 then
               dyn_fb(t,:)=residn_fb(t,:) ;         
            else
               dyn_fb(t,:)=[lt(t,:)*evecn(:,1:i-1) exon(t,:)]*[alpha2c;gam2c]+residn_fb(t,:) ;
            end
            lt(t+1,1:ny)=lt(t,1:ny)+dyn_fb(t,:);
            exon(t+1,1:ny*grocer_k)=[dyn_fb(t,:) exon(t,1:ny*(grocer_k-1))];
         end
         [flag,a_fb,evec_fb,lr1_fb,lr2_fb,pi_fb]=johansen_eigen(dyn_fb,exon(1:nobs,:),lt(1:nobs,:))
         if flag == 'not OK' then
            draws(grocer_NBoot+drawi,:)=floor(grand(1,nobs,'unf',1,nbresid+1))
            drawi=drawi-1
         else
            lr1_boot2(drawi,i)=lr1_fb(i)
            lr2_boot2(drawi,i)=lr2_fb(i)
         end
      end
   end
 
   lr1_boot(:,i)=gsort(lr1_boot(:,i),'g','i')
   lr1_p(i)=sum(lr1_boot(:,i) > lr1(i))/grocer_NBoot
   lr1_boot2(:,i)=gsort(lr1_boot2(:,i),'g','i')
   Q_B=lr1_boot2(max(floor(grocer_NBoot-lr1_p(i)*grocer_NBoot),1),i)
   lr1_p2(i)=sum(lr1_boot(:,i) > Q_B)/grocer_NBoot
 
   lr2_boot(:,i)=gsort(lr2_boot(:,i),'g','i')
   lr2_p(i)=sum(lr2_boot(:,i) > lr2(i))/grocer_NBoot
   lr2_boot2(:,i)=gsort(lr2_boot2(:,i),'g','i')
   Q_B=lr2_boot2(max(floor(grocer_NBoot-lr2_p(i)*grocer_NBoot),1),i)
   lr2_p2(i)=sum(lr2_boot(:,i) > Q_B)/grocer_NBoot
 
end
 
result(1)($+1)='NBoot'
result(1)($+1)='cvt'
result(1)($+1)='cvm'
result(1)($+1)='p trace'
result(1)($+1)='p lmax'
result(1)($+1)='p double trace'
result(1)($+1)='p double lmax'
result('NBoot')=NBoot
result('cvt')=lr1_boot(int([0.9 0.95 0.99]*grocer_NBoot),:)
result('cvm')=lr2_boot(int([0.9 0.95 0.99]*grocer_NBoot),:)
result('p trace')=lr1_p
result('p lmax')=lr1_p
result('p double trace')=lr1_p2
result('p double lmax')=lr2_p2


endfunction
