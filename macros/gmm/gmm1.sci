function gmmout=gmm1(Y,b,gmmopt,X,Z,Win)
 
// PURPOSE: Estimate model parameters using GMM
//--------------------------------------------------------------------------
// INPUTS:
// . Y = "dependent" variables
// . b = vector of starting values for parameters
// . gmmopt a tlist wich argument can be [default]:
//    - gmmopt('momt') = filename of moment conditions REQUIRED
//    - gmmopt('jake') = filename of Jacobian of moment cond ['numz0']
//    - gmmopt('namep') = a vector containing the name of the parameters (optional)
//    - gmmopt('gmmit') = number of GMM iterations [2]
//    - gmmopt('maxit') = cap on number of GMM iterations		[25]
//    - gmmopt('tol') = convergence criteria for iterated GMM		[sqrt(%eps)]
//    - gmmopt('W0') = Initial GMM weighting matrix			['Z']
//        'I' = identity
//        'Z' = instruments (Z'Z)
//        'C' = calculate from b
//        'Win' = fixed passed as Win
//		  'myfile' = user's own sci-file
//    - gmmopt('W') =  subsequent GMM weighting matrix ['S']
//        'S' = inverse spectral density from gmmS
//    - gmmopt('S') =  tytpe of spectral density matrix		['NW']
//        'W'=White, 'NW'=Newey-West (Bartlett), 'G'=Gallant (Parzen)
//        'H'=Hansen (Truncated), 'AM'=Andrews-Monahan, 'P'=Plain (OLS)
//        'myfile' = user's sci-file
//    - gmmopt('aminfo') = tlist if gmmopt('S')='AM' (see gmmAndMom.sci)
//    - gmmopt('lags') = lags used in truncated kernel for S	        [nobs^(1/3)]
//    - gmmopt('wtvec') = user-defined weights for Hansen matrix
//              allows for seasonals, etc (eg. wtvec = [1 0 1])
//    - gmmopt('Strim') = Contols demeaning of moments in calc of S	[1]
//         0 = none, 1 = demean e, 2 = demean Z'e
//    - gmmopt('Slast') = 1 to recalc S at final param est. 2 updates W	[1]
//    - gmmopt('null') = vector of null hypotheses for t-stats		[0]
//    - gmmopt('plt) = 1 if the user want to graph the weight of GMM matrix		[0]
//    - gmmopt('prt') = 1 if the user want to print the optimization steps [0]
// . X = "independent" variables
// . Z = Instruments (can be same as X)
// . Win = user-defined initial weighting matrix (optional)
//    To use a function to calculate W0, don't use Win, but set
//    gmmopt('W0') to gmmopt('W0') and give the sci-file name in gmmopt('W')
//--------------------------------------------------------------------------
// OUTPUT: gmmout results tlist wich arguments can be
// . gmmout('meth') = 'GMM'
// . gmmout('y') = y data vector
// . gmmout('x') = x data matrix
// . gmmout('z') = instruments data matrix
// . gmmout('f') = function value
// . gmmout('nobs') = number of observations
// . gmmout('varn') = number of parameters to estimate
// . gmmout('north') = number of orthogonality conditions
// . gmmout('neq') =  number of equations
// . gmmout('nz') =  number of instruments
// . gmmout('J') = chi-square stat for model fit
// . gmmout('pvalue fit') = p-value for model fit
// . gmmout('beta') = coefficient estimates
// . gmmout('se') = standard errors of parameters
// . gmmout('vcovar') = cov matrix of parameter estimates
// . gmmout('tstat') = t-stats for parms = null
// . gmmout('pvalue') = p-values for coefficients
// . gmmout('m') = value moments
// . gmmout('M') = value of jacobian of moments conditions
// . gmmout('mse') =  standard errors of moments
// . gmmout('varm') = covariance matrix of moments
// . gmmout('m tstat') = t-stats for moments = 0
// . gmmout('m pvalue') = p-vals for moments
// . gmmout('nz') =  number of instruments
// . gmmout('nvar') =  number of parameters
// . gmmout('df') = degrees of freedom for model
// . gmmout('null') = vector of null hypotheses for parameter values
// . gmmout('W0 type') = type of initial weighting matrix
// . gmmout('W type') = type of weighting matrix
// . gmmout('W') = weighting matrix
// . gmmout('S type') = type of spectral density matrix
// . gmmout('S') = spectral density matrix
// . gmmout('eflag') = error flag for spectral density matrix
//--------------------------------------------------------------------------
// VERSION: 1.3.5 (12/27/04)
// written by:
// Mike Cliff,  Purdue Finance  mcliff@mgmt.purdue.edu
// CREATED:   12/10/98
// MODIFIED:  11/14/99 (1.2.x modified calc of f with user's W; pass M)
//            7/21/00  (1.2.1 |dof| in iterated GMM, NW lags if error, GN dflt)
//            8/8/00   (1.2.2 iter after using user's W0; print momt wts)
//            9/23/00  (1.3.x Win can be fixed matrix or m-file)
//            11/30/00 (1.3.1) improved usage of sub-optimal W
//            5/11/01  (1.3.2) Fixed Wuse to properly do suboptimal W
//            7/11/02  (1.3.3) Added Plain S, mod user's own S
//            4/3/03  (1.3.4) Don't call print functions unless needed
//            12/27/04  (1.3.5) Set MINZ default printing to match GMM
// Translated to scilab and arranged by E. Michaux (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
out=%io(2)
[nargout,nargin]=argn(0);
 
