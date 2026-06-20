function reso=reliability(res,w,p,np)
 
// PURPOSE: estimate the reliability of the variables in a
// regression
// ------------------------------------------------------------
// INPUT:
// * res = the results of a -univariate- regression
// * w = a (1 x 4) vector of reliability outcome:
//   - w(1) = significant only on a sub-sample
//   - w(2) = significant only on the sub-samples
//   - w(3) = significant only on the whole sample
//   - w(4) = significant on the whole sample and on a
//            sub_sample
// * p = a size level
// * np = 'noprint' if the user does not want to print the
//   results
// ------------------------------------------------------------
// OUTPUT:
// reso = a tlist with:
// - res('meth')='reliability'
// - res('namey')= a string, the name of the endogenous
// variable in the regression
// - res('namex')= the string vector of the names of the
// exogenous variables in the regression
// - res('reliab')= the real vector of the reliability of the
// coefficients
// ------------------------------------------------------------
// Copyright: Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
 
if nargin < 4 then
   prt=%t
   if nargin <3 then
      p=0.05
   end
else
   if np ~= 'noprint' then
      warning('argin 4 in should be ''noprint''')
   end
   prt=%f
end
 
y=res('y')
x=res('x')
nvar=sum(res('nvar'))
meth=res('meth')
nobs=res('nobs')
namex=res('namex')
halft=floor(nobs/2)
x1=x(1:halft,:)
x2=x(halft+1:nobs,:)
y1=y(1:halft,:)
y2=y(halft+1:nobs,:)
nx=size(x,2)
 
select meth
case 'ols' then
   run1='r1=ols1(y1,x1)'
   run2='r2=ols1(y2,x2)'
 
case 'Newey-West''s HAC' then
   run1='r1=nwest1(y1,x1)'
   run2='r2=nwest1(y2,x2)'
 
case 'restricted var' then
   for j=2:res('neqs')
      x1=[x1 ; x(nobs*(j-1)+[1:halft],:)]
      x2=[x2 ; x(nobs*(j-1)+[halft+1:nobs],:)]
   end
 
   crit=res('crit')
   itmax=res('itmax')
   run1='r1=sur1(y1,x1,crit,itmax)'
   run2='r2=sur1(y2,x2,crit,itmax)'
 
case 'probit' then
   run1='r1=probit2(y1,x1)'
   run2='r2=probit2(y2,x2)'
 
case 'panel with random effects' then
   indiv=res('individual')
   indiv1=indiv(1:halft,:)
   indiv2=indiv(halft+1:nobs,:)
   glsmeth=res('gls estimation method')
   run1='r1=prandom1(glsmeth,y1,indiv1,x1,[])'
   run2='r2=prandom1(glsmeth,y2,indiv2,x2,[])'
 
case 'panel with fixed effects' then
   indiv=res('individual')
   nindiv=res('nb. indiv')
   namex=namex(1+nindiv:$)
   indiv1=indiv(1:halft,:)
   indiv2=indiv(halft+1:nobs,:)
   x1=x1(:,nindiv+1:$)
   x2=x2(:,nindiv+1:$)
 
   if or (res(1) == 'hac') then
      if res('hac') == 'clustered' then
         run1='r1=pfixed_hac1(y1,indiv1,x1,1,res(''win''))'
         run2='r2=pfixed_hac1(y2,indiv2,x2,1,res(''win''))'
      else
         run1='r1=pfixed_hac1(y1,indiv1,x1,2,res(''win''))'
         run2='r2=pfixed_hac1(y2,indiv2,x2,2,res(''win''))'
      end
 
   else
      run1='r1=pfixed1(y1,indiv1,x1,[])'
      run2='r2=pfixed1(y2,indiv2,x2,[])'
   end
   nvar=size(x1,2)
 
case 'panel pooled' then
   if or (res(1) == 'hac') then
      if res('hac') == 'clustered' then
         indiv=res('individual')
         nindiv=res('nb. indiv')
         indiv1=indiv(1:halft,:)
         indiv2=indiv(halft+1:nobs,:)
         run1='r1=ppooled_hac1(y1,indiv1,x1,1,res(''win''))'
         run2='r2=ppooled_hac1(y2,indiv2,x2,1,res(''win''))'
      else
         run1='r1=ppooled_hac1(y1,indiv1,x1,2,res(''win''))'
         run2='r2=ppooled_hac1(y2,indiv2,x2,2,res(''win''))'
      end
 
   else
      run1='r1=ppooled1(y1,x1)'
      run2='r2=ppooled1(y2,x2)'
   end
   nvar=size(x1,2)
 
 
else
   error(meth+' non available for a reliability test')
 
end
 
if or(svd(x1) < size(x1,2)*%eps) then
   reso='variables are colinear over the first half of the data'
 
elseif or(svd(x2) < size(x2,2)*%eps) then
   reso='variables are colinear over the second half of the data'
 
else
   // retrieve the estimation results over each sub-sample
   execstr(run1)
   execstr(run2)
   reliab=zeros(nvar,1)
   pall=bool2s(real(res('pvalue')($-nvar+1:$)) < p)
   p1=bool2s(real(r1('pvalue')($-nvar+1:$)) < p)
   p2=bool2s(real(r2('pvalue')($-nvar+1:$)) < p)
   reliab=w(1)*(p1+p2)+...
          (w(2)-2*w(1)) .*p1 .*p2+w(3)*pall+...
          (w(4)-w(3)-w(1)) .*pall .*(p1 .*(1-p2)+p2 .*(1-p1))+...
          (1-w(4)-w(1)) .*pall .*p1 .*p2
 
   reso=tlist(['results';'meth';'namey';'namex';'reliab'],...
   'reliability',res('namey'),namex,reliab)
 
   if prt then
      prt_reliab(reso)
   end
end
 
endfunction
