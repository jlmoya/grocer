function [rvar]=Hetero_TVP_VAR1(nlag,Y,Z,nrep,nburn,prior,libsave,nrep_max)
 
// PURPOSE: TVP-VAR Time varying structural VAR with
// heteroskedastic covariance matrix.
// ************************************************************
// The model is:
//
//     Y(t) = B0(t) + B1(t)xY(t-1) + ... + Bp(t)xY(t-p) + e(t)
//
//  with e(t) ~ N(0,SIGMA(t)),
//  and  L(t)'' x SIGMA(t) x L(t) = D(t)*D(t),
//             _                                          _
//            |    1         0        0       ...       0  |
//            |  L21(t)      1        0       ...       0  |
//    L(t) =  |  L31(t)     L32(t)    1       ...       0  |
//            |   ...        ...     ...      ...      ... |
//            |_ LN1(t)      ...     ...    LN(N-1)(t)  1 _|
//
//
// and D(t) = diag[exp(0.5 x h1(t)), .... ,exp(0.5 x hn(t))].
//
// The state equations are
//
//            B(t) = B(t-1) + u(t),            u(t) ~ N(0,Q)
//            l(t) = l(t-1) + zeta(t),      zeta(t) ~ N(0,S)
//            h(t) = h(t-1) + eta(t),        eta(t) ~ N(0,W)
//
// where:
//       B(t) = [B0(t),B1(t),...,Bp(t)]'
//       l(t)=[L21(t),...,LN(N-1)(t)]'
//       h(t) = [h1(t),...,hn(t)]'
//
// ------------------------------------------------------------
// INPUT:
// * nlag = a scalar, the # of lags of the VAR
// * Y = a (T x M) matrix of endogenous variables
// * Z = a ((T-lnag)*M x nZ) matrix of exogenous variables
// * nrep = # of replications taken into account
// * nburn = # of replications not taken into account
//   ("burned": the total # of draws is therefore grocer_nrep+
//   grocer_nburn)
// * prior = a prior tlist
// * libsave = name of the library where the resultys will be
//   stored
// * nrep_max = maximum number of iterations for a storing file
// * varargin = optional arguments that can be:
//   - 'exo=list(exo1,..., exon) if the user wants to add
//   exogenous variables to the VAR, exoi then collects the
//   exogenous variables of equation i
//   - 'nocte' if the user does not want constants in the VAR
//   - 'dropna' if the user wants to drop NA values from the
//    data instead of generating an error
// ------------------------------------------------------------
// OUTPUT:
// rvar= a results tlist with:
// - rvar('meth') = 'heteroskedastic tvp var'
// - rvar('y') = matrix, the endogenous variables
// - rvar('x') = matrix, the exogenous variables
// - rvar('nobs') = # of observations used for estimation
// - rvar('nendo') = # of endogenous variables
// - rvar('nrep') = # of replications taken into account for the
//   calculation of psoterior densities
// - rvar('nburn') = # of replications not taken into account
//   for the calculation of psoterior densities
// - rvar('nlag') = # of lags in the VAR
// - rvar('A_0_prmean') = mean of the prior for the A(0)
//   coefficients
// - rvar('A_0_prvar') = variance of the prior for the
//   A(0) coefficients
// - rvar('B_0_prmean') = mean of the prior for the B(0)
//   coefficients
// - rvar('B_0_prvar') = variance of the prior for the B(0)
//   coefficients
// - rvar('logsigma_prmean') = mean of the prior for the
//   log of the Sigma(t) variances
// - rvar('logsigma_prvar') = variance of the tvp prior for the
//   log of the Sigma(t) variances
// - rvar('Q_prmean') = mean of the prior for the Q
//   variance matrix
// - rvar('Q_prvar') = variance of the prior for the Q
//   variance matrix
// - rvar('W_prmean') = mean of the prior for the W
//   variance matrix
// - rvar('W_prvar') = variance of the prior for the W
//   variance matrix
// - rvar('S_prmean') = mean of the prior for the S
//   variance matrix
// - rvar('S_prvar') = variance of tvp prior for the S
//   variance matrix
// - rvar('Bt_postmean') = estimated matrix of the B(t)
//   coefficients (averaged over the replications)
// - rvar('At_postmean') = estimated matrix of the A(t)
//   coefficients (averaged over the replications)
// - rvar('Sigt_postmean') = estimated matrix of the Sigma(t)
//   coefficients (averaged over the replications)
// - rvar('Qmean') = estimated value of the Q variance matrix
//   (averaged over the replications)
// - rvar('Smean') = estimated value of the S variance matrix
//   (averaged over the replications)
// - rvar('Wmean') = estimated value of the W variance matrix
//   (averaged over the replications)
// - rvar('Sigmamean') = estimated value of the Sigma(t)
//   variance matrices (averaged over the replications)
// - rvar('.dat Bt') = a string vector, the names of the databases
//   where all B(t) draws are stored
// - rvar('.dat At') = a string vector, the names of the databases
//   where all A(t) draws are stored
// - rvar('.dat Sigmat') = a string vector, the names of the
//   databases where all draws of Sigmat are stored
// - rvar('.dat Htstd') = a string vector, the names of the databases
//   where the estimated variance of the shocks are stored
// - rvar('.dat Q') = a string vector, the names of the databases
//   where all Q draws are stored
// - rvar('.dat S') = a string vector, the names of the databases
//   where all S draws are stored
// - rvar('.dat W') = a string vector, the names of the databases
//   where all W draws are stored
// ------------------------------------------------------------
// REFERENCE :
//   G. Primiceri (2005), "Time Varying Structural Vector
//   Autoregressions & Monetary Policy", Review of Economic
//   Studies 72, p. 821-852
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by Gary Koop and
// Dimitris Korobilis (http://personal.strath.ac.uk/gary.koop)
 
 
if ~isdir(libsave) then
   mkdir(libsave)
