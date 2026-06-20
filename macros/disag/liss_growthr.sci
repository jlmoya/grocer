function [y,u] = liss_growthr(Y,uA,gxhat,s)

// ------------------------------------------------------------
//  Program that realizes:
//       Min sum ut(t)^2
//         w.r sum[ ut(t) ] = ua
// with ut high frequency residuals and ua annual ones
// ------------------------------------------------------------

N=size(uA,1)

Mat_q2a=[eye(N,N).*.[0:s-1] , zeros(N,s)]+[zeros(N,s) , eye(N,N).*.[s:-1:1] ]
Mat_q2a(:,1)=[]
u=[4*Mat_q2a'*((Mat_q2a*Mat_q2a')\uA) ; zeros(size(gxhat,1)-(N+1)*s+1,1)]
y=cumprod(1+gxhat+u)
y1=Y(1)/(1+y(1)+y(2)+y(3))
y=[y1 ; y1*y]

endfunction