if typeof(gmmopt) ~= "gmm" then // PEUt ETRE AMELIORE ???
  error('GMM options should be in a tlist variable');
end;
 
nobs = size(Y,1);
nz = size(Z,2);
k = size(b,1);
popt=3;
 
// File references and Optimization Options
allf=getfield(1,gmmopt)
tf=or(allf=='momt')
if ~tf then
  error('There is no moment conditions')
else
  execstr('momt='+gmmopt('momt'));
  m = momt(b,gmmopt,Y,X,Z);
  north = size(m,1);
  if north < k
    error(mprintf('Model is not identified: %i moments, %i parms',north,k));
  end
end
 
tf=or(allf=='jake')
if ~tf then
  gmmopt(1)($+1) = 'jake';
  gmmopt('jake') = 'numz0';
end
 
tf=or(allf=='prt')
if ~tf then
  gmmopt(1)($+1) = 'prt';
  gmmopt('prt') = 0;
  popt=0
end
 
gmmopt(1)($+1) = 'Seval';
gmmopt(1)($+1) =  'func';
gmmopt('func') = 'gmmLsFunc';	
gmmopt(1)($+1) = 'grad';
gmmopt('grad')= 'gmmLsGrad';
 
// file the tlist
tf=or(allf=='gmmit');
if ~tf then
  gmmopt(1)($+1) = 'gmmit';
  gmmopt('gmmit') = 1;
end
 
tf=or(allf=='lags');
if ~tf then
  gmmopt(1)($+1) = 'lags';
  gmmopt('lags') =floor(nobs^(1/3));
end
 
tf=or(allf=='null');
if ~tf then
  gmmopt(1)($+1) = 'null';
  gmmopt('null') =zeros(k,1);
end
 
 
tf=or(allf=='W')
if ~tf then
  gmmopt(1)($+1)='W';
  gmmopt('W')='S';
end
 
tf=or(allf=='Slast');
if ~tf then
  gmmopt(1)($+1)='Slast';
  gmmopt('Slast')=1;
end
 
tf=or(allf=='W0')
if ~tf then
  gmmopt(1)($+1)='W0'
  gmmopt('W0')='Z'
end
 
tf=or(allf=='S');
if ~tf then
  gmmopt(1)($+1)='S';
  gmmopt('S')='NW';
