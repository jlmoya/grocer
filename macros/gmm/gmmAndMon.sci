function [band,uout,D,eflag] = gmmAndMon(gmmopt,e,M,Z)
 
// PURPOSE : Andrews-Monahan HAC estimators
// -------------------------------------------------------------------
// Calculate objects needed by gmmS for Andrews-Monahan HAC estimate.
// Basic idea is to take residuals from normal estimation then fit a
// simple time-series model such as VAR(p), ARMA(1,1), AR(1), or MA(q), then use
// these 'whitened' residuals to calculate the spectral density matrix.
// The parameters of the auxillary time-series model are used to 'recolor'
// the spectral density matrix of the whitened residuals.
//
// Another key feature is the use of the quadratic-spectral kernel with
// 'automatic' bandwidth selection.  This procedure still requires choosing
// a weighting matrix to the relative importance of each of the disturbance
// vectors.  I use the inverse of the standard deviation of the residuals
// as weights in attempt to make the bandwidth selection scale-invariant.
// This effort seems to be partially successful.
//
// The procedure can also be used to generate the automatic bandwidth,
// but without the pre-whitening. This is the Andrews procedure, and is
// implemented by setting gmmopt('aminfo')('nowhite') = 1.
// -------------------------------------------------------------------
// INPUTS: gmmopt tlist from GMM estimation which revelant arguments are
// . gmmopt('prt') = printing (0=none, 1=screen,else file)	[1]
// . gmmopt('aminfo')= a list with fields:
//      aminfo('p') = autoregressive lags (p<=1 for arma models)		[1]
//      aminfo('q') = moving average lags			[0]
//      aminfo('vardum')= 1 for VAR(p) (overrides q)		[0]
//      aminfo('kernel') =  weighting scheme for lags		['QS']
//      aminfo('nowhite') = 1 suppresses pre-whitening		[0]
//      aminfo('diagdum')  =1 for diagnostic graphs			[0]
// . e	 =	matrix of residuals -- we want its spectral density
// . M	 =	Jacobian (derivative of moments wrt parameters)
// . Z		= instruments
// -------------------------------------------------------------------
// OUTPUTS:
//  . band	=	bandwidth determined from the data
//  . uout	=	matrix of whitened residuals
//  . D =		matrix to 're-color' spectral density of whitened resids
//  . eflag	=1 if an error in estimating ARMA model, else 0
// -------------------------------------------------------------------
// REFERENCES:
// - Donald W. K. Andrews (1991), "Heteroskedasticity and Autocorrelation
//      Consistent Covariance Matrix Estimation", Econometrica, 59, 817-858
// - Donald W. K. Andrews & J. Christopher Monahan (1992), "An Improved
//      Heteroskedasticity and Autocorrelation Consitent Covariance Matrix",
//      Econometrica, 64, 953-966.
// - Wouter J. den Hann & Andrew Levin (1997), "A Practitioner's Guide to Robust Covariance
//      Matrix Estimation", forthcoming in Handbook of Statistics.
// -------------------------------------------------------------------
// WRITTEN BY:  Mike Cliff, Purdue Finance,  mcliff@mgmt.purdue.edu
// VERSION 1.1
// CREATED: 11/6/99
//
// E. Michaux (2007)  for the scilab translation and the VAR(p) part
// http://grocer.toolbox.free.fr/grocer.html
 
out=%io(2)
 
 
// Set Defaults
allf=getfield(1,gmmopt);
tf=or(allf=='prt');
if ~tf then
  gmmopt(1)($+1) = 'prt';
  gmmopt('prt') = 1;
end
 
allf=getfield(1,gmmopt('aminfo'));
tf=or(allf=='q');
if ~tf then
  gmmopt('aminfo')(1)($+1) =  'q';
  gmmopt('aminfo')('q') = 1;
end
tf=or(allf=='kernel');
if ~tf then
  gmmopt('aminfo')(1)($+1)='kernel';
  gmmopt('aminfo')('kernel') = 'QS';
end
 
tf=or(allf=='p');
if ~tf then
  gmmopt('aminfo')(1)($+1) =  'p';
  gmmopt('aminfo')('p') = 1;
end
 
tf=or(allf=='vardum');
if ~tf then
  gmmopt('aminfo')(1)($+1) =  'vardum';
  gmmopt('aminfo')('vardum') = 0;
end
 
tf=or(allf=='diagdum');
if ~tf then
  gmmopt('aminfo')(1)($+1) =  'diagdum';
  gmmopt('aminfo')('diagdum') = 0;
end
 
tf=or(allf=='nowhite');
if ~tf then
  gmmopt('aminfo')(1)($+1) =  'nowhite';
  gmmopt('aminfo')('nowhite') = 0;