end
 
// Number of observations and dimension of X and Y
[T,M] = size(Y);// t is the time-series observations of Y
t=T-nlag
ylag=mlag(Y,nlag)
ylag=ylag(nlag+1:T,:)
Zlag=[]
for i=1:t
   Zlag=[Zlag ; eye(M,M) .*.  ylag(i,:)]
end
Z=[Zlag , Z]
K=size(Z,2)
numa = M*(M-1)/2;// Number of lower triangular elements of A_t (other than 0''s and 1''s)
 
// Redefine VAR variables to remove the training observations
y = Y(nlag+1:T,:)';
t=T-nlag
 
//set priors from the corresponding tlist
B_0_prmean = prior('B_0_prmean')
B_0_prvar = prior('B_0_prvar')
A_0_prmean = prior('A_0_prmean')
A_0_prvar = prior('A_0_prvar')
logsigma_prmean =prior('logsigma_prmean')
logsigma_prvar = prior('logsigma_prvar')
Q_prmean=prior('Q_prmean');
Q_prvar=prior('Q_prvar');
W_prmean=prior('W_prmean');
W_prvar=prior('W_prvar');
S_prmean=prior('S_prmean');
S_prvar=prior('S_prvar');
 
// Parameters of the 7 component mixture approximation to a log(chi^2)
// density:
q_s = [0.0073;0.10556;0.00002;0.04395;0.34001;0.24566;0.2575];// probabilities
m_s = [-10.12999;-3.97281;-8.56686;2.77786;0.61942;1.79518;-1.08819];// means
u2_s = [5.79596;2.61369;5.1795;0.16735;0.64009;0.34023;1.26261];// variances
 
 
//========= INITIALIZE MATRICES:
Btdraw = ones(1,t) .*. B_0_prmean;// Initialize Btdraw, a draw of the mean VAR coefficients, B(t)
Atdraw = ones(1,t) .*. A_0_prmean;// Initialize Atdraw, a draw of the non 0 or 1 elements of A(t)
Sigtdraw = logsigma_prmean' .*. ones(t,1);// Initialize Sigtdraw, a draw of the log-diagonal of SIGMA(t)
sigt = exp(logsigma_prmean') .*. ones(t,1);// Matrix of the exponent of Sigtdraws (SIGMA(t))
Qdraw = Q_prmean/(Q_prvar+K+1);// Initialize Qdraw, a draw from the covariance matrix Q
Wdraw = W_prmean/(W_prvar+M+2);// Initialize Wdraw, a draw from the covariance matrix W
Sblockdraw=zeros(M*(M-1)/2,M*(M-1)/2)
for ii = 2:M
   index=ii-1+(ii-3)*(ii-2)/2:(ii-1)*ii/2
   Sblockdraw(index,index) = S_prmean(index,index)/(S_prvar(ii-1)+ii+1);// Initialize Sdraw, a draw from the covariance matrix S
end;
statedraw = 5*ones(t,M);// initialize the draw of the indicator variable
// (of 7-component mixture of Normals approximation)
capA0=eye(M,M)
for i = 2:M
   capA0(i,1:i-1)=A_0_prmean((i-1)*(i-2)/2+1:i*(i-1)/2)'
end
Hsd = inv(capA0)*diag(exp(logsigma_prmean));
Hti = ones(t,1) .*. (Hsd*Hsd');// Initialize Htdraw, a draw from the VAR covariance matrix
 
Zs = 2*ones(t,1) .*. eye(M,M);
 
// Storage matrices for posteriors and stuff
Bt_postmean = zeros(K,t);// regression coefficients B(t)
At_postmean = zeros(numa,t);// lower triangular matrix A(t)
Sigt_postmean = zeros(t,M);// diagonal std matrix SIGMA(t)
Qmean = zeros(K,K);// covariance matrix Q of B(t)
Smean = zeros(numa,numa);// covariance matrix S of A(t)
Wmean = zeros(M,M);// covariance matrix W of SIGMA(t)
 
sigmean = zeros(t,M);// mean of the diagonal of the VAR covariance matrix
cormean = zeros(t,numa);// mean of the off-diagonal elements of the VAR cov matrix
sig2mo = zeros(t,M);// squares of the diagonal of the VAR covariance matrix
cor2mo = zeros(t,numa);// squares of the off-diagonal elements of the VAR cov matrix
 
At = zeros(numa,t,nrep_max);
Bt = zeros(K,t,nrep_max);
Sigmat = zeros(t,M,nrep_max);
Htsd=zeros(M*t,M,nrep_max);
 
Q = zeros(K,K,nrep_max);
S = zeros(numa,numa,nrep_max);
W = zeros(M,M,nrep_max);
 
//----------------------------- END OF PRELIMINARIES ---------------------------
 
//====================================== START SAMPLING ========================================
//==============================================================================================
write(%io(2),"Number of iterations",'(a)');
 
isave=0
datasave=1
it_print=1000;
tol=sqrt(%eps)
Sigtdraw=logsigma_prmean .*. ones(1,t)
 
ndel=0
irep=1
 
while irep <= nrep+nburn // GIBBS iterations starts here
   // Print iterations
   if pmodulo(irep,it_print)==0 then
      disp(irep);
   end;
 // Print iterations
 // -----------------------------------------------------------------------------------------
 //   STEP I: Sample B from p(B|y,A,Sigma,V) (Drawing coefficient states, pp. 844-845)
 
 // -----------------------------------------------------------------------------------------
     [Btdraw,Qdraw]=draw_beta(y,Z,Hti,Qdraw,K,M,t,B_0_prmean,B_0_prvar,tol)
     //-------------------------------------------------------------------------------------------
     //   STEP II: Draw A(t) from p(At|y,B,Sigma,V) (Drawing coefficient states, p. 845)
     //-------------------------------------------------------------------------------------------
     [Atdraw,Sblockdraw,yhat]=draw_alpha(Btdraw,Z,M,numa,Sblockdraw,sigt,A_0_prmean,A_0_prvar,tol)
 
     //------------------------------------------------------------------------------------------
     //   STEP III: Draw diagonal VAR covariance matrix log-SIGMA(t)
     //------------------------------------------------------------------------------------------
 
      [Sigtdraw,Wdraw,capAt,sigt,statedraw]=draw_sigma(yhat,Atdraw,Wdraw,statedraw,m_s,u2_s,q_s)
      // Create the VAR covariance matrix H(t). It holds that:
      //           A(t) x H(t) x A(t)'' = SIGMA(t) x SIGMA(t) ''
      Hti = zeros(M*t,M);
      Htsdi = zeros(M*t,M);
      for i = 1:t
         inva = inv(capAt((i-1)*M+1:i*M,:));
         stem = diag(sigt(i,:));
         Hsd = inva*stem;
         Hdraw = Hsd*Hsd';
         Hti((i-1)*M+1:i*M,:) = Hdraw;  // H(t)
         Htsdi((i-1)*M+1:i*M,:) = Hsd;  // Cholesky of H(t)
      end;
 
     //----------------------------SAVE AFTER-BURN-IN DRAWS AND IMPULSE RESPONSES -----------------
      if irep>nburn then
         isave=isave+1
 
         Bt(:,:,isave)=Btdraw;
         At(:,:,isave)=Atdraw;
         Sigmat(:,:,isave)=sigt;
         Htsd(:,:,isave)=Htsdi
 
         Q(:,:,isave)=Qdraw;
         S(:,:,isave)=Sblockdraw;
         W(:,:,isave)=Wdraw;
 
         Bt_postmean = Bt_postmean+Btdraw;  // regression coefficients B(t)
         At_postmean = At_postmean+Atdraw;  // lower triangular matrix A(t)
         Sigt_postmean = Sigt_postmean+sigt;  // diagonal std matrix SIGMA(t)
         Qmean = Qmean+Qdraw;  // covariance matrix Q of B(t)
 
         Smean = Smean+Sblockdraw;  // covariance matrix S of A(t)
         Wmean = Wmean+Wdraw;  // covariance matrix W of SIGMA(t)
 
         // Get time-varying correlations and variances
         stemp6 = zeros(M,1);
         stemp5 = zeros(t,M)
         stemp7 = [];
         for i = 1:t
            stemp8 = var2cor(Hti((i-1)*M+1:i*M,:));
            stemp7a = [];
            ic = 1;
            for j = 1:M
               if j>1 then
                  stemp7a = [stemp7a;stemp8(j,1:ic)'];
                  ic = ic+1;
               end;
               stemp6(j) = sqrt(Hti((i-1)*M+j,j));
            end;
            stemp5(i,:) = stemp6';
            stemp7 = [stemp7;stemp7a'];
         end;
         sigmean =sigmean+stemp5;  // diagonal of the VAR covariance matrix
         cormean = cormean+stemp7;  // off-diagonal elements of the VAR cov matrix
         sig2mo = sig2mo+stemp5 .^2;
         cor2mo = cor2mo+stemp7 .^2;
 
         if modulo(isave,nrep_max) == 0 then
           execstr('save('''+libsave+'\Bt'+string(datasave)+'.dat'',''Bt'')')
           execstr('save('''+libsave+'\At'+string(datasave)+'.dat'',''At'')')
           execstr('save('''+libsave+'\Sigmat'+string(datasave)+'.dat'',''Sigmat'')')
           execstr('save('''+libsave+'\Htsd'+string(datasave)+'.dat'',''Htsd'')')
 
           execstr('save('''+libsave+'\Q'+string(datasave)+'.dat'',''Q'')')
           execstr('save('''+libsave+'\S'+string(datasave)+'.dat'',''S'')')
           execstr('save('''+libsave+'\W'+string(datasave)+'.dat'',''W'')')
           datasave=datasave+1
           isave=0
         end
 
      end; // END saving after burn-in results
   irep=irep+1
end;//END main Gibbs loop (for irep = 1:nrep+nburn)
 
if ndel > 0 then
   warning(string(ndel)+' draws have been remade')
end
if isave ~= 0 then
   Bt=Bt(:,:,1:isave)
   At=At(:,:,1:isave)
   Q=Q(:,:,1:isave)
   Sigmat=Sigmat(:,:,1:isave)
   Htsd=Htsd(:,:,1:isave)
   execstr('save('''+libsave+'\Bt'+string(datasave)+'.dat'',''Bt'')')
   execstr('save('''+libsave+'\At'+string(datasave)+'.dat'',''At'')')
   execstr('save('''+libsave+'\Sigmat'+string(datasave)+'.dat'',''Sigmat'')')
   execstr('save('''+libsave+'\Htsd'+string(datasave)+'.dat'',''Htsd'')')
 
   execstr('save('''+libsave+'\Q'+string(datasave)+'.dat'',''Q'')')
   execstr('save('''+libsave+'\S'+string(datasave)+'.dat'',''S'')')
   execstr('save('''+libsave+'\W'+string(datasave)+'.dat'',''W'')')
else
   datasave=datasave-1
end
//=============================GIBBS SAMPLER ENDS HERE==================================
 
 
rvar=tlist(['results';'meth';'y';'x';'nobs';'nendo';'nrep';'nburn';'nlag';...
'A_0_prmean';'A_0_prvar';'B_0_prmean';'B_0_prvar';...
'logsigma_prmean';'logsigma_prvar';'Q_prmean';'Q_prvar';...
'W_prmean';'W_prvar';'S_prmean';'S_prvar';...
'Bt_postmean';'At_postmean';'Sigt_postmean';...
'Qmean';'Smean';'Wmean';'Sigmamean';...
'.dat Bt';'.dat At';'.dat Sigmat';'.dat Htsd';'.dat Q';'.dat S';'.dat W'],...
'heteroskedastic tvp var',Y,Z,t,M,nrep,nburn,nlag,...
A_0_prmean,A_0_prvar,B_0_prmean,B_0_prvar,...
logsigma_prmean,logsigma_prvar,Q_prmean,Q_prvar,...
W_prmean,W_prvar,S_prmean,S_prvar,...
Bt_postmean/nrep,At_postmean/nrep,Sigt_postmean/nrep,Qmean/nrep,...
Smean/nrep,Wmean/nrep,sigmean/nrep,...
libsave+'\Bt'+string(1:datasave)'+'.dat',...
libsave+'\At'+string(1:datasave)'+'.dat',...
libsave+'\Sigmat'+string(1:datasave)'+'.dat',...
libsave+'\Htsd'+string(1:datasave)'+'.dat',...
libsave+'\Q'+string(1:datasave)'+'.dat',...
libsave+'\S'+string(1:datasave)'+'.dat',...
libsave+'\W'+string(1:datasave)'+'.dat')
 
endfunction
