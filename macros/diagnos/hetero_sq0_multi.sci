function [lmf,pvalue]=hetero_sq0_multi(res,np)
 
// PURPOSE: LM multivariate test of heteroskedasticity
// ------------------------------------------------------------
// INPUT:
// * res = results tlist from a first stage estimation
// * np = unused argument (but put here for compatibility with
//   other testing functions)
// ------------------------------------------------------------
// OUTPUT:
//  * lmf = value of the statistic
//  * pvalue = its p-value
// ------------------------------------------------------------
// REFERENCE:
// Doornik (1996): "Testing vector error autocorrelation and
// heteroscedasticity"". Mimeo, University of Oxford,
// http://www.doornik.com/research/vectest.pdf.
// ------------------------------------------------------------
//// Copyright: Eric Dubois 2013-2019
// http://grocer.toolbox.free.fr/grocer.html
 
if or(res('meth') == ['ms var' ; 'ms regression' ; 'ms mean'])
   u=res('smoothed resid')
   T=res('nobs')
   neqs=res('nendo')
   x=[res('xmat') , res('zmat')]
 
else
   u=res('resid')
   T=res('nobs')
   neqs=res('neqs')
   x=res('x')
end
 
// rescale the residuals to obtain better estimates
v0=varcov0(u)
u=u ./ (ones(T,1) .*. sqrt(real(diag(v0)))')
ud=u .^ 2
for i=1:neqs-1
   ud=[ud ((ones(1,neqs-i) .*. u(:,i)) .* u(:,i+1:neqs))]
end
 
if size(x,1) == T then
   sigma0=(ud-(ones(T,1) .*. mean0(ud,'r')))'*(ud-(ones(T,1) .*. mean0(ud,'r')))
   xd=[ones(T,1) x (x .^2)]
   for j=size(xd,2):-1:2
      mat_diff=xd(:,1:j-1)-(xd(:,j) .*. ones(1,j-1))
      if or(sum(abs(mat_diff),'r') == 0) then
         xd(:,j)=[]
      end
   end
 
   betad=lsq(xd,ud)
   residd=ud-xd*betad
   hbar=size(xd,2)-1
 
else
   xfull=[]
   indsuppr=[]
   residd=zeros(T,neqs*(neqs+1)/2);
   hbar=0
   xd=[]
   nx=zeros(neqs+1,1);
   for i=1:neqs
      xi=x(1+(i-1)*T:i*T,:)
      xi=xi(:,sum(abs(xi),'r')~=0)
      if isempty(xi) then
         indsuppr=[indsuppr , i]
         xd_i=ones(T,1)
         nx(i+1)=nx(i)+1
      else
         xd_i=[ones(T,1) xi (xi .^ 2)]
         for j=size(xd_i,2):-1:2
            mat_diff=xd_i(:,1:j-1)-(xd_i(:,j) .*. ones(1,j-1))
            if or(sum(abs(mat_diff),'r') == 0) then
               xd_i(:,j)=[]
            end
         end
         nxi=size(xd_i,2)
         nx(i+1)=nxi+nx(i)
         hbar=hbar+nxi-1
//         betad=lsq(xd_i,ud(:,i))
//         residd(:,i)=ud(:,i)-xd_i*betad
      end
      xd=[xd xd_i ]
   end
 
   k=i+1
   for i=1:neqs-1
      n1=nx(i)+1
      n2=nx(i+1)
      xd_i=xd(:,n1:n2)
      for j=i+1:neqs
         xd_ij=[xd_i xd(:,nx(j)+2:nx(j+1)) ]
         if size(xd_ij,2) == 1 then
            indsuppr=[indsuppr , k]
         else
            for l=size(xd_ij,2):-1:2
               mat_diff=xd_ij(:,1:l-1)-(xd_ij(:,l) .*. ones(1,l-1))
               if or(sum(abs(mat_diff),'r') == 0) then
                  xd_ij(:,l)=[]
               end
            end
            hbar=hbar+size(xd_ij,2)-1
            k=k+1
            nx=[nx;nx($)+size(xd_ij,2)]
            xd=[xd xd_ij]
         end
      end
   end
   ud(:,indsuppr)=[]
   nres=size(ud,2)
   xfull=[xd(:,nx(1)+1:nx(2)) ; zeros(T*(nres-1),nx(2)-nx(1))]
   for i=2:nres
      ncols=nx(i+1)-nx(i)
      xfull=[xfull [zeros(T*(i-1),ncols) ; xd(:,nx(i)+1:nx(i+1)) ; zeros(T*(nres-i),ncols)]]
   end
   sigma0=real((ud-(ones(T,1) .*. mean0(ud,'r')))'*(ud-(ones(T,1) .*. mean0(ud,'r'))))
   sqrtsigma=real(sigma0^(-0.5)).*.eye(T,T)
   ud1=ud(:)
   betad=ols0(sqrtsigma*ud1,sqrtsigma*xfull)
   residd=matrix(ud1-xfull*betad,T,nres)
   hbar=hbar/neqs
end
 
sigmad=residd'*residd
g=0.5*neqs*(neqs+1)
r=sqrt(((g*hbar)^2-4)/(g^2+hbar^2-5))
N=T-1-hbar-0.5*(g-hbar+1)
q=0.5*g*hbar-1
lmf=(real(det(sigma0)/det(sigmad))^(1/r)-1)*(N*r-q)/round(g*hbar)
 
pvalue=1-cdff("PQ",lmf,round(g*hbar),round(N*r-q))
 
endfunction
