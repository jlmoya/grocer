function rspec = deltaspec(sig,vtheta,AR,MA)
 
// PURPOSE: compute asymptotic confidence band by delta-method
//-----------------------------------------------------------
// INPUTS:
// . sig      = variance-covariance matrix of residuals
// . vtheta   = global variance-covariance matrix of estimated parameters
// . AR       = matrix of AR coefficients ar = [A1 .. Ap]
// . MA       = matrix of MA coefficients ma = [B1 .. Bq]
//-----------------------------------------------------------
// OUPUTS:
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
// . rspec('phase')  = matrix of phase spectrum
// . rspec('uphase') = matrix of upper bound for phase spectrum
// . rspec('lphase') = matrix of lower bound for phase spectrum
// . rspec('order')  = order of arrival of variable in cross-products
// . rspec('omega')  = vector of frequencies
//-----------------------------------------------------------
// REFERENCE:
// H. Lutkepohl (1993), "Introduction to multivariate times
// series analysis", ed. Springer-Verlag, pp.27
//-----------------------------------------------------------
// Free adaptation from J. Matheron, CRECH, Banque de France
// by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
// compute spectral analysis
omega = 0:%pi/64:%pi
nomega = size(omega,2)
 
rspec = specvarma1(sig,AR,MA,omega)
cospe0 = rspec('cospe')
coher0 = rspec('coher')
cohes0 = rspec('cohes')
dcorr0 = rspec('dcorr')
phase0 = rspec('phase')
 
//number of cross-products
N = size(AR,1)
nc = N*(N-1)/2
 
nparm = size(vtheta,2)
vecar0 = vec(AR)
vecma0 = vec(MA)
vhsig0 = vech(sig)
 
mvtheta = zeros(nomega,nomega) // (nomega X nomega) vcv matrix of paramaters
mvtheta(1:nparm,1:nparm) = vtheta
 
