function [betat,betaf,sigmatt,sigmatf]=kalm_filter(grocer_param,func,y,x,F,grocer_z)
 
// PURPOSE: generate model filtered betas and variances, given
// values for Q, R and A in a kalman model:
//          y(t) = X(t)*B(t) + Z(t)*A + e(t), e(t) = N(0,R)
//          B(t) = Z(t) * B(t-1) + v(t),    v(t) = N(0,Q)
// ------------------------------------------------------------
// INPUT:
// * param = a vector of parameters (sqrt of variances)
// * func = the function which transforms the parameters into
//        the matrix of variances (Q and R) and, if necessary,
//        into the matrices of prior values
// * y = (nx1) data vector
// * x = (nxk) data matrix
// * F = transition matrix
// * z = (nxl) data matrix
// ------------------------------------------------------------
// OUTPUT:
// * betat = vector of filtered beta at date t with the
//   information available at date t (beta(t|t))
// * betaf = vector of filtered beta at date t with the
//   information available at date t-1 (beta(t|t-1)
// * ferror = vector of errors at date t (=y-x*beta(t|t))
// * sigmatt = vector of filtered variances at date t with the
//   information available at date t (sigma(t|t))
// * sigmatf = vector of filtered variances at date t with the
//   information available at date t-1 (sigma(t|t-1))
// -------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
execstr(func)
 
[n,k] = size(x)
 
ik=eye(k,k)
betat = zeros(n,k);
betaf = zeros(n,k);
sigmatt=zeros(n,k*k)
sigmatf=zeros(n,k*k)
 
betatf = grocer_priorb0;
ptf = grocer_priorv0
yhat=y-grocer_z*A
 
for iter = 1:n
   xt = x(iter,:)
 
   fcast = yhat(iter)-xt*betatf
   K = ptf*xt'/(xt*ptf*xt'+R)
   betatt = betatf+K*fcast
   ptt = (ik-K*xt)*ptf
   betatf = F*betatt
   ptf = F*ptt*F'+Q
 
   sigmatf(iter,:)=matrix(ptf,1,-1)
   sigmatt(iter,:)=matrix(ptt,1,-1)
   betaf(iter,1:k)=betatf'
   betat(iter,1:k)=betatt'
 
end
endfunction
