function [res]=irf(results,S,varargin)
 
// PURPOSE: Calculates Impulse Response Function for VAR
// ------------------------------------------------------------
// INPUT:
// * results = results tlist returned by VAR
// * S = scalar for number of periods in IRF
// * varargin = optional arguments:
//   - 'mres=x' where x = chol1 (cholesky decomposition)
//                    x = chol2 (triangular factorisation)
//                    x = original (original residuals)
//                        (default = chol1)
//   - 'meth=x' where x = asym (asymptotic formula)
//                    x = mc1 (Monte-Carlo simulations using
//                        draws from the coefficients)
//                        (default = asym)
//   - 'niter=x' where x= # iterations for the Monte-Carlo
//                        simulations (if any; default=1000)
//   - 'size=x' where x = significance level for the confidence
//                        band (default =0.05)
//-------------------------------------------------------------
// OUTPUT:
// res= a results tlist with
// - res('meth') = 'irf'
// - res('mres') = decomposition method
// - res('T') = # of periods represented
// - res('IRF') = ((S+1) x T) impulse response functions
// - res('IRF_LOW') = ((S+1) x T) lower range of impulse
//                     response confidence band
// - res('IRF_UPP') = ((S+1) x T) upper range of impulse
//                     response confidence band
// - res('PHI') = (N*p x T) matrix of coefficients
// - res('resvar') = results tlist of the originating VAR
// - res('msg') = message inidicating the nature of the
//   decomposition
// - res('size') = size of the confidence band
//-------------------------------------------------------------
// REFERENCES: Hamilton, Time Series Analysis (1994)
//-------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// Mike Cliff, UNC Finance  mcliff@unc.edu
 
//============================================================
//    SET UP PARMS
//============================================================
 
mres='chol1'
meth='asym'
ndraws=1000
siz=0.05
 
for i=1:length(varargin)
   ieq=strindex(varargin(i),'=')
   car1=part(varargin(i),1:ieq-1)
   l=length(varargin(i))
 
   select car1
   case 'mres' then
      mres=part(varargin(i),ieq+1:l)
   case 'meth' then
      meth=part(varargin(i),ieq+1:l)
   case 'ndraws' then
      execstr('niter='+part(varargin(i),ieq+1:l))
   case 'size' then
      execstr('size='+part(varargin(i),ieq+1:l))
   end
end
 
N = results('neqs');
p = results('nlag');
namey = results('namey')
sigma = results('sigma')
bet = results('beta')
 
// ---- Determine decomposition of Cov matrix -----------------
select mres
case 'chol1' then
   // Cholesky of omega = P'*P
   msg = 'Orthog. IRF: 1 sigma changes';
   P0 = chol(sigma)';
   P=P0;
case 'chol2' then
   // triangular fact. omega = A*D*A'
   msg = 'Orthog. IRF: 1 unit changes';
   P0    = chol(sigma)'
   Dsr = diag(diag(P0));
   P = inv(Dsr)*P0;
else
   msg = 'Unorthog. IRF: 1 unit changes';
   P = eye(N,N);
end
 
[IRF,PHI]=irf0(bet,S,N,p,P)
 
select meth
case 'asym' then
   [irf_low,irf_upp]=irf_asy(results,mres,P0,IRF,bet,S,siz)
case 'bootstrap' then
   [irf_low,irf_upp]=irf_bs(results,mres,IRF,S,ndraws,siz)
else
   error(meth+' is not an available method to compute confidence bands in irf')
end
 
 
res=tlist(['results';'meth';'mres';'T';'IRF';'IRF_LOW';...
'IRF_UPP';'PHI';'resvar';'msg';'size'],'irf',mres,S,IRF,...
irf_low,irf_upp,PHI,results,msg,siz)
 
for i=1:N
   for j=1:N
      execstr('ans_var'+string(i)+'_to_shock'+string(j)+'=IRF(N*[0:S]+i,j)')
      execstr('res(1)($+1)=''ans_var'+string(i)+'_to_shock'+string(j)+'''')
      execstr('res($+1)=ans_var'+string(i)+'_to_shock'+string(j))
   end
end
 
endfunction