if N > 1 then
 
  dcohes1 = zeros(nomega,nc)
  dcorr_b = zeros(nomega,nc)
  phase_b = zeros(nomega,nc)
  coher_b = zeros(nomega,nc)
  cohes_b = zeros(nomega,nc)
  cospe_b = zeros(nomega,nc)
  for nm = 1:nc
	  execstr('ddcorr1_'+string(nm)+' = zeros(nomega,nparm)')
		execstr('dphase1_'+string(nm)+' = zeros(nomega,nparm)')
		execstr('dcoher1_'+string(nm)+' = zeros(nomega,nparm)')
	end
  for nm = 1:nc+N
	  execstr('dcospe1_'+string(nm)+' = zeros(nomega,nparm)')
  end
 
  // delta-method to compute asymptotic confidence interval
  for nn = 1:nparm // shocked each parameters
    vecar1 = vecar0
    vecma1 = vecma0
    vhsig1 = vhsig0
 
    vecar2 = vecar0
    vecma2 = vecma0
    vhsig2 = vhsig0
 
    if nn <= size(vecar0,1) then
      eps = sqrt(%eps)*(1+1d-3*abs(vecar1(nn)))
      vecar1(nn) = vecar1(nn)-eps
      vecar2(nn) = vecar2(nn)+eps
    elseif (size(vecar0,1) < nn) & (nn <= size(vecar0,1)+size(vecma0,1)) & ~isempty(vecma0) then
      n1 = nn-size(vecar0,1)
      eps = sqrt(%eps)*(1+1d-3*abs(vecma1(n1)))
      vecma1(n1) = vecma1(n1)-eps
      vecma2(n1) = vecma2(n1)+eps
    else
      n2 = nn-size(vecar0,1)-size(vecma0,1)
      eps = sqrt(%eps)*(1+1d-3*abs(vhsig1(n2)))
      vhsig1(n2)= vhsig1(n2)-eps
      vhsig2(n2)= vhsig2(n2)+eps
    end
 
    sig1 = invvech(vhsig1,N)
    AR1  = matrix(vecar1,size(AR,1),size(AR,2))
    MA1  = matrix(vecma1,size(MA,1),size(MA,2))
 
    sig2 = invvech(vhsig2,N)
    AR2  = matrix(vecar2,size(AR,1),size(AR,2))
    MA2  = matrix(vecma2,size(MA,1),size(MA,2))
 
    rspec1 = specvarma1(sig1,AR1,MA1,omega)
    cospe1 = rspec1('cospe')
    coher1 = rspec1('coher')
    cohes1 = rspec1('cohes')
    dcorr1 = rspec1('dcorr')
    phase1 = rspec1('phase')
 
    rspec2 = specvarma1(sig2,AR2,MA2,omega)
    cospe2 = rspec2('cospe')
    coher2 = rspec2('coher')
    cohes2 = rspec2('cohes')
    dcorr2 = rspec2('dcorr')
    phase2 = rspec2('phase')
 
      // compute partial derivatives
    for nm = 1:nc
      execstr('ddcorr1_'+string(nm)+'(:,'+string(nn)+') = ('+string(1)+'/(2*'+string(eps)+...
                    '))*(dcorr2(:,'+string(nm)+')-dcorr1(:,'+string(nm)+'))')
      execstr('dphase1_'+string(nm)+'(:,'+string(nn)+') = ('+string(1)+'/(2*'+string(eps)+...
                    '))*(phase2(:,'+string(nm)+')-phase1(:,'+string(nm)+'))')
      execstr('dcoher1_'+string(nm)+'(:,'+string(nn)+') = ('+string(1)+'/(2*'+string(eps)+...
                    '))*(coher2(:,'+string(nm)+')-coher1(:,'+string(nm)+'))')
    end
 
    for nm = 1:nc+N
        execstr('dcospe1_'+string(nm)+'(:,'+string(nn)+') = ('+string(1)+'/(2*'+string(eps)+'))*(cospe2(:,'+string(nm)+')-cospe1(:,'+string(nm)+'))')
    end
    dcohes1(:,nn) = (1/(2*eps))*(cohes2-cohes1)
 
  end
 
 
  for nm = 1:nc
    execstr('dcorr_b(:,'+string(nm)+') = sqrt(diag([ddcorr1_'+string(nm)+...
                      ' zeros(nomega,nomega-nparm)]*mvtheta*[ddcorr1_'+string(nm)+' zeros(nomega,nomega-nparm)]''))')
    execstr('phase_b(:,'+string(nm)+') = sqrt(diag([dphase1_'+string(nm)+....
                      ' zeros(nomega,nomega-nparm)]*mvtheta*[dphase1_'+string(nm)+' zeros(nomega,nomega-nparm)]''))')
    execstr('coher_b(:,'+string(nm)+') = sqrt(diag([dcoher1_'+string(nm)+...
                       ' zeros(nomega,nomega-nparm)]*mvtheta*[dcoher1_'+string(nm)+' zeros(nomega,nomega-nparm)]''))')
  end
  for nm = 1:nc+N
     execstr('cospe_b(:,'+string(nm)+') = sqrt(diag([dcospe1_'+string(nm)+' zeros(nomega,nomega-nparm)]*mvtheta*[dcospe1_'+string(nm)+' zeros(nomega,nomega-nparm)]''))')
  end
  cohes_b = sqrt(diag([dcohes1 zeros(nomega,nomega-nparm)]*mvtheta*[dcohes1 zeros(nomega,nomega-nparm)]'))
 
  rspec(1)($+1) = 'ucospe'
  rspec(1)($+1) = 'lcospe'
  rspec(1)($+1) = 'ucohes'
  rspec(1)($+1) = 'lcoher'
  rspec(1)($+1) = 'ucoher'
  rspec(1)($+1) = 'lcohes'
  rspec(1)($+1) = 'udcorr'
  rspec(1)($+1) = 'ldcorr'
  rspec(1)($+1) = 'uphase'
  rspec(1)($+1) = 'lphase'
  rspec('ucospe') = cospe0+1.96*cospe_b
  rspec('lcospe') = cospe0-1.96*cospe_b
  rspec('ucohes') = cohes0+1.96*cohes_b
  rspec('lcohes') = cohes0-1.96*cohes_b
  rspec('ucoher') = coher0+1.96*coher_b
  rspec('lcoher') = coher0-1.96*coher_b
  rspec('udcorr') = dcorr0+1.96*dcorr_b
  rspec('ldcorr') = dcorr0-1.96*dcorr_b
  rspec('uphase') = phase0+1.96*phase_b
  rspec('lphase') = phase0-1.96*phase_b
 
else
 	dcospe = zeros(nomega,nparm)
  for nn = 1:nparm // shocked each parameters
    vecar1 = vecar0
    vecma1 = vecma0
    vhsig1 = vhsig0
 
    vecar2 = vecar0
    vecma2 = vecma0
    vhsig2 = vhsig0
 
    if nn <= size(vecar0,1) then
      eps = sqrt(%eps)*(1+1d-3*abs(vecar1(nn)))
      vecar1(nn) = vecar1(nn)-eps
      vecar2(nn) = vecar2(nn)+eps
    elseif (size(vecar0,1) < nn) & (nn <= size(vecar0,1)+size(vecma0,1)) & ~isempty(vecma0) then
      n1 = nn-size(vecar0,1)
      eps = sqrt(%eps)*(1+1d-3*abs(vecma1(n1)))
      vecma1(n1) = vecma1(n1)-eps
      vecma2(n1) = vecma2(n1)+eps
    else
      n2 = nn-size(vecar0,1)-size(vecma0,1)
      eps = sqrt(%eps)*(1+1d-3*abs(vhsig1(n2)))
      vhsig1(n2)= vhsig1(n2)-eps
      vhsig2(n2)= vhsig2(n2)+eps
    end
 
    sig1 = invvech(vhsig1,N)
    AR1  = matrix(vecar1,size(AR,1),size(AR,2))
    MA1  = matrix(vecma1,size(MA,1),size(MA,2))
 
    sig2 = invvech(vhsig2,N)
    AR2  = matrix(vecar2,size(AR,1),size(AR,2))
    MA2  = matrix(vecma2,size(MA,1),size(MA,2))
 
    rspec1 = specvarma1(sig1,AR1,MA1,omega)
    cospe1 = rspec1('cospe')
 
    rspec2 = specvarma1(sig2,AR2,MA2,omega)
    cospe2 = rspec2('cospe')
 
      // compute partial derivatives
 
    dcospe1(:,nn) = (1/(2*eps))*(cospe2-cospe1)
  end
 
  cospe_b = sqrt(diag([dcospe1 zeros(nomega,nomega-nparm)]*mvtheta*...
            [dcospe1 zeros(nomega,nomega-nparm)]))
 
  rspec(1)($+1) = 'ucospe'
  rspec(1)($+1) = 'lcospe'
  rspec(1)($+1) = 'ucohes'
  rspec(1)($+1) = 'lcohes'
  rspec(1)($+1) = 'ucoher'
  rspec(1)($+1) = 'lcoher'
  rspec(1)($+1) = 'udcorr'
  rspec(1)($+1) = 'ldcorr'
  rspec(1)($+1) = 'uphase'
  rspec(1)($+1) = 'lphase'
  rspec('ucospe') = cospe0+1.96*cospe_b
  rspec('lcospe') = cospe0-1.96*cospe_b
  rspec('ucohes') = %nan
  rspec('lcohes') = %nan
  rspec('ucoher') = %nan
  rspec('lcoher') = %nan
  rspec('udcorr') = %nan
  rspec('ldcorr') = %nan
  rspec('uphase') = %nan
  rspec('lphase') = %nan
 
end
 
 
 
endfunction
