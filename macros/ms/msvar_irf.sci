function resirf=msvar_irf(res,hor,varargin)
 
// PURPOSE: provide the impulse response functions (irf) from a
// Markov-switching VAR
// ------------------------------------------------------------
// INPUT:
// * res = a tlist result from a ms var estimation
// * hor = a scalar, the horizon of the irf (note that the
//   shocks are supposed to happen at time 0; therefore (hor+1)
//   impulses are calculated)
// * mres = optional argument that can be:
//   - x = chol1 (cholesky decomposition)
//   - x = chol2 (triangular factorisation)
//   - x = original (original residuals)
//     (default = chol1)
// ------------------------------------------------------------
// OUTPUT:
// resirf = a result tlist with:
// - resirf('meth') = 'msvar irf'
// - resirf('msvar res') = the input ms var results tlist
// - resirf('# irf') = the horizon of the irf calculations
// - resirf('nb states') = the # of states
// - resirf('nb irf') = the # of different AR parts
//   * 1 if they do not switch
//   * the # states if they switcch
// - resirf('sigma switch') = the # of switching wariances
//   * 1 if they do not switch
//   * the # states if they switch
// 1) if both are equal to 1 then
// - resirf('irf') = the only set of impulse repsonse function,
//    a (nvar.hor x nvar) matrix:
//   [IRF(t=0)
//       .
//       .
//       .
//   IRF(t=hor)]
//   , with nvar= # of endogenous varaibles in the VAR
//
// 2) if resirf('nb states') == 1 and resirf('sigma switch') ~= 1
//   then:
// - resirf('irf state # 1') until resirf('irf state # ''nstates''')=
//   the set of impulse repsonse function, each a (nvar.hor x nvar)
//   matrix:
//   [IRF(t=0)
//       .
//       .
//       .
//   IRF(t=hor)]
//   conditional of the state of the shock
//
// 3) if resirf('nb states') == 1 and resirf('sigma switch') ~= 1
//   then:
// - resirf('irf part state # 1') until
//   resirf('irf part state # ''nstates''')=
//   the set of impulse response function, each a (nvar.hor x nvar)
//   matrix:
//   [IRF(t=0)
//       .
//       .
//       .
//   IRF(t=hor)]
//   conditional of the state of the shock and the fact that
//   the state does not switch (not realistic, but useful to
//   the analysis of the VAR associated to each regime)
// - resirf('irf full state # 1') until
//   resirf('irf fulle state # ''nstates''')=
//   the set of full impulse response function, each a
//   (nvar.hor x nvar) matrix:
//   [IRF(t=0)
//       .
//       .
//       .
//   IRF(t=hor)]
// ------------------------------------------------------------
// REFERENCE:
// Krolzig H-M., 2006, "Impulse-Response Analysis in Markov
// Switching Vector Autoregressive Models," Economics
// Department. University of Kent. Keynes College,
// http://f.karame.free.fr/IUP_IES/Var_Lat/Projets/Krolzig.pdf
// ------------------------------------------------------------
// Copyright: Eric Dubois 2011
// http://grocer.toolbox.free.fr/grocer.html
 
mres='chol2'
meth='asym'
niter=1000
siz=0.05
 
if res('meth') ~= 'ms var' then
   error('first arg should be a ms var results tlist')
end
 
for i=1:length(varargin)
   ieq=strindex(varargin(i),'=')
   car1=part(varargin(i),1:ieq-1)
   l=length(varargin(i))
 
   if car1 == 'mres' then
      mres=part(varargin(i),ieq+1:l)
   end
end
 
if and(meth ~= ['asym' ; 'mc1']) then
   error(meth+' is not an available method to compute confidence bands in irf')
end
 
beta_id=res('beta_id')
beta_co=res('beta_co')
nlag=res('nlag')
nendo=res('nendo')
sigma_switch=res('switching V')
nobs=res('nobs')
nb_states=res('nb_states')
resirf=tlist(['results';'meth';'msvar res';'# irf';'nb states';'# AR';'sigma switch';'innovation type'],...
'msvar irf',res,hor,nb_states,1-(nb_states-1)*(res('typemod')-3),sigma_switch,[])
 
