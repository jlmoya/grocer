function [irf_low,irf_upp]=irf_asy(results,mres,P0,IRF,bet,S,siz)
 
// PURPOSE: Calculates standard error of Impulse Response
// Function for VAR by means of the asymptotic formula
//-------------------------------------------------------------
// REFERENCES:
// * Hamilton, Time Series Analysis (1994)
// * Mittnik and Zadrozny, Asymptotic distibutions of Impulse
// Responses, Step Respones, and Variance Decomposition of
// Estimated Linear Dhynamic Modesl, Econometricas, vol61, n°4,
// Jul. 1993
// ------------------------------------------------------------
// INPUT:
// * results = results tlist returned by VAR
// * mres = decomposition method
// * P = matrix such that P*e = u
//       where u is the residual from the VAR regression
//             e is the residual to be shocked
// * IRF = ((S+1) x T) impulse response functions
// * PHI = (N*p x T) matrix of coefficients
// * S = # of periods
// * siz = size of the confidence band
//-------------------------------------------------------------
// OUTPUT:
// * irf_low = ((S+1) x T) lower range of impulse response
//                     confidence band
// * irf_upp = ((S+1) x T) upper range of impulse response
//                     confidence band
//-------------------------------------------------------------
// Copyright Eric Dubois 2002-2013
// http://grocer.toolbox.free.fr/grocer.html
 
N = results('neqs');
dup=duplication(N)
dupp=inv(dup'*dup)*dup'
com=commutation(N)
eli=elimination(N)
 
p = results('nlag');
nx=results('nx')
nobs = results('nobs');
sigma =results('sigma')
sig_vecA= results('vcovar')
 
index=[1:N*p]
for i=2:N
   index=[index , [1:N*p]+(i-1)*(N*p+nx) ]
end
sig_vecA=sig_vecA(index,index)
sig_sig=2*dupp*(sigma.*.sigma)*dupp'/nobs
 
mult=cdfnor("X",0,1,1-siz/2,siz/2)
 
v=zeros(N*(S+1),N)
j=eye(N,N*p)
I_N=eye(N,N)
grad_irf_A=zeros(N^2,N^2*p,S+1)
grad_irf_R=zeros(N^2,N^2,S+1)
 
grad_A_A=zeros(N^2,N^2*p,p)
for i=1:p
    grad_A_A(:,1+(i-1)*N^2:i*N^2,i)=eye(N^2,N^2)
end
 
select mres
 
case 'chol1'
 
   h=eli'*inv(eli*(eye(N^2,N^2)+com) *(P0 .*. eye(N,N))*eli')
   grad_irf_R(:,:,1)=eye(N^2,N^2)
   v(1:N,:)=sqrt(matrix(diag(h*sig_sig*h'),N,N)/nobs)
 
   for s=1:S
      grad_As=0
      grad_Rs=0
      for k=1:min(s,p)
         grad_As=grad_As+(IRF(1+N*(s-k):N*(s-k+1),:)' .*. I_N)*grad_A_A(:,:,k)+...
                 (I_N .*. bet(1+(k-1)*N:k*N,:)')*grad_irf_A(:,:,s+1-k)
         grad_Rs=grad_Rs+(I_N .*. bet(1+(k-1)*N:k*N,:)')*grad_irf_R(:,:,s+1-k)
      end
      grad_irf_A(:,:,s+1)=grad_As
      grad_irf_R(:,:,s+1)=grad_Rs
 
      v(1+s*N:(s+1)*N,:)=matrix(sqrt(diag(grad_As*sig_vecA*grad_As'+...
                            grad_Rs*h*sig_sig*h'*grad_Rs')/nobs),N,N)
   end
 
case 'chol2'
   Dsr = diag(diag(P0));
   P = inv(Dsr)*P0;
   R=eli'*inv(eli*(eye(N^2,N^2)+com) *(P .*. eye(N,N))*eli')
 
   h=zeros(N^2,N*(N+1)/2)
   for i=1:N-1
      for j=i+1:N
         h((i-1)*N+j,:)=R((i-1)*N+j,:)/P0(j,j)-P0(j,i)/P0(j,j)^2*R((j-1)*N+j,:);
      end
   end
   grad_irf_R(:,:,1)=eye(N^2,N^2)
   v(1:N,:)=sqrt(matrix(diag(h*sig_sig*h')/nobs,N,N))
 
   for s=1:S
      lags=min(s,p)
      grad_As=0
      grad_Rs=0
      for m=1:lags
         grad_As=grad_As+(IRF(1+N*(s-m):N*(s-m+1),:)' .*. I_N)*grad_A_A(:,:,m)+...
                 (I_N .*. bet(1+(m-1)*N:m*N,:)')*grad_irf_A(:,:,s+1-m)
         grad_Rs=grad_Rs+(I_N .*. bet(1+(m-1)*N:m*N,:)')*grad_irf_R(:,:,s+1-m)
      end
      grad_irf_A(:,:,s+1)=grad_As
      grad_irf_R(:,:,s+1)=grad_Rs
 
      v(1+s*N:(s+1)*N,:)=matrix(sqrt(diag(grad_As*sig_vecA*grad_As'+...
                            grad_Rs*h*sig_sig*h'*grad_Rs')/nobs),N,N)
   end
 
 
case 'original'
   for s=1:S
      lags=min(s,p)
      grad_As=0
      grad_Rs=0
      for m=1:lags
         grad_As=grad_As+(IRF(1+N*(s-m):N*(s-m+1),:) .*. I_N)*grad_A_A(:,:,m)+...
                 (I_N .*. bet(1+(m-1)*N:m*N,:)')*grad_irf_A(:,:,s+1-m)
      end
      grad_irf_A(:,:,s+1)=grad_As
 
      v(1+s*N:(s+1)*N,:)=matrix(sqrt(diag(grad_As*sig_vecA*grad_As')),N,N)
   end
 
 
end
 
irf_low=IRF-mult*v
irf_upp=IRF+mult*v
 
endfunction
