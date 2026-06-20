function [a,d1,d2,fdr]=kern(serie,vmin,vmax,nbpts)
 
// PURPOSE: estimate the cdf of a series by the method of the
// gaussian and Epanechnikov kernel
// ------------------------------------------------------------
// INPUT:
// * serie = a (N X 1) vector
// * vmin = a scalar, the minimum of the distribution
// * vmax = a scalar, the maximum of the distibution
// * vmax = a scalar, the # of points bewteen vmin and vmax
// ------------------------------------------------------------
// OUTPUT:
// * a = trigger points of the probability distribution function
//   probabilities
// * d1 = gaussian kernel
// * d2 = Epanechnikov kernel
// * fdr = cumulative distibution function associated to the
//   series
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adapted from a Gauss programm by J. Bardaji
// and F. Tallet
 
 
nb_noy=2;
n=size(serie,1);
sigma=stdc(serie)*sqrt((n-1)/n);
h=(4/3)^(0.2)*sigma*n^(-0.2);
pas=(vmax-vmin)/nbpts;
 
// a is the vector over which the distibution is calcualted
// and d1 and 2 contains the pdf of respectively the gaussian
// and Epanechnikov kernel
a=seqa(vmin,pas,nbpts);
d1=zeros(nbpts,1);
d2=zeros(nbpts,1);
 
for i =1:nbpts
// gaussian kernel d1
   u=(a(i)-serie)/h;
   k=norm_pdf(u) ;
   d1(i)=sum(k)/(n*h) ;
// Epanechnikov kernel d2 only for k > 0 */
   k=[3/(4*sqrt(5))*(1-0.2*(u.^2)) zeros(n,1)]
   k=max(k,'c') ;
   d2(i)=sum(k)/(n*h);
end
 
// Calculation of the cdf associated to the gaussian kernel
fdr0=d1(1)+cumsum([0;d1(2:$)])*pas
fdr=fdr0/fdr0($);
 
endfunction
