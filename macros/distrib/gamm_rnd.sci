function [gb]=gamm_rnd(nrow,ncol,m,k)
 
// PURPOSE: a matrix of random draws from the gamma
// distribution
// ------------------------------------------------------------
// INPUT:
// * nrow,ncol = the size of the matrix drawn
// * m = a parameter such that the mean of the gamma = m/k
// * k = a parameter such that the variance of the gamma = m/(k^2)
//        note: m=r/2, k=2 equals chisq r random deviate
// ------------------------------------------------------------
// OUTPUT:
// gb = an nrow x ncol matrix of random numbers from the gamma distribution
// ------------------------------------------------------------
// REFERENCES: Luc Devroye, Non-Uniform Random Variate Generation,
//            New York: Springer Verlag, 1986, ch 9.3-6.
// ------------------------------------------------------------
// Copyright: Eric Dubois
// http://grocer.toolbox.free.fr/grocer.html
// Translated to scilab from:
// Michael Gordy, 15 Sept 19
// mbgordy@athena.mit.edu
 
[nargout,nargin] = argn(0)
if nargin~=4 then
  error('Wrong # of arguments to gamm_rnd');
end
 
gb = zeros(nrow*ncol,1);
if m<=1 then
  // Use RGS algorithm by Best, p. 426
   c = 1/m;
   t = .07+.75*sqrt(1-m);
   b = 1+exp(-t)*m/t;
   for i1 = 1:nrow*ncol
      accept = 0;
      while accept==0 then
         u=rand(1,1,'uniform');
         w=rand(1,1,'uniform');
         v=b*u;
         if v<=1
            x=t*(v^c);
            accept=((w<=((2-x)/(2+x))) | (w<=exp(-x)));
         else
            x=-log(c*t*(b-v));
            y=x/t;
            accept=(((w*(m+y-m*y))<=1) | (w<=(y^(m-1))));
         end
      end
      gb(i1) = x ;
   end
 
   else
   // Use Best's rejection algorithm XG, p. 410
   b = m-1;
   c = 3*m-.75;
   for i1 = 1:nrow*ncol
      accept = %f;
      while ~accept then
         u=grand(1,1,'unf',0,1)
         v=grand(1,1,'unf',0,1)
         w=u*(1-u)
         y=sqrt(c/w)*(u-0.5)
         x=b+y
         if x >= 0
            z=64*(w^3)*v*v
            accept=(z<=(1-2*y*y/x)) ...
                    | (log(z)<=(2*(b*log(x/b)-y)))
         end
      end
 
      gb(i1) =x
   end
 
end
 
gb=matrix(gb,nrow,ncol)
gb = gb/k;
 
endfunction
