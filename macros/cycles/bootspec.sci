function rspec = bootspec(y,k,w,sb,B)
 
// PURPOSE: compute cospectra, phase, dynamic correlation and cohesion
// and their confindence band by mean of block-bootstrap
//---------------------------------------------------------------
// INPUTS:
// . y 	= (T x N) matrix having variables on the columns
// . k 	= the lag window size (the default value is k=round(sqrt(T)))
// . w 	= a n-vector of weights ti compute cohesion (equal weights by default)
// .	sb	= size of blocks for block-bootstrap
// . B 	= number of draws
//-----------------------------------------------------------------
// OUPUTS:
// rspec a tlist result:
// . rspec('cohes')  = matrix of cohesion
// . rspec('ucohes') = matrix of upper bound for cohesion
// . rspec('lcohes') = matrix of lower bound for cohesion
// . rspec('coher')  = matrix of coherency
// . rspec('ucoher') = matrix of upper bound for coherency
// . rspec('lcoher') = matrix of lower bound for coherency
// . rspec('cospe')  = matrix of cospectra
// . rspec('ucospe') = matrix of upper bound for cospectra
// . rspec('lcospe') = matrix of upper bound for cospectra
// . rspec('dcorr')  = matrix of dynamic correlations
// . rspec('udcorr') = matrix of upper bound for dynamic correlations
// . rspec('ldcorr') = matrix of lower bound for dynamic correlations
// . rspec('phase')  = matrix of dynamic correlations
// . rspec('uphase') = matrix of upper bound for phase spectrum
// . rspec('lphase') = matrix of lower bound for phase spectrum
// . rspec('order')  = order of arrival of variable in cross-products
//-----------------------------------------------------------------
// Copyright E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
[T,N]=size(y)
 
//number of cross-products
nc1 = N*(N-1)/2
binf1 = (1:nc1:(B-1)*nc1+1)'
bsup1 = (nc1:nc1:B*nc1)'
	
nc2 = N*(N-1)/2 + N	
binf2 = (1:nc2:(B-1)*nc2+1)'
bsup2 = (nc2:nc2:B*nc2)'
 
// first estimation
rspec = spectral0(y,k,w)
 
// draws B new y
[bsy,a] = mvblockboot(y,sb,B)
 
// estimate cospecra, cohesion...
cospeb = zeros(65,B*nc2)
cohesb = zeros(65,1)
coherb = zeros(65,B*nc1)
dcorrb	= zeros(65,B*nc1)
phaseb	= zeros(65,B*nc1)
 
// bootstrap replication
for i=1:B
	ys = bsy(:,a(i,:))
  rboot=spectral0(ys,k,w)
 
  cohesb(:,i) = rboot('cohes')	
	cospeb(:,binf2(i):bsup2(i)) = rboot('cospe')
  coherb(:,binf1(i):bsup1(i)) = rboot('coher')
  dcorrb(:,binf1(i):bsup1(i)) = rboot('dcorr')
  phaseb(:,binf1(i):bsup1(i)) = rboot('phase')
 
end 	
 
l = ['dcorr';'coher';'cospe';'cohes';'phase']
for ln = 1:size(l,1)
	execstr('dcm_'+l(ln)+' = zeros(65,nc1)')
	execstr('dcp_'+l(ln)+' = zeros(65,nc1)')
end
 
for i = 1:nc1
	selec1 	= binf1+(i-1)
 
	vdcorr = dcorrb(:,selec1)
	zed = atanh(rspec('dcorr')(:,i)) // Fisher z-transformation  cf. Croux et alii (2001) Appendix B.
	sig = st_dev(atanh(vdcorr),'c')
	dcm_dcorr(:,i)= tanh(zed-1.96*sig)
	dcp_dcorr(:,i)= tanh(zed+1.96*sig)
 
	vcoher = coherb(:,selec1) // Fisher z-transformation  cf. Croux et alii (2001) Appendix B.
	zed = atanh(rspec('coher')(:,i))
	sig = st_dev(atanh(vcoher),'c')
	dcm_coher(:,i)= tanh(zed-1.96*sig)
	dcp_coher(:,i)= tanh(zed+1.96*sig)
	
	vphase = phaseb(:,selec1)
	dcm_phase(:,i) = rspec('phase')(:,i)- 1.96*st_dev(vphase,'c')
	dcp_phase(:,i) = rspec('phase')(:,i)+ 1.96*st_dev(vphase,'c')
	
end
 
for i = 1:nc2
	selec2 = binf2+(i-1)
	vcospe = cospeb(:,selec2)
	dcm_cospe(:,i) = rspec('cospe')(:,i)-1.96*st_dev(vcospe,'c')
	dcp_cospe(:,i) = rspec('cospe')(:,i)+1.96*st_dev(vcospe,'c')
end
 
zed = atanh(rspec('cohes')) // Fisher z-transformation  cf. Croux et alii (2001) Appendix B.
sig = st_dev(atanh(cohesb),'c')
dcm_cohes = tanh(zed-1.96*sig)
dcp_cohes = tanh(zed+1.96*sig)
	
 
for ln =1:size(l,1)
	execstr('rspec(1)($+1) = ''u'+l(ln)+'''')
	execstr('rspec(1)($+1) = ''l'+l(ln)+'''')
	execstr('rspec(''l'+l(ln)+''') = dcm_'+l(ln)')
	execstr('rspec(''u'+l(ln)+''') = dcp_'+l(ln)')
end
 
 
endfunction
