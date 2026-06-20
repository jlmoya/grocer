function [betas,sigmas]=smoothing(F,betat,betaf,sigmat,sigmaf,begsmooth)
 
// PURPOSE: provide smoothed values from a Kalman filtering
// ------------------------------------------------------------
// INPUT:
// * F = transition matrix
// * betat = vector of filtered beta at date t with the
//   information available at date t (beta(t|t))
// * betaf = vector of filtered beta at date t with the
//   information available at date t-1 (beta(t|t-1)
// * sigmat = vector of filtered variances at date t with the
//   information available at date t (sigma(t|t))
// * sigmat = vector of filtered variances at date t with the
//   information available at date t-1 (sigma(t|t-1))
// * begsmooth = first observation where to calculate smoothed
//   values
// ------------------------------------------------------------
// OUTPUT:
// * betas = vector of smoothed beta at date t with the
//   information available at date t-1 (beta(t|T)
// * sigmat = vector of smoothed variances at date t with the
//   information available at date t (sigma(t|T))
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
[nargout,nargin] = argn(0)
[n,k] = size(betat)
 
betas=betat(begsmooth:n,:)
sigmas=ones(n-begsmooth+1,k,k)
sigmas(n-begsmooth+1,:,:)=matrix(sigmat(n,:),k,k)
 
for iter=n-1:-1:begsmooth
   m1=matrix(sigmat(iter,:),k,k)
   m2=matrix(sigmaf(iter,:),k,k)
   m3=matrix(sigmas(iter-begsmooth+2,:,:),k,k)
   [u,s,v]=svd(m2)
   mt=m1*F'*u* diag(ones(k,1) ./ diag(s)) *v'
   betas(iter-begsmooth+1,:)=betat(iter,:)+(betas(iter-begsmooth+2,:)-betaf(iter,:))*mt'
   sigmas(iter-begsmooth+1,:,:)=m1+mt'*(m3-m2)*mt
end
 
endfunction
