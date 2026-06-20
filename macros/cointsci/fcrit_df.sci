function pvalue=fcrit_df(tstat,precrt,nobs,db,nametab,np)

global GROCERDIR;
 
load(db)
load(GROCERDIR+'/data/mackinnon_probs.dat')
execstr('nametab='+nametab)
nz=nametab(1,1)
nreg=nametab(1,2)
model=nametab(1,3)
minsize=nametab(1,4)
nvar=size(nametab,2)-1
regress1=(1/nobs).^[0:nvar-1]
 
tab_tstat=nametab(2:$,1:nvar)*regress1'
wght=nametab(2:$,nvar+1)
 
[a,index_p]=min((tstat-tab_tstat).^2)
nph=floor(np/2)
 
if (221-index_p) > np/2 then
 
   if index_p > np/2 then
      vecp=index_p-floor(np/2):index_p+floor(np/2)
   else
      np=max(index_p+nph,nph+1)
      vecp=1:np
   end
 
   omega=zeros(np,np)
   for i=1:np
      for j=i:np
         ic=vecp(i)
         jc=vecp(j)
         top=mackinnon_probs(ic)*(1-mackinnon_probs(jc))
         bot=mackinnon_probs(jc)*(1-mackinnon_probs(ic))
         omega(i,j)=wght(ic)*wght(jc)*sqrt(top/bot)
         omega(j,i)=omega(i,j)
      end
   end
 
else
   np=max(222-index_p+nph,5)
   vecp=222-np:221
   omega=eye(np,np)
 
end
 
cnorm=mackinnon_probs(vecp,2)
crit=tab_tstat(vecp)
x=[ones(np,1) crit (crit .^2) (crit .^3)]
 
sqrtom=omega .^(-0.5)
r=ols1(sqrtom*cnorm,sqrtom*x)
nx=4
 
if abs(r('tstat')(4)) < precrt then
   nx=3
   x=x(:,1:3)
   r=ols1(sqrtom*cnorm,sqrtom*x)
end
 
crfit=(tstat .^ [0:nx-1])*r('beta')
pvalue=cdfnor("PQ",crfit,0,1)
 
endfunction
