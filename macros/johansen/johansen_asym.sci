function [result]=johansen_asym(result,m,exo_st)
 
// PURPOSE: perform Johansen cointegration tests
// ------------------------------------------------------------
// * References:
// - Johansen (1988), 'Statistical Analysis of
// Co-integration vectors', Journal of Economic Dynamics and
// Control, 12, pp. 231-254.
// - Jueslius (2006): The Cointegrated VAR Model: Methodlogy
// and Applications, Oxford University Press.
// ------------------------------------------------------------
// INPUT:
// * result = a result tlist containing all input and ouptut
//   except for the critcial values from a johansen analysis
// * m = # of endogenous variables
// * exo_st = matrix of exogenous variables
// ------------------------------------------------------------
// OUTPUT:
// * result = the ouput tlist completed with asymptotic
//   critical levels
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009- 2011
// http://grocer.toolbox.free.fr/grocer.html
 
if isempty(exo_st) then
   p=-1
else
   dexo_st=exo_st(2:$,:)-exo_st(1:$-1,:)
   i=size(exo_st,2)
   tren=%f
   const=%f
   for i=size(exo_st,2):-1:1
      if and(dexo_st(:,i) == dexo_st(1,i)) & (dexo_st(1,i) ~= 0) then
         tren=%t
         exo_st(:,i)=[]
      elseif and(dexo_st(:,i) == dexo_st(1,i)) then
          exo_st(:,i)=[]
          const=%t
      end
   end
 
   if isempty(exo_st) then
      if tren then
         p=1
      elseif const then
         p=0
      else
         p=-1
      end
   else
      error('your exogenous variables do not allow to calculate asymptotic statistics')
   end
end
 
// Compute the trace and max eigenvalue statistics
lr1 = zeros(m,1);
lr2 = zeros(m,1);
cvm = zeros(m,3);
cvt = zeros(m,3);
 
for i = 1:m
   cvm(i,:) = c_sja(m-i+1,p);
   cvt(i,:) = c_sjt(m-i+1,p);
end
 
 
result(1)($+1)='cvt'
result(1)($+1)='cvm'
result('cvt')=cvt
result('cvm')=cvm
 
endfunction
