function prtms_quali(r,out);
 
// PURPOSE: print a HMM model based upon qualitative data
// ------------------------------------------------------------
// INPUT:
// * r = the results typed list of a univariate regression
// * out = the symobolic name of the file where the
//              results are printed (default: %io(2))
// ------------------------------------------------------------
// OUPTUT:
// nothing: all results are printed on the specified file
// ------------------------------------------------------------
// Copyright Eric Dubois 2009
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin]=argn(0)
if nargin == 1 then
   out=%io(2)
end
 
meth=r('meth')
namey=r('namey')
 
nblatent=r('nb_latent')
nbstates=r('nb_states')
nbqua=r('nb_quantiles')
nvar=r('nvar')
PX_cond=r('conditional probabilities')
PX_cond_std='('+string(r('PX_cond_std'))+')'
PX_cond_std=strsubst(PX_cond_std,'Nan','c')
PZ_std=string(r('PZ_std'))
PZ_std=strsubst(PZ_std,'Nan','c')
 
write(out,meth+' estimation results')
write(out,' ')
if r('prests') then
   ch='estimation period: '
   boundsvar=r('bounds')
   for i=1:size(boundsvar,1)/2
      ch=ch+boundsvar(2*i-1)+'-'+boundsvar(2*i)+'  '
   end
   write(out,ch)
end
 
write(out,'number of observations: '+string(r('nobs')))
write(out,'number of variables: '+string(nvar))
write(out,'number of latent states: '+string(nblatent))
write(out,'Log likelihood: '+string(r('llike')))
write(out,' ')
 
select nblatent
case 1 then
   write(out,'=================Matrix of markovian transition probabilities P(Zt/Zt-1): ==================');
   write(out,'=================          [standard errors between brackets]             ==================');
   write(out,' ')
   mat2print=emptystr(nbstates*3+3,nbstates+1)
   mat2print(1,1)='Z(t+1) \ Z(t)'
   mat2print(1,2:nbstates+1)=string([1:nbstates])
   mat2print(3*[1:nbstates],1)=string([1:nbstates]')
   mat2print(3*[1:nbstates],2:nbstates+1)=' '+string(r('transition probabilities'))+' '
   mat2print(3*[1:nbstates]+1,2:nbstates+1)='('+PZ_std+')'
   latents_names='Z(t)'
   latents=string([1:nbstates])
   printmat(mat2print,out)
 
else
   nbstates=4
   write(out,'=================Matrix of markovian transition probabilities P(Zt/Zt-1): ==================');
   write(out,'=================          [standard errors between brackets]             ==================');
   write(out,' ')
   mat2print=emptystr(9,3)
   mat2print(1,1)='Z(t+1) \ Z(t)'
   mat2print(1,2:3)=string([1:2])
   mat2print(3*[1:2],1)=string([1:2]')
   mat2print(3*[1:2],2:3)=' '+string(r('first transition probabilities'))+' '
   mat2print(3*[1:2]+1,2:3)='('+string(r('PZ_std'))+')'
   printmat(mat2print,out)
   write(out,' ')
 
   write(out,'=================Matrix of markovian transition probabilities P(Wt/Wt-1): ==================');
   write(out,'=================          [standard errors between brackets]             ==================');
   write(out,' ')
   mat2print=emptystr(nbstates*2+2,nbstates+1)
   mat2print(1,1)='W(t+1) \ W(t)'
   mat2print(1,2:3)=string([1:2])
   mat2print(3*[1:2],1)=string([1:2]')
   mat2print(3*[1:2],2:3)=' '+string(r('second transition probabilities'))+' '
   mat2print(3*[1:2]+1,2:3)='('+string(r('PW_std'))+')'
   printmat(mat2print,out)
   nbstates=4
   latents_names='[Z(t),W(t)]'
   latents=['low;strong signal' 'low;weak signal' 'high;strong signal' 'high;weak signal']
   PX_cond_std(:,[2 4])=' '
 
end
 
write(out,' ')
write(out,'================= Matrix of Conditional probabilities :=================')
write(out,'=================  [standard errors between brackets]  =================');
write(out,' ')
for i=1:nvar
   write(out,'variable '+namey(i))
   write(out,' ')
   mat2print=emptystr(nbqua(1)*3+2,nbstates+1)
   mat2print(1,1)='value \ '+latents_names
   mat2print(1,2:nbstates+1)=string(latents)
   mat2print(3*[1:nbqua(1)]-1,1)=string([1:nbqua(1)]')
   mat2print(3*[1:nbqua(1)]-1,2:nbstates+1)=' '+string(PX_cond((i-1)*nbqua(1)+[1:nbqua(1)],:))+' '
   mat2print(3*[1:nbqua(1)],2:nbstates+1)=PX_cond_std((i-1)*nbqua(1)+[1:nbqua(1)],:)
   printmat(mat2print,out)
   write(out,' ')
end
write(out,'(c): value constrained to a corner solution')
 
endfunction
 
