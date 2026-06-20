function [g,dht,gradt]=garch_grad2(parm,nar,nma,y,x)
 
// PURPOSE: gradient for garch model
// ------------------------------------------------------------
// INPUT:
// * parm = a vector of parmeters
//        parm(1) = beta 1
//        parm(2) = beta 2
//        .
//        .
//        .
//        parm(k) = beta k
//        parm(k+1) = a0
//        parm(k+2) = ar(1)
//        .
//        .
//        .
//        parm(k+nar+1) = ar(nar)
//        parm(k+nar+1) = ma(1)
//        .
//        .
//        .
//        parm(k+nar+nma+1) = ar(nma)
// * y = (n x 1) vector of the endogenous variable
// * x = (n x k) vector of the exogenous variables
// * nar = # of ar coefficient in the garch model
// * nma = # of ma coefficient in the garch model
// ------------------------------------------------------------
// OUTPUT:
// * g = (k+nar+nma+1 x 1) -gradient at param
// * dht = (nobs x nar+nma+1) derivative of sigt w.r.t a0, ar,
//          ma
// * scores = (k+nar+nma+1 x 1) sub-gradient at each date
// ------------------------------------------------------------
// REFERENCES: Fiorentini, Calzolari et Panattoni (1996):
// Journal of Applied Econometrics, col1 ,n�4, pp 399-417
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
n = size(y,1); // in case of x is empty
k = size(x,2);
 
b=parm(1:k)
// transform parameters
[parmt] = garch_trans(parm,k);
a0=parmt(k+1)
ar=parmt(k+2:k+1+nar)
ma=parmt(k+2+nar:k+1+nar+nma)
 
// compute residuals
if k == 0 then
   res0=y
else
   res0 = y-x*b;
end
sig = res0'*res0/n
ser=sqrt(sig)
xresT=res0'*x/n
 
res=[ser*ones(nma,1) ; res0]
res2=res .* res
sigt = [sig*ones(nar,1) ; zeros(n,1)]
 
// equation (11) in Fiorentini, Calzolari et Panattoni
c= [(-2*ones(nar,1) .*. xresT) ; zeros(n,k)]
d=zeros(n+nar,1)
e=zeros(n+nar,nar)
f=zeros(n+nar,nma)
 
// equation (7) in Fiorentini, Calzolari et Panattoni
for i = 1:n
   sigt(i+nar) = parmt(k+1:k+1+nar+nma)'*[1 ; sigt(i+nar-1:-1:i) ;...
             res(i+nma-1:-1:i).*res(i+nma-1:-1:i)];
   d(i+nar)=1+ar'*d(i+nar-1:-1:i)
   e(i+nar,:)=sigt(i+nar-1:-1:i)'+ar'*e(i+nar-1:-1:i,:)
   f(i+nar,:)=res2(i+nma-1:-1:i,:)'+ar'*f(i+nar-1:-1:i,:)
 
end
 
// equation (13) in Fiorentini, Calzolari et Panattoni
for i=1:nma
   xres=ones(nma,1) .*. xresT
   for j=1:i-1
      xres(j,:)=res0(i-j)*x(i-j,:)
   end
   c(nar+i,:)=-2*ma'*xres+ar'*c(i+nar-1:-1:i,:)
end
 
xres=zeros(nma,k)
for i=nma+1:n
   for j=1:nma
      xres(j,:)=res0(i-j)*x(i-j,:)
   end
   c(nar+i,:)=-2*ma'*xres+ar'*c(i+nar-1:-1:i,:)
end
 
// adjust the derivative to take into account the
// fact that a0 is squared and ar and ma are exponetiated and
// summed
sigt=sigt(1+nar:n+nar,:)
base=ones(1,k+1+nar+nma).*.(((res0 .^ 2)./sigt-1)./(2*sigt))
 
 
dht=[c';d';e';f']'
dht=dht(1+nar:n+nar,:)
gradt=base.*dht+[(ones(1,k) .*. (res0 ./ sigt)).*x , zeros(n,1+nar+nma)]
 
// compute the derivative of [ar;ma] with respect to...
// parm(1+nar+nma)
D=diag([ar ;ma])-[ar ; ma]*[ar ; ma]'
 
g= -sum(gradt(1:n,:),'r')
g=[eye(k,k) zeros(k,1+nar+nma);...
   zeros(1,k) 2*parm(k+1) zeros(1,nar+nma) ; ...
   zeros(nar+nma,k+1) D]*g'
 
endfunction
