function [minuslik,gra,ind]=box_lik(lam,ind,y,x,mod)
 
// PURPOSE: evaluate Box-Cox model likelihood function
//----------------------------------------------------
// USAGE: like = box_lik(b,y,x,model)
// where:  lam = box-cox parameter (scalar)
//           y = dependent variable vector (un-transformed)
//   x = explanatory variables matrix (un-transformed)
//       model = 0 for y-transform only, 1 for y,x both transformed
// NOTE: x should contain intercept vector in 1st column (if desired)
//----------------------------------------------------
// RETURNS: lik = -log likelihood function
 
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
 
[n,k] = size(x);
ys = boxc_trans(y,lam);
gra=0
if mod==1 then
  // see if an intercept term exists in the model
  prescte=%f
  for i=1:k
     diff=max(x(:,i))-min(x(:,i))
     if diff == 0 then
        prescte=%t
     end
  end
  if prescte then
     xtrans = boxc_trans(x(:,2:k),lam);
     xs = [ones(n,1),xtrans];
     bhat = inv(xs'*xs)*xs'*ys;
     resid = ys-xs*bhat;
     sige = resid'*resid/n;
     for j=2:k
        if lam ~= 0 then
           gra=gra-(x(:,j).^lam.*log(x(:,j))/lam-(x(:,j).^lam-1)/lam^2)'*...
               resid*bhat(j)/sige
        else
           gra=gra-0.5*(log(x(:,j)).^2)'*(ys-xs*bhat)*bhat(j)/sige
        end
     end
  else
      // no intercept
      warning('your model has no constant')
      xs = boxc_trans(x,lam);
      bhat = inv(xs'*xs)*xs'*ys;
      resid = ys-xs*bhat;
      sige = resid'*resid/n;
      for j=1:k
        if lam ~= 0 then
           gra=gra-(x(:,j).^lam.*log(x(:,j))/lam-(x(:,j).^lam-1)/lam^2)'*...
               resid*bhat(j)/sige
        else
           gra=gra-0.5*(log(x(:,j)).^2)'*(ys-xs*bhat)*bhat(j)/sige
        end
      end
   end
   if lam ~= 0 then
      gra=gra-sum(log(y))+(y .^lam.*log(y)/lam-(y .^lam-1)/lam^2)'*resid/sige
   else
      gra=gra-sum(log(y))+0.5*(log(y).^2)'*resid/sige
   end
elseif mod==0 then
   write(%io(2),'traitement du cas mod==0')
   xs = x;
   bhat = inv(xs'*xs)*xs'*ys;
   resid = ys-xs*bhat;
   sige = resid'*resid/n;
   write(%io(2),'valeur de sige : '+string(sige))
   if lam ~= 0 then
      gra=-sum(log(y))+(y.^lam.*log(y)/lam-(y.^lam-1)/lam^2)'*resid/sige
   else
      gra=-sum(log(y))+0.5*(log(y).^2)'*resid/sige
   end
end
 
 
minuslik =n/2*log(2*%pi)-(lam-1)*sum(log(y))+n/2*log(sige);
write(%io(2),'valeur de la log-vrais : '+string(minuslik))
 
 
endfunction
