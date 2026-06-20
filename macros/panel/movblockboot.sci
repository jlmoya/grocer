function [ovb,selb,k,re]=movblockboot(T,l,B)
 
// PURPOSE: In a moving-block bootstrap, gives the matrix
//  that decomposes the initial sample into overlapping
//  block and the matrix that randomly selects them
//---------------------------------------------------
// INPUT:
// . T  = sample size
// . l  = block length
// . B = number of bootstrap replications
//---------------------------------------------------
// OUTPUT:
// . ovb  = (l x T/l) matrix that decomposes the initial
//        sample into l overlapping blocks
// . selb = (T/l x B) matrix that randomly selects the
//       overlapping blocks
// . k = number of blocks
// . re = size of the last block if T/l not an integer
//---------------------------------------------------
//  Emmanuel Michaux 2012
// http://grocer.toolbox.free.fr/grocer.html
 
 
k=T/l;
re=0;
if int(k)~=k then
  write(%io(2),'','(a)');
  warning('# blocks not an integer: one block will have to be truncated');
  k=int(k)+1;
  re=k*l-T;
end
 
 
li=ones(l,1)*(1:(T-l+1));
co=(0:(l-1))'*ones(1,T-l+1);
ovb=li+co;
 
 
selb=grand(k,B,'uin',1,T-l+1);
 
 
endfunction