end
 
eflag = 0;
aminfo = gmmopt('aminfo');
p = aminfo('p');
q = aminfo('q');
vardum = aminfo('vardum');
diagdum = aminfo('diagdum');
nobs = size(e,1);
 
select aminfo('kernel');
  case 'H'
    const = 0.6611;
    ktype = 2;
    kname = 'Truncated (Hansen)';
  case 'NW'
    const = 1.1447;
    ktype = 1;
    kname = 'Bartlett (Newey-West)';
  case 'G'
    const = 2.6614;
    ktype = 2;
    kname = 'Parzen (Gallant)';
  case 'QS'
    const = 1.3221;
    ktype = 2;
    kname = 'Quadratic-Spectral';
  case 'TH'
    const = 1.7462;
    ktype = 2;
    kname = 'Tukey-Hanning';
  else
    error('Need kernel in ANDMON');
end
 
if p > 0
  if (p > 1) & (vardum~=1) then
    error('ANDMON written for p<=1 in ARMA(p,q)');
  elseif (p > 1) & (vardum==1) & (ktype==1) then
    error('Bartlett kernel is not allowed with VAR(p) in ANDMON');
  elseif q > 1 then
    error('ANDMON written for ARMA(p,q), q <=1 when p = 1');
  end
end
 
// Get residuals times instruments
u = [];
for i = 1:size(e,2)
  u = [u repmat(e(:,i),1,size(Z,2)).*Z];
end
north = size(u,2);
In = eye(north,north);
 
