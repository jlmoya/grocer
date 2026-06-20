function x = rndnb(r,c,k,p)
 
// PURPOSE: mimics gauss function rndnb: computes pseudo-random
// numbers with negative binomial distribution
// ------------------------------------------------------------
// INPUT:
// * r = scalar, number of rows of resulting matrix
// * c = scalar, number of cols of resulting matrix
// * k = (M x N) matrix, (E x E) conformable with (r x c)
//   resulting matrix, “event” parameters for negative binomial
//   distribution
// * k = (K x L) matrix, (E x E) conformable with (r x c)
//   resulting matrix, “probability” parameters for negative
//   binomial distribution
// ------------------------------------------------------------
// OUTPUT:
// * x =  a (r x c) matrix, negative binomial distributed
//   pseudo-random numbers
// ------------------------------------------------------------
// Copyright Eric Dubois 2010
// http://grocer.toolbox.free.fr/grocer.html
 
x=ones(r,c)
[rk,ck]=size(k)
[rp,cp]=size(p)
p=1-p
 
if and([rk ck rp cp] ==1) then
   x=grand(r,c,'nbn',k,p)
 
elseif and([rk rp] == 1) then
   if ck == 1 then
      k=k*ones(1,c)
   elseif cp == 1 then
      p=p*ones(1,c)
   end
   for i=1:c
      x(:,i)=grand(r,1,'nbn',k(i),p(i))
   end
 
elseif and([ck cp] == 1) then
   if rk == 1 then
      k=k*ones(r,1)
   elseif rp == 1 then
      p=p*ones(r,1)
   end
   for i=1:r
      x(i,:)=grand(r,1,'nbn',k(i),p(i))
   end
 
else
   [k,p]=resize(k,p,x)
   for i=1:max(rk,rp)
	  for j=1:max(ck,cp)
	     x(i,j)=grand(r,1,'nbn',k(i,j),p(i,j))
      end
   end
 
end
 
endfunction