if isempty(beta_co) then
   xmat=res('xmat')
   x=xmat(1:nobs,1:nendo*nlag)
   [xpxi]=invxpx(x)
 
   // prepare the matrix [PI M] (equation 28 in Krolzig paper)
   PI_n_M=[]
   ptrans=res('ptrans')
   sigma=res('sigma')
   if sigma_switch == 1 then
      select mres
      case 'chol1' then
         // Cholesky of omega = P'*P
         msg = 'orthogonalized 1 std deviation';
         P = chol(sigma)';
      case 'chol2' then
         // triangular fact. omega = A*D*A'
         msg = 'orthogonalized 1 unit';
         cholsigmap    = chol(sigma)'
         Dsr = diag(diag(cholsigmap));
         P = inv(Dsr)*cholsigmap;
      else
         msg = 'unorthogonalized 1 unit';
         P = eye(nendo,nendo)   ;
      end
      shocks= [[(eye(nb_states,nb_states) .*. [1 ; zeros(nlag-1,1)]) .*. P] ; zeros(nb_states,nb_states*nendo)]
   else
      shocks=zeros(nb_states*nendo*nlag+nb_states,nb_states*nendo)
   end
 
   for i=1:nb_states
      if sigma_switch ~= 1 then
         // the matrix of shocks depends on the regime
         sigma_i=sigma(:,nendo*(i-1)+1:i*nendo)
         select mres
         case 'chol1' then
            // Cholesky of omega = P'*P
            msg = 'orthogonalized 1 std deviation';
            P = chol(sigma_i)';
         case 'chol2' then
            // triangular fact. omega = A*D*A'
            msg = 'orthogonalized 1 unit';
            cholsigmap    = chol(sigma_i)'
            Dsr = diag(diag(cholsigmap));
            P = inv(Dsr)*cholsigmap;
         else
            N=res('nendo')
            msg = 'unorthogonalized 1 unit';
            P = eye(nendo,nendo);
         end
         shocks(nendo*nlag*(i-1)+1:nendo*nlag*(i-1)+nendo,nendo*(i-1)+1:nendo*i)=P
      end
 
      beta_i=beta_id(:,i)
      beta_const=beta_i((nendo*nlag+1)*[1:nendo])
      // remove constants from the beta vector
      beta_i((nendo*nlag+1)*[1:nendo])=[]
      beta_i=matrix(beta_i,nendo*nlag,nendo)'
 
      [IRF_part,PHI]=irf0(beta_i',hor,nendo,nlag,P)
      resirf(1)($+1)='irf part state # '+string(i)
      resirf($+1)=IRF_part
 
      // now build the [A1 ... Ap nu] matrix (see equation 36 in Krolzig paper)
      // build matrix Am in equation 36 in Krolzig paper
      Am=[beta_i ; [ eye((nlag-1)*nendo,(nlag-1)*nendo) zeros((nlag-1)*nendo,nendo) ] ]
      // build the block i of matrix PI in equation 28 in Krolzig paper
      PI=ptrans(i,:) .*. Am
      //  build block i of matrix M (see equations 28 and 36 in Krolzig paper)
      M=ptrans(i,:) .*. [beta_const ; zeros((nlag-1)*nendo,1) ]
      // build progressively the block [PI M] in equation 28 by adding the line i of equation (26)
      PI_n_M=[PI_n_M ; PI M ]
   end
 
   // end the PI matrix with the addition of block [O F] in equation 28
   PI=[PI_n_M ; zeros(nb_states,nendo*nlag*nb_states) ptrans]
   PSI_j=shocks
   mat_left=ones(1,nb_states) .*. ([1 zeros(1,nlag-1)] .*. eye(nendo,nendo))
   IRF_FULL = [mat_left*shocks(1:$-nb_states,:) ; zeros(hor*nendo,nendo*nb_states)]
   for j=1:hor
      PSI_j=PI*PSI_j
      IRF_FULL(j*nendo+1:(j+1)*nendo,:)=mat_left*PSI_j(1:$-nb_states,:)
   end
// note: I build the full matrix PSI_j, but uses for the moment only the (1,1) block of this matrix
// which could be calculated more easily; the full matrix is however needed for the IRF pertaining to
// regime shocks
 
   for i=1:nb_states
      resirf(1)($+1)='irf full state # '+string(i)
      resirf($+1)=IRF_FULL(:,nendo*(i-1)+1:nendo*i)
 
   end
 
else
   // case when AR terms do not switch
   x=res('zmat')
   [xpxi]=invxpx(x)
   beta_i=matrix(beta_co,nendo*nlag,nendo)
 
   if sigma_switch == 1 then
   // variances do not switch: the impulse response functions are not regime dependent
      sigma=res('sigma')
 
      select mres
      case 'chol1' then
         // Cholesky of omega = P'*P
         msg = 'orthogonalized 1 std deviation';
         P = chol(sigma)';
      case 'chol2' then
         // triangular fact. omega = A*D*A'
         msg = 'orthogonalized unit';
         cholsigmap    = chol(sigma)'
         Dsr = diag(diag(cholsigmap));
         P = inv(Dsr)*cholsigmap;
      else
         msg = 'unorthogonalized 1 unit';
         P = eye(nendo,nendo);
      end
 
      [IRF,PHI]=irf0(beta_i,hor,nendo,nlag,P)
      resirf(1)($+1)='irf'
      resirf($+1)=IRF
 
   else
      for i=1:nb_states
         sigma=res('sigma')
         sigma=sigma(:,nendo*(i-1)+1:i*nendo)
 
         select mres
         case 'chol1' then
            // Cholesky of omega = P'*P
            msg = 'orthogonalized 1 std deviation';
            P = chol(sigma)';
         case 'chol2' then
            // triangular fact. omega = A*D*A'
            msg = 'orthogonalized unit';
            cholsigmap    = chol(sigma)'
            Dsr = diag(diag(cholsigmap));
            P = inv(Dsr)*cholsigmap;
         else
            N=res('nendo')
            msg = 'unorthogonalized 1 unit';
            P = eye(nendo,nendo);
         end
 
         [IRF,PHI]=irf0(beta_i,hor,nendo,nlag,P)
         resirf(1)($+1)='irf state #'+string(i)
         resirf($+1)=IRF
      end
   end
 
end
resirf('innovation type')=msg
 
endfunction
