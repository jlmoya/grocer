function [llik]=filter_like(grocer_param,grocer_func,grocer_y,grocer_x,grocer_F,grocer_z)
 
// PURPOSE: generate model loglikelihood in a kalman model:
//          y(t) = X(t)*B(t) + e(t), e(t) = N(0,R)
//          B(t) = Z(t) * B(t-1) + v(t),    v(t) = N(0,Q)
// ------------------------------------------------------------
// INPUT:
// * param = a vector of parameters (sqrt of variances)
// * func = the function which transforms the parameters into
//        the matrix of variances (Q and R)
// * y = (nx1) data vector
// * x = (nxk) data matrix
// * F = transition matrix
// ------------------------------------------------------------
// OUTPUT:
// * llik = - log-likehood (+n*log(2*%pi))
// -------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
 
execstr(grocer_func)
 
n = size(grocer_x,1)
betatf = grocer_priorb0;
ptf = grocer_priorv0
llik=0
if isempty(grocer_z) | isempty(A) then
   yhat=grocer_y
else
   yhat=grocer_y-grocer_z*A
end
 
for iter = 1:n
   xt = grocer_x(iter,:)
 
   fcast = yhat(iter)-xt*betatf
   ptfx=ptf*xt'
   mtt=xt*ptfx+R
   K = ptfx/mtt
   betatt = betatf+K*fcast
   ptt = ptf-K*ptfx'
   betatf = grocer_F*betatt
   ptf = grocer_F*ptt*grocer_F'+Q
 
   llik=llik+(fcast^2)/mtt+log(mtt)
end
llik=0.5*llik
endfunction
