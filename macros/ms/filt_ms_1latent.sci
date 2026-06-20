function [s_fx,s_z,s_fz]=filt_ms_1latent(matf,theta);
 
// PURPOSE: filter applied to a HMM turning point model with J
// latent states
// ------------------------------------------------------------
// INPUT:
// * matf = a (T x nvar) matrix of data coded with 0 and 1
// * theta = a (nbquaam x 1) vector of parameters
// ------------------------------------------------------------
// OUTPUT:
// * s_fx  = a (T x 1) vector of conditional probabilities
//   (P(X_t|I_t)
// * s_z = a (nbstates x T) matrix of filetered probabilities
//   (P(Z_t|I_t)
// * s_fz = a (nbstates x T) matrix of forecasted probabilities
//   (P(Z_{t+1}|I_t)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated and adaptated from a Gauss programm by
// J. Bardaji and F. Tallet
 
 
nf=size(matf,1);
 
s_fx=zeros(nf,1);
s_z=zeros(nbstates,nf);
s_fz=zeros(nbstates,nf);
 
[PZ,PX_c]=Write_matrices(theta);
i_PX=matrix(PX_c,nbqua(1),nvar*nbstates)
 
// initialisation: probabilities on the hidden variable at date 0
// are equal to the stationnary probabilities associated to the
// Markovian dynamics
s_fz(:,1)=ini_eta_BB(PZ');
i_mat=ones(nbstates,1) .*. matrix(matf(1,:)',nbqua(1),nvar)'
p_PX=matrix(diag(i_mat*i_PX),nvar,nbstates)'
// replace all 0 by 1
p_PX(p_PX==0)=1
 
s_z(:,1)=s_fz(:,1).*prod(p_PX,'c');
s_fx(1)=sum(s_z(:,1));
s_z(:,1)=s_z(:,1)/s_fx(1);
// calculation of the conditionnal likelihood by recurrence
for i=2:nf;
   if var_inno==1 then
      PZ=calcul_PZ(PZ_ti,PW,v1,v2,mat_inno(i-1,:));
   end
   s_fz(:,i)=(PZ.^puis(i))*s_z(:,i-1);
   i_mat=ones(nbstates,1) .*. matrix(matf(i,:),nbqua(1),nvar)'
 
   p_PX=matrix(diag(i_mat*i_PX),nvar,nbstates)'
 
   p_PX(p_PX==0)=1
   s_z(:,i)=s_fz(:,i) .* prod(p_PX,'c');
   s_fx(i)=sum(s_z(:,i));
   s_z(:,i)=s_z(:,i)/s_fx(i);
end
 
 
endfunction
 
 
