function [P_smoothed,P_filtered]=ms_quali_smooth(matf,theta);
 
// PURPOSE: Computes the smoothed probabilities
// ------------------------------------------------------------
// INPUT:
// * matf = matrix of data
// * tehta = vector of parameters
// ------------------------------------------------------------
// OUTPUT:
// * P_smoothed = smoothed probabilities
// * P_filtered = filtered probabilities
// ------------------------------------------------------------
// Copyright: Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
// Translated from a gauss programm by J. Bardaji and F. Tallet
 
nf=size(matf,1);
P_smoothed=zeros(nbstates,nf)
 
PZ=Write_matrices(theta);
[s_fx,P_filtered,s_fz]=ms_quali_filt(matf,theta)
P_smoothed(:,nf)=P_filtered(:,nf)
 
for i=nf-1:-1:1
   P_smoothed(:,i)=(PZ'*(P_smoothed(:,i+1) ./ s_fz(:,i+1))) .* P_filtered(:,i)
end
 
endfunction
 
 
