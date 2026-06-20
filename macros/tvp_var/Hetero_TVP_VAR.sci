function rvar=Hetero_TVP_VAR(grocer_nlag,grocer_endo,grocer_nrep,grocer_nburn,grocer_prior,grocer_libsave,grocer_nrep_max,varargin)
 
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
// * grocer_nlag = a scalar, the # of lags of the VAR
// * grocer_endo = either a string vector or a list collecting
//   the names of the endogenous variables of the VAR
// * grocer_nrep = # of replications taken into account
// * grocer_nburn = # of replications not taken into account
//   ("burned": the total # of draws is therefore grocer_nrep+
//   grocer_nburn)
// * grocer_prior = a prior tlist
// * tau = size of the training sample or [] if ts_priori is set
//   to %f
// * consQ = multiplicative factor used for the prior of the
//   variance-matrix of the tvp
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
// - rvar('nobs') = # of observations used for estimation
// - rvar('nendo') = # of endogenous variables
// - rvar('nrep') = # of replications taken into account for the
//   calculation of psoterior densities
// - rvar('nburn') = # of replications not taken into account
//   for the calculation of psoterior densities
// - rvar('nlag') = # of lags in the VAR
// - rvar('A_0_prmean') = mean of the tvp prior for the A(t)
//   coefficients
// - rvar('B_0_prvar') = variance of the tvp prior for the
//   A(t) coefficients
// - rvar('B_0_prmean') = mean of the tvp prior for the B(t)
//   coefficients
// - rvar('B_0_prvar') = variance of the tvp prior for the B(t)
//   coefficients
// - rvar('logsigma_prmean') = mean of the tvp prior for the
//   log of the Sigma(t) variances
// - rvar('logsigma_prvar') = variance of the tvp prior for the
//   log of the Sigma(t) variances
// - rvar('Q_prmean') = mean of the tvp prior for the Q
//   variance matrix
// - rvar('Q_prvar') = variance of the tvp prior for the Q
//   variance matrix
// - rvar('W_prmean') = mean of the tvp prior for the W
//   variance matrix
// - rvar('W_prvar') = variance of the tvp prior for the W
//   variance matrix
// - rvar('S_prmean') = mean of the tvp prior for the S
//   variance matrix
// - rvar('S_prvar') = variance of the tvp prior for the S
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
// - rvar('Sigmamean') = estimated variance of the shocks
//   (averaged over the replications)
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
// - rvar('namey') = name of the y variable
// - rvar('namex') = list of names of the x variables
// - rvar('prests') = boolean indicating the presence or
//     absence of a time series in the regression
// - rvar('dropna') = boolean indicating if NAs have
//		   been dropped
// - rvar('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
// - rvar('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// REFERENCE :
//   G. Primiceri (2005), "Time Varying Structural Vector
//   Autoregressions & Monetary Policy", Review of Economic
//   Studies 72, p. 821-852
// ------------------------------------------------------------
// Copyright: Eric Dubois 2015
// http://grocer.toolbox.free.fr/grocer.html
// This function uses the function Hetero_TVP_VAR1, that has been
// translated and adapted from a Matlab program by Gary Koop and
// Dimitris Korobilis (http://personal.strath.ac.uk/gary.koop)
 
 
grocer_dropna=%f
grocer_flagexo=%f
grocer_nocte=%f
 
grocer_nargin=length(varargin)
for grocer_i=1:grocer_nargin
 
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_st=strsubst(varargin(grocer_i),' ','')
 
      if part(grocer_st,1:4) == 'exo=' then
        grocer_indeq=strindex(varargin(grocer_i),'=')
        execstr('grocer_exo='+part(varargin(grocer_i),grocer_indeq+1:length(grocer_st)))
        grocer_flagexo=%t
 
      elseif grocer_st == 'nocte' then
         grocer_nocte = 'nocte'
 
      elseif grocer_st == 'dropna' then
         grocer_dropna = %t
      end
 
   else
      error(typeof(varargin(grocer_i))+': not a valid type in var')
   end
 
end
 
if grocer_flagexo then
    if typeof(grocer_exo)  == 'list' then
       if typeof(grocer_endo) ~= list then
          grocer_endo=list(grocer_endo)
       end
       [mats,names,prests,boundsvarb,nonna]=explon(lstcat(grocer_endo,grocer_exo),['endogenous';'exogenous'+string(1:length(grocer_exo))'],[],%t,grocer_dropna,%f,[grocer_nlag;zeros(length(grocer_exo),1)])
       y=mats(1)
       namey=grocer_names(1)
       namex(1)=null()
       [nobs,ny]=size(y)
       if length(grocer_exo) ~= ny then
          error('list of exogenous variables should have the same length as the # of endogenosu variables')
       end
       nz=zeros(ny,1)
       for i=1:ny
          zi=grocer_mats(i+1)
          nz(i)=size(zi,2)
       end
       nobs_z=nobs-grocer_nlag
       z=zeros(nobs_z*ny,sum(nz))
       ind_col=0
       for i=1:ny
          zi=grocer_mats(i+1)
          z(i+ny*[0:nobs_z-1],ind_col+[1:nz(i)])= zi
          ind_col=ind_col+nz(i)
       end
   end
 
else
   [y,namey,prests,boundsvarb,nonna]=explone(grocer_endo,[],['endogenous'],%t,grocer_dropna,%f,grocer_nlag)
   if grocer_nocte then
      z=[]
      namex=list()
   else
      [nobs,ny]=size(y)
      z=ones(nobs-grocer_nlag,1) .*. eye(ny,ny)
      namex=list('const')
      for j=2:ny
         namex($+1)='const'
      end
   end
 
end
[rvar]=Hetero_TVP_VAR1(grocer_nlag,y,z,grocer_nrep,grocer_nburn,grocer_prior,grocer_libsave,grocer_nrep_max)
 
rvar(1)($+1)='namey'
rvar($+1)=namey
rvar(1)($+1)='namex'
rvar($+1)=namex
rvar(1)($+1)='prests'
rvar($+1)=prests
rvar(1)($+1) = 'dropna'
rvar('dropna')=grocer_dropna
 
if prests then
   rvar(1)($+1)='bounds'
   rvar($+1)=boundsvarb
end
 
if grocer_dropna then
   rvar(1)($+1)='nonna'
   rvar('nonna')=nonna
end
 
 
endfunction