end
 
tf=or(allf=='Strim');
if ~tf then
  gmmopt(1)($+1)='Strim';
  gmmopt('Strim')=1;
end
 
// Andrew-Monahan options
if gmmopt('S') == 'AM' then
  tf=or(allf=='aminfo');
  if ~tf then
    gmmopt(1)($+1) ='aminfo';
    gmmopt('aminfo')=tlist(['AM';'kernel';'p';'q';'vardum';'nowhite','diagdum'],'QS',1,1,0,1,0);
  end
 
  // Fill in Andrew-Monahan tlist options when necessary
  allg=getfield(1,gmmopt('aminfo'));
  tg=or(allg=='kernel');
  if ~tg then
    gmmopt('aminfo')(1)($+1)='kernel';
    gmmopt('aminfo')('kernel')='QS';
  end
 
  tg=or(allg=='p');
  if ~tg then
    gmmopt('aminfo')(1)($+1)='p';
    gmmopt('aminfo')('p')=1;
  end
 
  tg=or(allg=='q');
  if ~tg then
    gmmopt('aminfo')(1)($+1)='q';
    gmmopt('aminfo')('q')=1;
  end
 
  tg=or(allg=='vardum');
  if ~tg then
    gmmopt('aminfo')(1)($+1)='vardum';
    gmmopt('aminfo')('vardum')=0;
  end
 
  tg=or(allg=='nowhite');
  if ~tg then
    gmmopt('aminfo')(1)($+1)='nowhite';
    gmmopt('aminfo')('nowhite')=0;
  end
 
  tg=or(allg=='diagdum');
  if ~tg then
    gmmopt('aminfo')(1)($+1)='diagdum';
    gmmopt('aminfo')('diagdum')=0;
  end
end
 
if gmmopt('W0') =='Win';  // Mod 8/8/00 to allow iter after initial user's W
  if nargin ~= 6
    error('You specified a fixed W but didn''t pass one');
  end
end
 
tf=or(allf=='tol');
if ~tf then
  gmmopt(1)($+1)='tol';
  gmmopt('tol') = sqrt(%eps);
end
 
tf=or(allf=='plt');
if ~tf then
  gmmopt(1)($+1)='plt';
  gmmopt('plt')=0;
end
 
tf = or(allf=='namep');
if ~tf then
  gmmopt(1)($+1) = 'namep';
  rnames = [];
  for rn = 1:k
    execstr('rnames = [rnames;''var '+string(rn)+''']');
  end
  gmmopt('namep') = rnames;
end
 
gmmopt(1)($+1)='i';
gmmopt(1)($+1)='north';
gmmopt('north') = north;
 
// tlist of results
gmmout = tlist(['results';'meth';'namep';'y';'x';'z';'f';'J';'pvalue fit';'beta';'se';'vcovar';...
'tstat';'pvalue';'m';'M';'mse';'varm';'m tstat';'m pvalue';'nobs';'north';'neq';...
'nz';'nvar';'df';'stat';'null';'W0 type';'W';'W type';'S';'S type';'lags';'eflag';'gmmit';'jake';'momt']);
gmmout('eflag') = 0;		// Set to zero for error checking
gmmout('W type') = gmmopt('W');
gmmout('W0 type') = gmmopt('W0');
gmmout('S type') = gmmopt('S');
;gmmout('lags') = gmmopt('lags');
 
 
// add Andrew-Monahan tlist option if selected
if gmmopt('S') == 'AM' then
  gmmout(1)($+1)='aminfo';
  gmmout('aminfo') = gmmopt('aminfo') ;
end
 
 
// function to be optimized, gradiants, jacoabian and moments
fgmm = gmmopt('func');
ggmm= gmmopt('grad');
fjake = gmmopt('jake');
fmomt = gmmopt('momt');
 
// function call into string format
fgmms=fgmm+'(b,gmmopt,Y,X,Z,W)';
ggmms=ggmm+'(b,gmmopt,Y,X,Z,W)';
 
//  Get Ready for Loop
if isnan(gmmopt('gmmit'))
  maxiter = gmmopt('maxit');
  loopdum = 1;
else
  maxiter = gmmopt('gmmit');
  loopdum = 0;
end
 
// construct vector of names
cnames = [' '];
for cn = 1:north
  execstr('cnames = [cnames,''Moment '+string(cn)+''']');
