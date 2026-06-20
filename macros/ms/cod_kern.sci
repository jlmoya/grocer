function res_code=cod_kern(data,nbqua)
 
// PURPOSE: divides the data into quantiles with a kernel
// method
// ------------------------------------------------------------
// INPUT:
// * data = a (N X k) data matrix
// * nbqua = a (2 x 1 ) vector:
//           - nbqua(1) = # of quantiles used to divide the data
//           - nbqua(2) = useless (for the moment...)
// ------------------------------------------------------------
// OUTPUT:
// * res_code =
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adapted from a Gauss programm by J. Bardaji
// and F. Tallet
 
[nobs,nbv]=size(data);
 
max_abs=max(abs(data),'r')
 
// Calculation of the quantiles of the series
quantiles=zeros(nbv+2,nbqua(1)-1);
if nbqua(2) ==0 then
   quantiles(1:2,:)=[seqa(1,1,nbqua(1)-1)';seqa(1/nbqua(1),1/nbqua(1),nbqua(1)-1)'];
else
   quantiles(1:2,:)=[seqa(1,1,nbqua(1)-1)';nbqua(2:nbqua(1),:)'];
end
 
// Kernel estimation with nbpts=1000 and the kernel method
nbpts=1000;
 
for i =1:nbv
   [s,d1,d2,f]=kern(packr(data(:,i)),-max_abs(i),max_abs(i),nbpts);
 
   for j=1:nbqua(1)-1
      [junk,m]=min(abs(f-quantiles(2,j)))
      quantiles(i+2,j)=s(m);
   end
end
 
// Phase de codage proprement dite : 1er quantile pr ttes les variables, 2ième ...//
// en sortie: - mat : var1(quant1-quantq) ... varp(quant1-quantq)                 //
 
res_code=zeros(nobs,nbv*nbqua(1));
for s=1:nbv
   res_code(:,1+nbqua(1)*(s-1))=(data(:,s) < (ones(nobs,1) .*. quantiles(s+2,1)));
   if nbqua(1)==2 then
      res_code(:,2+nbqua(1)*(s-1))=(data(:,s) >= (ones(nobs,1) .*. quantiles(s+2,1)));
   elseif nbqua(1)==3 then
      res_code(:,2+nbqua(1)*(s-1))=(ones(nobs,1) .*. quantiles(s+2,1) <= data(:,s))...
                                                 & (data(:,s) < ones(nobs,1).*.quantiles(s+2,2));
      res_code(:,3+nbqua(1)*(s-1))=(data(:,s) >= ones(nobs,1) .*. quantiles(s+2,2));
   end
end
 
endfunction
