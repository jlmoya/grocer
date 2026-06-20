function [llike,grad,ind]=probit_like(b,ind)
 
// PURPOSE: evaluate logit log-likelihood
// ------------------------------------------------------------
// INPUT:
// * b = parameter vector (k x 1)
// * y = dependent variable vector (n x 1)
// * x = explanatory variables matrix (n x m)
// ------------------------------------------------------------
// OUTPUT:
// -log(pseudo-likelihood)
// ------------------------------------------------------------
// NOTE: this function returns a scalar
//       k ~= m because we may have additional parameters
//           in addition to the m bhat's (e.g. sigma)
//-----------------------------------------------------
// REFERENCES: Green, 1997 page 883
//-----------------------------------------------------
// Copyright: Eric Dubois 2011-2013
// http://grocer.toolbox.free.fr/grocer.html
 
[nobs,nvar]=size(x)
// to avoid taking the log of 0, minor the PDF with sqrt(%eps)
// and major it with 1-sqrt(%eps)
cdf = min(max(cdfnor("PQ",x*b,zeros(nobs,1),ones(nobs,1)),sqrt(%eps)),1-sqrt(%eps))
cdf1=cdf(y==0)
cdf2=cdf(y==1)
like=zeros(nobs,1)
like(y==0)=log(1-cdf1)
like(y==1)=log(cdf2)
llike = -sum(like);
 
// calculate the pdf, taking into account the fact that cdf ahs been
// limited to the segment [sqrt(%eps);1-sqrt(%eps)]:
// 0.00000021338358020222500=exp(-(cdfnor("x",0,1,sqrt(%eps),1-sqrt(%eps)))^2/2
pdf=1/sqrt(2*%pi)*max(exp(-(x*b).^2/2),0.00000021338358020222500)
 
aux=0*y
aux(y==1) = pdf(y==1) ./ cdf2
aux(y==0) = -pdf(y==0) ./ (1-cdf1)
grad=-x' *aux
 
endfunction