// VAR(p) to whiten residuals
if vardum == 1 then
  varout = var1(u,p,[],'nocte');
  Phi=varout('beta')';
  Omega=varout('sigma');
  nvar = size(Omega,1);
  THETA = zeros(north,north);
 
  if p == 1 then
    PHI = Phi;
    term = inv(In - Phi);
    f = term*Omega*term;
 
    if ktype == 1;
      H = [];
      for j = 1:128				// Truncate infinite sum
        H = H + Phi^j*Omega*(Phi')^j;
      end
      H = term^2*Phi*H;
      fq = H + H';
    else
      fq = Phi*Omega + Phi^2*Omega + Phi^2*Omega*Phi';
      fq = fq + fq' - 6*Phi*Omega*Phi';
      fq = term^3*fq*(term')^3;
    end
 
    uout = [zeros(1,north); varout('resid')];		// Initial values
    msg = '\n VAR(1) ';
 
  else
 
    SPhi = zeros(nvar,nvar);
    SjPhi = zeros(nvar,nvar);
    Sj2Phi = zeros(nvar,nvar);
    for j  = 1:p
      SPhi =  SPhi+Phi(:,(j-1)*nvar+1:j*nvar);
      SjPhi = SjPhi+j*Phi(:,(j-1)*nvar+1:j*nvar);
      Sj2Phi = Sj2Phi+(j^2)*Phi(:,(j-1)*nvar+1:j*nvar);
    end
    PHI = SPhi;
    term = inv(In-SPhi);
    f = term*Omega*term;
 
    P1 = term*SjPhi*term;
    M1 =-2*P1*Omega*P1';
    M2 =[2*P1*SjPhi*term+term*Sj2Phi*term]*Omega*term;
    fq = M1+M2+M2';
 
    uout = [zeros(p,north); varout('resid')];		// Initial values
    msg = '\n VAR('+string(p)+')';
  end
 
  f = f/(2*%pi);
  fq = fq/(2*%pi);
  K = commutation(north,north);
  w = diag(ones(nvar,1)./sqrt(diag(Omega)));			// Calc weighting matrix
  W = diag(vec(w*w'));
 
  alpha = 2*vec(fq)'*W*vec(fq);
  alpha = alpha/trace(W*(eye(north^2,north^2)+K)*(f.*.f));
 
else
 
  // ARMA(1,1), AR(1), or MA(q) for WHITENING
  THETA = zeros(north,north);
  PHI = zeros(north,north);
  w = 1 ./st_dev(u,1)';				// Wt to standardize
 
  for i = 1:north
    if p > 0 then
      pp = repmat(0,p,1);
    else
      pp = [];
    end
 
    if q > 0 then
      qq = repmat(0,q,1);
    else
      qq = [];
    end
 
    tempout = varma(u(:,i),pp,[],qq,[],0,1,'exo=''cte''','Gexo=0','noprint');		// Estimate the ARMA model
 
    if p == 0					// then package estimates
      phi(i,1) = 0;
    elseif p == 1
      phi(i,1) = tempout('AR');
    end
    if q == 0
      theta(i,1) = 0;
    else
      theta(i,:) = tempout('MA');
    end
    sigma(i,1) = sqrt(tempout('V'));
    uout(:,i) = tempout('resid');
    uout(1:max(p,q),i) = 0;			// Set initial cond to 0
    PHI(i,i) = sum(phi(i,:)');
    THETA(i,i) = sum(theta(i,:)');
 
    // ARMA(1,1) or AR(1) case
    if p == 1
      num(i,1) = 4*(1+phi(i)*theta(i))^2*(phi(i)+theta(i))^2;
      if ktype == 1
        term = (1-phi(i)^6)*(1+phi(i)^2);
      else
        term = (1-phi(i))^8;
      end
      num(i,1) = num(i)/term;
      den(i,1) = (1+theta(i))^4/(1-phi(i))^4;
      if q == 0
        msg = ['\n AR('+string(p)+') '];
      else
        msg = ['\n ARMA('+string(p)+','+string(q)+')'];
      end
    // MA(q) case
    else
      tempnum = 0;
      tempden = 0;
      for j = 1:q
        temp = theta(i,j) + theta(i,1:q-j)*theta(i,1+j:q)';
        tempnum = tempnum + temp*j^ktype;
        tempden = tempden + temp;
      end
      num(i,1) = (2*tempnum)^2;
      den(i,1) = (2*tempden + 1 + theta(i,:)*theta(i,:)')^2;
      msg = ['\n MA('+string(q)+') '];
    end
    num(i,1) = w(i)*sigma(i)^4*num(i,1);
    den(i,1) = w(i)*sigma(i)^4*den(i,1);
  end
  alpha = sum(num)/sum(den);
end
 
band = const*(alpha*nobs)^(1/(2*ktype+1));
 
// Adjust eigenvalues of PHI to avoid near-singularity
[B,lambda] = spec(PHI*PHI');
[C,lambda] = spec(PHI'*PHI);
Delta = diag(B'*PHI*C);
 
if max(abs(Delta)) >.97
  write(%io(2),'Modified large eigenvalues in Andrews-Monahan','(a)');
 
  Delta = min(Delta,.97);
  Delta = max(Delta,-.97);
  Delta = diag(Delta);
//  PHI = B*Delta*C';
end
 
// The matrix D for 'recoloring'
D = inv(In - PHI)*(In + THETA);
 
 
//  Andrews case, no pre-whitening
if aminfo('nowhite') == 1
  D = eye(size(D,1),size(D,2));
  uout = u;
  msg = [msg 'bandwidth selection in Andrews HAC\n'];
else
  msg = [msg 'Prewhitening in Andrews-Monahan HAC\n'];
end
 
// --- Print some Info ---------------------------------------------------
mprintf(msg);
mprintf(' %s Kernel, Automatic bandwidth = %5.3f\n',kname,band);
 
rnames = [];
for rn = 1:north
  execstr('rnames=[rnames;''M '+string(rn)+''']');
end
//rnames = [repmat(' M',north,1) string([1:north]')];
if gmmopt('prt') then
  if vardum == 1	then				// VAR case
      m2p = [rnames,string(PHI)];
      printmat(m2p,out);
  else		 // AR/ARMA models
    cnames = rnames;
    if q > 0 then
      pout = theta
      rnames = [];
      for rn = 1:q
        execstr('rnames=[rnames;''Theta '+string(rn)+''']');
      end
    else
      pout = [];
      rnames = [];
    end
    if p == 1 then
      pout = [phi pout];
      rnames = ['Phi 1',rnames];
    end
    rnames = ['',rnames];
    m2p=[cnames,string(pout)];
    m2p=[rnames;m2p];
    write(out,'');
    printmat(m2p,out);
    write(out,'');
    write(out,'');
  end
end
 
//  Diagnostics
if diagdum == 1 then
  lags = 24;				// # autocorr to plot
  write(out,'');
  write(out,'');
  uterm = input(['Enter index for residual of interest (1:'+string(north)+'), other exits ']);
 
  while (uterm > 0 & uterm < size(u,2))
    tittext = ['Sample Partial Autocorr: u'+string(uterm)];
    pacf(u(:,uterm),'m=lags');		// Sample partial autocorr for u
    xtitle([tittext ' Before Whitening']);
    write(%io(2),'Strike a key for the next graph','(a)');
    halt();
    pacf(uout(:,uterm),'m=lags');		// same for uout
    xtitle([tittext ' After Whitening']);
    write(%io(2),'Strike a key to continue','(a)');
    halt();
    uterm = input(['Enter index for residual of interest (1:'+string(north)+'), other exits ']);
  end
end
 
endfunction
