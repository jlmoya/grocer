function [s_fx,s_z,s_fz]=filt_ms_2latent(matf,theta);
 
// PURPOSE: filter applied to the
// ------------------------------------------------------------
// INPUT:
// * matf = a (T x nvar) matrix of data
// * theta = a (nbquaam x 1) vector of parameters
// ------------------------------------------------------------
// OUTPUT:
// * s_fx  = a (nbstates x 1) vector of conditional probabilities
//   (P(X_t|I_t)
// * s_z = a (nbstates x T) matrix of filetered probabilities
//   (P(Z_t|I_t)
// * s_fz = a (nbstates x T) matrix of forecasted probabilities
//   (P(Z_{t+1}|I_t)
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated from a Gauss programm by J. Bardaji and F. Tallet
 
 
nf=size(matf,1);
 
s_fx=zeros(nf,1);
s_z=zeros(nbstates,nf);
s_fz=zeros(nbstates,nf);
 
[PZ,PX_c,PZ_ti,PW]=Write_matrices_2latent(theta);
if variante_inno==1 then
   v1=theta(5+2*(nbqua(1)-1)*nvar:5+(2*nbqua(1)-1)*nvar,1);
   v2=theta(6+(2*nbqua(1)-1)*nvar:6+2*nbqua(1)*nvar,1);
end
i_PX=matrix(PX_c(:),nbqua(1),nvar*nbstates)
 
// initialisation: probabilities on the hidden variable at date 0
// are equal to the stationnary probabilities associated to the
// Markovian dynamics
PZ_tini=ini_eta(PZ);
 
s_fz(:,1)=PZ_tini(:,1);
i_mat=ones(nbstates,1) .*. matrix(matf(1,:)',nbqua(1),nvar)';
p_PX=matrix(diag(i_mat*i_PX),nvar,nbstates)'
 
// replace all 0 by 1
p_PX(p_PX==0)=1
 
s_z(:,1)=s_fz(:,1).*prod(p_PX,'c');
s_fx(1)=sum(s_z(:,1));
s_z(:,1)=s_z(:,1)/s_fx(1);
 
// calculation of the conditionnal likelihood by recurrence
for i=2:nf;
   if variante_inno==1 then
      PZ=calcul_PZ(PZ_ti,PW,v1,v2,mat_inno(i-1,:));
   end
   s_fz(:,i)=(PZ.^puis(i))*s_z(:,i-1);
   i_mat=ones(nbstates,1) .*. matrix(matf(i,:)',nbqua(1),nvar)';
 
   p_PX=matrix(diag(i_mat*i_PX),nvar,nbstates)'
   p_PX(p_PX==0)=1
   s_z(:,i)=s_fz(:,i) .* prod(p_PX,'c');
   s_fx(i)=sum(s_z(:,i));
   s_z(:,i)=s_z(:,i)/s_fx(i);
end
 
 
endfunction
 
 
