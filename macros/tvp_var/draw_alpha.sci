function [Atdraw,Sblockdraw,yhat]=draw_alpha(Btdraw,Z,M,numa,Sblockdraw,sigt,A_0_prmean,A_0_prvar,tol)

// Substract from the data y(t), the mean Z x B(t)
yhat = zeros(M,t);

for i = 1:t
   yhat(:,i) = y(:,i) - Z((i-1)*M+1:i*M,:)*Btdraw(:,i);
end

Atdraw = [];

for ii = 2:M
   Zctemp = -yhat(1:ii-1,:)'
   index=(ii-1)*(ii-2)/2+1:ii*(ii-1)/2
   sigmatemp = sigt(:,ii) .^ 2

  // Draw each block of A(t)
   Atblockdraw = carter_kohn(yhat(ii,:),Zctemp,sigmatemp,...
            Sblockdraw(index,index),ii-1,1,t,A_0_prmean(index),A_0_prvar(index,index),tol);
   Atdraw = [Atdraw;Atblockdraw];  
end;

//=====| Draw S, the covariance of A(t) (from iWishart)
// Take the SSE in the state equation of A(t)
Attemp = Atdraw(:,2:t)' - Atdraw(:,1:t-1)';
sse_2 = zeros(numa,numa);
for i = 1:t -1
   sse_2 = sse_2 + Attemp(i,:)'*Attemp(i,:);
end;

// ...and subsequently draw S, the covariance matrix of A(t) 
for ii = 2:M
   index=ii-1+(ii-3)*(ii-2)/2:(ii-1)*ii/2
   Sinv = inv(sse_2(index,index)+S_prmean(index,index))
   Sinvblockdraw = wish_rnd1(Sinv,t-1+S_prvar(ii-1));
   Sblockdraw(index,index)=inv(Sinvblockdraw);
end;

endfunction
