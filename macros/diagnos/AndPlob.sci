function resout = AndPlob(resin,t1,t2,varargin)
 
// PURPOSE: perform the Andrews and Andrews and Ploberger
// stability tests, with asymptotic and bootstrapped p-values
// ------------------------------------------------------------
// INPUT:
// * resin = an ols result tlist
// * t1 = starting breakpoint index or percentage,
//        may be integer in [k+1,T-k-1] or percentage in (0,1).
// * t2 = ending breakpoint index or percentage,
//        may be integer in [k+1,T-k-1] or percentage in (0,1),
//        must equal or exceed t1.
//   Note: For Sup test, Andrews recommends t1=.15 and t2=.85
//         For Exp test, Andrews-Ploberger recommend t1=.02 and
//         t2=.98
// * varargin = optional arguments that can be:
//   - 'noprint' if the user does not want to print the results
//   - 'nboost=xx' where xx is the number of bootstrap
//     replications (default=1000)
// ------------------------------------------------------------
// OUTPUT:
// * resout = a result tlist, with
//   . resout('meth')  = 'AndPlob'
//   . resout('res all') = the original ols tlist
//   . resout('res 1') = the estimation results over the period
//                       before the break
//   . resout('res 2') = the estimation results over the period
//                       after the break
//   . resout('res 2') = the estimated break point
//   . resout('SupF') = Andrews Sup F statistics
//   . resout('ExpF') = Andrews and Ploberger Exponential F
//                      statistics
//   . resout('AveF') = Andrews and Ploberger Average F
//                      statistics
//   . resout('SupF pvalues') = Andrews Sup F p-values:
//                            - asymptotic
//                            - boostrapped under homoskedasticity
//                            - boostrapped under heteroskedasticity
//   . resout('ExpF')  = Andrews and Ploberger Exponential F p-values
//                            - asymptotic
//                            - boostrapped under homoskedasticity
//                            - boostrapped under heteroskedasticity
//   . resout('AveF')  = Andrews and Ploberger Average F p-values
//                            - asymptotic
//                            - boostrapped under homoskedasticity
//                            - boostrapped under heteroskedasticity
//   . resout('nboost') = # of boostrap draws
// ------------------------------------------------------------
// REFERENCES:
// Hansen B. (2000): "Testing for Structural Change in Conditional
// Models.",
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011-2015
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a matlab program by:
// Bruce E. Hansen
// Department of Economics
// Social Science Building
// University of Wisconsin
// Madison, WI 53706-1393
// bhansen@ssc.wisc.edu
// http://www.ssc.wisc.edu/~bhansen/
 
nboost=1000
prt=%t
for i=length(varargin):-1:1
   argi=varargin(i)
   if tyepof(argi) == 'string' then
      argi=strsubst(argi,' ','')
      if part(argi,1:7) == 'nboost=' then
         execstr(argi)
      elseif argi == 'noprint' then
         prt=%f
      end
   end
end
 
r1 = 10;
r2=int(nboost/r1)
if r2 ~= nboost/r1 then
   warning('# of boostrap draws have been rounded to: '+string(r2*r1))
end
 
// recover from the result tlist various useful data
y=resin('y')
x=resin('x')
e=resin('resid')
[n,k]= size(x);
xx=x'*x
xe = x .*(e*ones(1,k));
ee = resin('sigu')
xxi=resin('vcovar')/resin('sige')
 
if t1 < 1 then
   n1 = floor(n*t1);
   tau1 = t1;
else
   n1 = t1;
   tau1 = t1/n;
end;
 
if t2 < 1 then
   n2 = floor(n*t2);
   tau2 = t2;
else
   n2 = t2;
   tau2 = t2/n;
end;
 
 
if n1 <= k then
   write(%io(2),"ERROR:   Starting Sample is smaller than Number of Parameters",'(a)');
   write(%io(2),"            You need to select a larger value for t1",'(a)');
end;
if n2 >= n-k then
   write(%io(2),"ERROR:   Ending Sample is smaller than Number of Paramters",'(a)');
   write(%io(2),"            You need to select a smaller value for t2",'(a)');
end;
 
f = zeros(n,1);
m=x(1:n1-1,:)'*x(1:n1-1,:);
mi=inv(m);
msi=inv(xx-m);
sn=sum(xe(1:n1-1,:),'r')';
 
