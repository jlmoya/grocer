function res=johansen_normalize(res,vari,np)
 
// PURPOSE: normalize the eigen vector and error correction
// term from a johansen estimation
// ------------------------------------------------------------
// INPUT:
// * res = a johansen results tlist
// * vari = a vector indicating the variables used for each
//   normalization
// * np = 'noprint if the user dose not want to print the 
//   results
// ------------------------------------------------------------
// OUTPUT:
// res = the original tlist except for the 'evec' (eigen
// vectors) and 'alpha' (error correction) fields changed
// by the normalization
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009-2011
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
prt=%t
if nargin ==3 then
   if np == 'noprint' then
      prt=%f
   end
end
alpha=res('alpha')
evec=res('evec')
ny=res('nvar')
 
for i=1:size(vari,'*')
   v=evec(vari(i),i)
   evec(:,i)=evec(:,i)/v
   alpha(i,:)=alpha(i,:)*v
end
 
res('alpha')=alpha
res('evec')=evec
 
res_1=res(1)
if prt then
   if or(res_1 == 'nb of cointegration relations') then
      prtjohvec(res,res('nb of cointegration relations'))
   else
      prtjohvec(res,res('nvar'))
   end
end
 
endfunction
