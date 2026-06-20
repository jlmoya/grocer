function [Sigtdraw,Wdraw,capAt,sigt,statedraw,yss]=draw_sigma(yhat,Atdraw,Wdraw,statedraw,m_s,u2_s,q_s)

n_m_s=size(m_s,1)
t=size(yhat,2)
// First create capAt, the lower-triangular matrix A(t) with ones on the
// main diagonal. This is because the vector Atdraw has a draw of only the
// non-zero and non-one elements of A(t) only.
capAt = ones(t,1) .*. eye(M,M) 

for i = 2:M 
   capAt(M*[0:t-1]+i,1:i-1)=Atdraw((i-1)*(i-2)/2+1:i*(i-1)/2,:)'
end

// yhat is the vector y(t) - Z x B(t) defined previously. Multiply yhat
// with capAt, i.e the lower triangular matrix A(t). Then take squares
// of the resulting quantity (saved in matrix y2)
y2 = zeros(M,t)

// Transform to the log-scale but also add the ''offset constant'' to prevent
// the case where y2 is zero (in this case, its log would be -Infinity) 
for i = 1:t
   ytemps = capAt((i-1)*M+1:i*M,:)*yhat(:,i);
   y2(:,i)=ytemps .^2
end;
yss=log(y2'+0.001)

// Next draw statedraw (chi square approximation mixture component) conditional on Sigtdraw
// This is used to update at the next step the log-volatilities Sigtdraw
// Seed=grand('getsd')
yss_Sigtdraw=yss-2*Sigtdraw'
u2_s_m2=-2*u2_s
m_s2=m_s-1.2704
q_s2=q_s  ./ sqrt(u2_s) // could add 2*%pi but this is not necessary
for jj = 1:M
   for i = 1:t
      prw=real(q_s2 .*exp((yss_Sigtdraw(i,jj) - m_s2).^2 ./u2_s_m2))
      prw = prw/sum(prw);
      cprw = cumsum(prw);
      trand = grand(1,1,'def');
      if trand < cprw(1); statedraw(i,jj)=1;
      elseif trand < cprw(2), statedraw(i,jj)=2;
      elseif trand < cprw(3), statedraw(i,jj)=3;
      elseif trand < cprw(4), statedraw(i,jj)=4;
      elseif trand < cprw(5), statedraw(i,jj)=5;
      elseif trand < cprw(6), statedraw(i,jj)=6;
      else statedraw(i,jj)=7; 
      end
        // this is a draw of the mixture component index
   end;
end;
// In order to draw the log-volatilies, substract the mean and variance
// of the 7-component mixture of Normal approximation to the measurement
// error covariance
vart = zeros(M*t,M);
yss1 = zeros(t,M);

for j=1:M
   imix=statedraw(:,j);
   vart([0:t-1]*M+j,j)= u2_s(imix);
   yss1(:,j)=yss(:,j)- m_s(imix) + 1.2704;
end

// Sigtdraw is a draw of the diagonal log-volatilies, which will give us SIGMA(t)
Sigtdraw = carter_kohn(yss1',Zs,vart,Wdraw,M,M,t,logsigma_prmean,logsigma_prvar);

// Draws in Sigtdraw are in logarithmic scale (log-volatilies). Create 
// original standard deviations of the VAR covariance matrix
sigt = zeros(t,M);

for i = 1:t
   sigt(i,:) = exp(Sigtdraw(:,i))';
end;

//=====| Draw W, the covariance of SIGMA(t) (from iWishart)
// Get first differences of Sigtdraw to compute the SSE
Sigttemp = Sigtdraw(:,2:t)' - Sigtdraw(:,1:t-1)';

sse_2 = zeros(M,M);
for i = 1:t-1
   sse_2 = sse_2 + Sigttemp(i,:)'*Sigttemp(i,:);
end
Winv = inv(sse_2 + W_prmean);
Winvdraw = wish_rnd1(Winv,t-1+W_prvar);
Wdraw = inv(Winvdraw);

endfunction