end
 
[n1,n2]=size(gmmopt('namep'));
if n1>n2 then
  rnames =gmmopt('namep');
else
  rnames =gmmopt('namep')';
end
 
 
// Do the Loop
i = 1;
of = 1/%eps;			// initialize objective function
tol = gmmopt('tol') // optimization convergence tolerance
Wuse = gmmopt('W0');		// initialize Weighting Matrix choice
while i <= maxiter
  if i == 1 then  // Mod 5/11/01 to fix sub-optimal W
    Wuse = gmmopt('W0');
  else
    Wuse = gmmopt('W');
  end
  gmmopt('i') = i;
 
  if gmmopt('prt')>0 then
    write(out,'   Starting GMM iteration: '+string(i));
  end
 
  // Determine the weighting matrix
  if or(Wuse == ['I','Z','S','C']) then
    if or(gmmopt('S')==['P','W','NW','G','H','AM']) then
      [S,eflag,gmmopt] = gmmS(b,gmmopt,Y,X,Z);
      gmmout('eflag') = max(gmmout('eflag'),eflag);
      if eflag == 1 then
        	gmmopt('S') = 'NW';
	       gmmopt('lags') = min(gmmopt('lags'),floor(nobs^(1/3)));
	       S = gmmS(b,gmmopt,Y,X,Z);
 	       mprintf('Switching to Newey-West  (%d lags)\n',gmmopt('lags'));
         gmmout('S type') ='NW';
         gmmout('lags') =gmmopt('lags');
      end
    else
      execstr('S='+gmmopt('S')+'(b,gmmopt,Y,X,Z)');
    end
    W = inv(S);
  else
 
    //  Next little bit is new for suboptimal W
    if Wuse =='Win' then
      W = Win;
    else
      execstr('W='+Wuse+'(b,gmmopt,Y,X,Z)');
    end
  end
 
  if gmmopt('plt') == 1 then
    gmmDiagW(W,i);
  end
 
  //  Print Weights: M'Wm = w'm = 0 (Added 8/8/00)
  if gmmopt('prt')>0 then
    write(out,'  Weights attached to moments');
    write(out,'');
 
    if fjake ~= 'numz0' then
      execstr('M='+fjake+'(b,gmmopt,Y,X,Z)');
    else
      nb = max(size(b));
      deff('fm = momt(b,fmomt,gmmopt,Y,X,Z)','execstr(''fm='+fmomt+'(b,gmmopt,Y,X,Z)'')');
      M = numz0(momt,b,nb,zeros(nb,north),tol,fmomt,gmmopt,Y,X,Z);
      M=M'
    end
 
    wt = M'*W./repmat(sum(M'*W,2),1,north);
    mat2prt = [rnames,string(wt)];
    mat2prt  = [cnames;mat2prt];
    printmat(mat2prt,out);
    printsep(out);
  end
 
  // Do the Minimization
  bold = b;
  deff('[f,g,ind]=cost(b,ind)',['execstr(''f='+fgmms+''')';'execstr(''g='+ggmms+''')']);
  if popt > 0
    write(out,'  optimization step...') ;	
    write(out,'');
  end
 
  [f,b,gradopt] = optim(cost,bold,'qn','ar',10000,10000,tol,tol,imp=popt);
 
  if popt > 0
    write(out,'  ...optimization ended') ;
    write(out,'');
  end
 
  dof = (of-f)/of;
  of = f;
  if (abs(dof) <= gmmopt('tol') & loopdum == 1)
    i = maxiter+1;
  end
 
  // Print Est from this iteration
  if i < maxiter & gmmopt('prt') > 0 then
    mprintf('  Value of the parameters at the end of iteration %2d\n',i);
    mat2prt = [rnames,string(b)];
    printmat(mat2prt,out);
    printsep(out);
  end
 
  i = i + 1;
end
 
 
//= Make std errors
 
// Re-evaluate moments and Jacobian
gmmopt(1)($+1) = 'Seval';
gmmopt('Seval') = 1;                  // Can use in momt cond
 
execstr('m='+fmomt+'(b,gmmopt,Y,X,Z)');
if fjake ~= 'numz0' then
  execstr('M='+fjake+'(b,gmmopt,Y,X,Z)');
else
  nb = max(size(b));
  deff('fm = momt(b,fmomt,gmmopt,Y,X,Z)','execstr(''fm='+fmomt+'(b,gmmopt,Y,X,Z)'')');
  M = numz0(momt,b,nb,zeros(nb,north),tol,fmomt,gmmopt,Y,X,Z);
  M=M'
end
 
// Re-evaluate Spectral Density if Needed
if gmmopt('Slast') >= 1
  gmmopt('i') = i;                        // Want SEs, not initial W
  if or(gmmopt('S')==['P','W','NW','G','H','AM']) then
    S = gmmS(b,gmmopt,Y,X,Z);
  else
    execstr('S='+gmmopt('S')+'(b,gmmopt,Y,X,Z)');
  end
  gmmopt('i') = i - 1;                    // Restore actual iteration #
  if gmmopt('Slast') == 2
    W = inv(S);
  end
end
 
// Calculate Covariance matrices
term = inv(M'*W*M);
bcov = term*(M'*W*S*W*M)*term/nobs;	// Cov(b)
term = (eye(north,north) - M*term*M'*W);
varm = term*S*term'/nobs;		// Cov(m)
 
// The J-stat
if Wuse=='S' then
  gmmout('J') = nobs*f;		// T x Obj Function from min
else
  gmmout('J') = nobs*m'*pinv(nobs*varm)*m;	// Sub-optimal W, Cov(m) singular
end
 
// Assign Results to output tlist
gmmout('y') = Y ;
gmmout('x') = X ;
gmmout('z') = Z ;
gmmout('meth') = 'GMM' ;
gmmout('m') = m;
gmmout('M') = M;
if north > k
  gmmout('mse') = diag(sqrt(varm));
  gmmout('m tstat') = gmmout('m')./gmmout('mse');
  gmmout('m pvalue') = (1-cdfnor("PQ",abs(gmmout('m tstat')),zeros(north,1),ones(north,1)))*2
end
 
gmmout('nobs') = nobs;		
gmmout('north') = north;
gmmout('neq') = north/nz;		
gmmout('nvar') = k;
gmmout('nz') = nz;
gmmout('null') = gmmopt('null');	
gmmout('df') = north - k;
gmmout('beta') = b;
gmmout('vcovar') = bcov;		
gmmout('varm') = varm;
gmmout('se') = sqrt(diag(bcov));	
gmmout('tstat') = (b-gmmopt('null'))./gmmout('se');
gmmout('f') = f ;
if north > k  then
  gmmout('pvalue fit') = 1 - cdfchi("PQ",gmmout('J'),north-k);
else
  gmmout('pvalue fit') = %nan;
end
pvalue = (1-cdfnor("PQ",abs(gmmout('tstat')),zeros(k,1),ones(k,1)))*2;
gmmout('pvalue') = pvalue
gmmout('W') = W;			
gmmout('S') = S;
gmmout('namep') = gmmopt('namep');
gmmout('gmmit')=gmmopt('gmmit');
gmmout('jake')=gmmopt('jake');
gmmout('momt')=gmmopt('momt');
endfunction
 