for ib = n1:n2
   xi=x(ib,:)';
   xim=xi'*mi;
   mi=mi-((xim'*xim)'/(1+xim*xi)')';
   xim=xi'*msi;
   msi=msi+((xim'*xim)'/(1-xim*xi)')';
   sn=sn+(xe(ib,:)');
   q=sn'*msi*xx*mi*sn;
   f(ib)=q*(n-k*2)/(ee-q);
end;
[supf,im]=max(f);
avef=mean(f(n1:n2));
expf=log(mean(exp(f(n1:n2)/2)));
 
// Standard P-Value %
l_0 = tau2*(1-tau1)/(tau1*(1-tau2));
pi_0 = 1/(1+sqrt(l_0));
pv_s = pv_sup(supf,k,l_0);
pv_e = pv_exp(expf,k,l_0);
pv_a = pv_ave(avef,k,l_0);
 
x1=x(1:im,:);
x2=x(im+1:n,:);
y1=y(1:im);
y2=y(im+1:n);
rols1=ols2(y1,x1)
rols2=ols2(y2,x2)
// saves the names, the bounds if the regression involves ts
rols1(1)($+1) = 'prests'
rols1(1)($+1) = 'namex'
rols1(1)($+1) = 'namey'
rols1(1)($+1) = 'dropna'
rols1('prests')=resin('prests')
rols1('namex')=resin('namex')
rols1('namey')=resin('namey')
rols1('dropna')=resin('dropna')
 
rols2(1)($+1) = 'prests'
rols2(1)($+1) = 'namex'
rols2(1)($+1) = 'namey'
rols2(1)($+1) = 'dropna'
rols2('prests')=resin('prests')
rols2('namex')=resin('namex')
rols2('namey')=resin('namey')
rols2('dropna')=resin('dropna')
 
em=[rols1('resid') ; rols2('resid')]
 
if resin('prests') then
   ball=resin('bounds')
   ballnum=date2num_m(ball)
   dates=[ballnum(1):ballnum(2)]
   for i=2:size(ballnum,1)/2
      dates=[dates ballnum(i*2+1):ballnum(i*2+2)]
   end
   dates=dates'
   fq=date2fq(ball(1))
   rols1(1)($+1) = 'bounds'
   rols2(1)($+1) = 'bounds'
   rols1('bounds')=[ball(ballnum<ballnum(1)+im) ; num2date(dates(im),fq)]
   rols2('bounds')=[num2date(dates(im+1),fq) ; ball(ballnum>ballnum(1)+im)]
 
   if resin('dropna') then
      rols1(1)($+1)='nonna'
      rols1('nonna')=nonna
      rols2(1)($+1)='nonna'
      rols2('nonna')=nonna
   end
end
 
 
// Fixed Regressor Bootstrap   %
supfb = zeros(r2,r1);
expfb = zeros(r2,r1);
avefb = zeros(r2,r1);
supfh = zeros(r2,r1);
expfh = zeros(r2,r1);
avefh = zeros(r2,r1);
 
for ri = 1:r1
   u=grand(n,r2,'nor',0,1)
   euf=u-x*xxi*(x'*u);
   eef = sum(euf .^2,'r')';
   ff = zeros(n,r2);
   snf =x(1:n1-1,:)'*euf(1:n1-1,:);
 
   uh = u .*(em*ones(1,r2));
   euh=uh-x*xxi*(x'*uh);
   eeh = sum(euh .^2,'r')';
   ffh = zeros(n,r2);
   snh = x(1:n1-1,:)'*euh(1:n1-1,:);
 
   mf = x(1:n1-1,:)'*x(1:n1-1,:);
   mif = inv(mf);
   msif = inv(xx-mf);
 
   for ib = n1:n2
      xif=x(ib,:)';
      ximf=xif'*mif;
      mif=mif-(ximf'*ximf)/(1+ximf*xif);
      ximf=xif'*msif;
      msif=msif+(ximf'*ximf)/(1-ximf*xif);
      snf=snf+xif*euf(ib,:);
      qf = sum(snf .*(((msif*xx)*mif)*snf),'r')';
      ff(ib,:)=(qf./(eef-qf))';
      snh=snh+xif*euh(ib,:);
      qf = sum(snh .*(((msif*xx)*mif)*snh),'r')';
      ffh(ib,:)=(qf./(eeh-qf))';
   end;
 
   ftf = ff(n1:n2,:)*(n-k*2);
   supfb(:,ri) = (max(ftf,'r')'>supf);
   expfb(:,ri) = (mean(exp(ftf/2),'r')'>exp(expf));
   avefb(:,ri) = (mean(ftf,'r')'>avef);
 
   ftf = ffh(n1:n2,:)*(n-k*2);
   supfh(:,ri) = (max(ftf,'r')'>supf);
   expfh(:,ri) = (mean(exp(ftf/2),'r')'>exp(expf));
   avefh(:,ri) = (mean(ftf,'r')'>avef);
 
end;
 
supfb = mean(supfb)
expfb = mean(expfb);
avefb = mean(avefb);
 
supfh = mean(supfh);
expfh = mean(expfh);
avefh = mean(avefh);
 
resout=tlist(['results';'meth';'res all';'res 1';'res 2';'break point';...
'SupF';'ExpF';'AveF';'SupF pvalues';'ExpF pvalues';'AveF pvalues';
'nboost'],...
'AndPlob',resin,rols1,rols2,im,supf,expf,avef,[pv_s ; supfb ; supfh],...
[pv_e ; expfb ; expfh],[pv_a ; avefb ; avefh],r1*r2)
 
prt_AndPlob(resout)
 
endfunction
