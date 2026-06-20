function res=rolirf(results,S,varargin)
 
// PURPOSE: Calculates Impulse Response Function for rolling
// VAR
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
// - res('meth') = 'rolling irf'
// - res('rolling var results') = the rolling Var results tlist
//   entered as input to rolrif
// - res('mres') = decomposition method
// - res('T') = # of periods represented
// - res('IRF') = (nrolling x (S+1) x T) impulse response
//   functions (with nrolling = # of rolling VAR estimated)
// - res('IRF_LOW') = (nrolling x (S+1) x T) lower range of impulse
//                     response confidence band
// - res('IRF_UPP') = (nrolling x (S+1) x T) upper range of impulse
//                     response confidence band
// - res('PHI') = (nrolling x N*p x T) matrix of coefficients
// - res('msg') = message inidicating the nature of the
//   decomposition
// - res('size') = size of the confidence band
// - res('ans_var 1 to_shock 1') ...
//   until res('ans_var n to_shock n') = a (nrolling x N*p x T)
//   matrix collecting all irf of one variabel at a time to
//   a shock at a time
//-------------------------------------------------------------
// Copyright E. Dubois (2014)
// http://grocer.toolbox.free.fr/grocer.html
 
 
mres='chol1'
meth='none'
niter=1000
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
   case 'niter' then
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
nestim=size(bet,1)
 
IRF=zeros(nestim,N*(S+1),N)
PHI=zeros(nestim,N,N*p)
 
if or(meth == ['asym' ; 'mc1']) then
   irf_low=IRF
   irf_upp=IRF
else
   irf_low=[]
   irf_upp=[]
end
 
for i=1:nestim
   bet_i=squeeze(bet(i,:,:))
   sigma_i=squeeze(sigma(i,:,:))
   // ---- Determine decomposition of Cov matrix -----------------
 
   select mres
   case 'chol1' then
       // Cholesky of omega = P'*P
      msg = 'Orthog. IRF: 1 sigma changes';
      P = chol(sigma_i)';
   case 'chol2' then
       // triangular fact. omega = A*D*A'
      msg = 'Orthog. IRF: 1 unit changes';
      cholsigmap    = chol(sigma_i)'
      Dsr = diag(diag(cholsigmap));
      P = inv(Dsr)*cholsigmap;
   else
      msg = 'Unorthog. IRF: 1 unit changes';
      P = eye(N,N);
   end
 
   [IRF_i,PHI_i]=irf0(bet_i,S,N,p,P)
   IRF(i,:,:)=IRF_i
   PHI(i,:,:)=PHI_i
 
   select meth
   case 'asym' then
      [irf_low_i,irf_upp_i]=irf_asy(results,mres,P,IRF,PHI_i,S,siz)
      irf_low(i,:,:)=irf_low_i
      irf_upp(i,:,:)=irf_upp_i
   case 'mc1' then
      [irf_low_i,irf_upp_i]=irf_mc1(results,mres,S,N,p,niter,siz)
      irf_low(i,:,:)=irf_low_i
      irf_upp(i,:,:)=irf_upp_i
   end
end
 
 
res=tlist(['results';'meth';'rolling var results';'mres';'T';'IRF';'IRF_LOW';...
'IRF_UPP';'PHI';'msg';'size'],'rolling irf',results,mres,S,IRF,...
irf_low,irf_upp,PHI,msg,siz)
 
for i=1:N
   for j=1:N
      execstr('ans_var'+string(i)+'_to_shock'+string(j)+'=IRF(:,N*[0:S]+i,j)')
      execstr('res(1)($+1)=''ans_var'+string(i)+'_to_shock'+string(j)+'''')
      execstr('res($+1)=ans_var'+string(i)+'_to_shock'+string(j))
   end
end
 
 
endfunction
