function [S,eflag,gmmopt] = gmmS(b,gmmopt,Y,X,Z)
 
// PURPOSE: Calculates the spectral density matrix S in GMM
//--------------------------------------------------------------------
// INPUTS:
// . b = parameter values
// . gmmopt  options tlist from GMM
//   - gmmopt('W') = set to 'S' to use gmmS for inverse spectral density
//		      as GMM weighting matrix
//   - gmmopt('W0') =  initial weighting matrix:
//      * 'Z'  =	inv(I kron Z'Z) DEFAULT
//      * 'I'  =	identity
//      * 'C'  =	calculated from parms in b
//      * 'U'  = user-defined (pass to gmm as Win)
//   - gmmopt('S')  Type of spectral density matrix:
//		    * 'I' =	identity
//		    * 'P' =	plain (like OLS,  e'e.*.Z'Z)
//		    * 'W' =	White (hetero-consistent)
//		    * 'H' =	Hansen (truncated, wts = 1 or 0)
//		    * 'NW' =	Newey-West (Bartlett weights)
//		    * 'G' =	Gallant (Parzen weights)
//		    * 'AM' =	Andews or Andrews-Monahan (see gmmAndMon.sci)
//   - gmmopt('lags') = lags in H, NW, or G kernels
//   - gmmopt('wtvec')=  user-defined weights for Hansen matrix
//		        allows for seasonals, etc (eg. wtvec = [1 0 1])
//   - gmmopt('Strim') = ccntrols demeaning of moments in calculating S
//		    * 0	= none
//		    * 1	= demean model errors e (default)
//		    * 2	= demean moments, Z'e
// . Y = "endogenous" data
// . X = "exogenous" variable
// . Z = instruments
//--------------------------------------------------------------------
// OUTPUTS:
// . S =  the spectral density matrix of the GMM moments
// . eflag = 1 if matrix is neg. definite
// . gmmopt = gmm option tlist
//--------------------------------------------------------------------
// REMARKS:
//    gmmopt('Seval')  Lets momt know it is eval S   (used for special
//              application where added a penalty in momt to impose bound,
//              don't want penalty in calc of S)
//--------------------------------------------------------------------
// VERSION: 1.1.7 (2/13/03)
// written by:
// Mike Cliff,  Purdue Finance  mcliff@mgmt.purdue.edu
// CREATED:  12/10/98 (1.1.1 converted from gmmW)
// UPDATED:  11/19/99 (1.1.2 inv(Z'Z); Seval)
//           5/11/00  (1.1.3 Seval)
//           8/8/00   (1.1.4 error checking for User-defined W)
//           9/23/00  (1.1.5 gmmopt.W and fcnchk)
//           7/11/02  (1.1.6) Added Plain option
//           2/13/03  (1.1.7) Fixed if-stmt for plotting
// E. Michaux (2006) for the scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
 
gmmopt('Seval') = 1;  // Let momt know it is calc S
eflag = 0;
fmomt = gmmopt('momt');
fjake = gmmopt('jake');
 
execstr('test='+fmomt);
nout = size(getfield(2,macrovar(test)),"*");
if nout == 1
  error(['Function ' gmmopt('momt') ' requires two outputs.']);
end
 
// use of execstr because we want to use the second output argument of fmomt
execstr('[m,e] = '+fmomt+'(b,gmmopt,Y,X,Z)');
if fjake ~= 'numz0' then
  execstr('M='+fjake+'(b,gmmopt,Y,X,Z)');
else
  nb = max(size(b));
  deff('fm = momt(b,fmomt,gmmopt,Y,X,Z)','fm=evstr(fmomt+''(b,gmmopt,Y,X,Z)'')');
  M = numz0(momt,b,nb,zeros(nb,north),sqrt(%eps),fmomt,gmmopt,Y,X,Z);
  M=M'
end
 
// Get info on size of problem
nobs = size(e,1);
nz = size(Z,2);
north = size(m,1);
neq = north/nz;
Stype = gmmopt('S');
gmmopt('Seval') = 0;
 
// Give only Identity if specified
if (Stype =='I') then
  S = eye(north,north);
  return
end
 
// Determine number of lags to use
if or(Stype==['W';'P']) then
    maxlags = 0;
    amdum = 0;
    bandw = 1;
elseif or(Stype==['NW';'H';'G']) then
    maxlags = gmmopt('lags');
    amdum = 0;
    bandw = maxlags+1;
elseif Stype == 'AM' then
    maxlags = nobs-1;
    amdum = 1;
 
	allf=getfield(1,gmmopt('aminfo'));
	tf=or(allf=='kernel');
	if ~tf then
		Stype = 'QS';
	else
		Stype=gmmopt('aminfo')('kernel');
	end
elseif or(Stype ==['QS';'TH']) then
    error('Set gmmopt(''S'') =''AM'' and gmmopt(''aminfo'')(''kernel'')=''QS'' or ''TH''');
else
    error('Incorrect spectral matrix choice.  Check gmmopt(''S'')');
end
 
// For Truncated Kernel with User-defined Wts
allf=getfield(1,gmmopt);
tf=or(allf=='wtvec');
if ((Stype == 'H') & tf) then
  wtvec = [1; gmmopt('wtvec')];			// Wt of 1 on lag 0
  maxlags =size(wtvec,1)-1;
end
 
 
// calulate initial weighting matrix
if gmmopt('i') == 1 then
  if gmmopt('W0') =='I' then
    S = eye(north,north);			// Identity 			
    return
  elseif gmmopt('W0')=='Z' then		// Instruments
    S = eye(neq,neq).*.(Z'*Z);
    return
  elseif gmmopt('W0')=='C' then 		// Calculate from Starting Values
    S=zeros(north,north);
  elseif gmmopt('W0')=='U' then
    error('gmmS: Shouldn''t be here to evaluate W0.');
  end
else
  S=zeros(north,north);			// 2nd or more GMM iter
end
 
if gmmopt('north') ~= north then
  error('Mismatch of matrix dimensions');
end
 
if gmmopt('Strim') == 1 then
  e = e - repmat(mean0(e,1),nobs,1);	// Remove sample mean
end
 
 
// ANDREWS-MONAHAN PROCEDURE
if amdum == 1 then
  [bandw,u,D,amerr] = gmmAndMon(gmmopt,e,M,Z);
  if amerr == 1 then
    write(out,'');
    write(out,'Trouble with ARMA, switching to AR(1)');
    gmmopt('aminfo')('p')=1;
    gmmopt('aminfo')('q')=0;
    gmmopt('aminfo')('vardum')=0;
    [bandw,u,D,amerr] = gmmAndMon(gmmopt,e,M,Z);
    //write(%io(2),'ANDMON Error','(a)')
  end
  maxlags = nobs-1;
else
  u = [];
  for i = 1:size(e,2)
    u = [u repmat(e(:,i),1,nz).*Z];
  end
end
 
if gmmopt('Strim') == 2 then
  u = u - repmat(mean0(u,1),nobs,1);	// Remove sample mean
end
 
// Build S   Follows Greene (1997, p.528)
for l = 0:maxlags
  Rho = u(1:nobs-l,:)'*u(1+l:nobs,:);	// Vectorized (fast!!)
 
//  Rho = zeros(north,north);			// Loop (~25 x slower)
//  for i = lag+1:nobs				// Old way
//    e1 = e(i,:);  e2 = e(i-lag,:);
//    Z1 = Z(i,:);  Z2 = Z(i-lag,:);
//    Rho  = Rho + kron(e1'*e2,Z1'*Z2);
//  end
 
  Rho = Rho/nobs;
  if l >= 1 then
    Rho = Rho + Rho';
  end
 
 
  x = l/bandw;
//  switch Stype
  if Stype=='P' then		// Plain Standard Errors
    wt = 1;
    Rho = (e'*e/nobs).*.(Z'*Z/nobs);
  elseif or(Stype==['I','W','H']) then 	// Identity, White, or Hansen
    plotname = 'Truncated';
    if tf then // tf is compute in row 109
      wt = wtvec(l+1);
    else
      wt = 1;
    end
  elseif Stype== 'NW' then 		//  Newey West (Bartlett)
    plotname = 'Bartlett (Newey-West)';
    wt = 1 - x;
    if x > 1 then
      wt = 0
    end
  elseif Stype =='G' tehn 		// Gallant (Parzen)
    plotname = 'Parzen (Gallant)';
    if x < 0.5
      wt = 1 - 6*x^2 + 6*x^3;
    elseif x < 1
      wt = 2*(1-x)^3;
    else
      wt = 0;
    end
  elseif Stype=='QS' then		// Quadratic Spectral
    plotname = 'Quadratic-Spectral';
    term = 6*%pi*x/5;
    if l == 0
      wt = 1;
    else
      wt = 25*(sin(term)/term - cos(term))/(12*%pi^2*x^2);
    end
  elseif Stype=='TH'		// Tukey-Hanning
    plotname = 'Tukey-Hanning';
    if x < 1
      wt = (1+cos(%pi*x))/2;
    else
      wt = 0;
    end
  end
  wt = wt*nobs/(nobs-size(b,1));			// Degrees of freedom adj
  S = S + wt*Rho;
  wtout(l+1,1) = wt;
end
 
 
 
// Recolor S if Using Andrews-Monahan Procedure
if amdum == 1 then
  S = D*S*D';
  gmmopt('lags') = bandw;			// Send bandwidth for printing
end
 
version=getversion()
if and(version ~= ['scilab-3.0' ; 'scilab-3.1' ; 'scilab-3.1.1']) then
   execstr('try;mineig = min(spec(S));catch;mineig = %eps;end')
// the developped syntax is the following, but it is not used
// because it generates an error in Scilab 3.x
// try 					// Safeguard against errors
//  mineig = min(spec(S));
// catch					// If problem with eig(S)
//  mineig = %eps;
// end
else
  mineig = min(spec(S));
end
 
if mineig < max(size(S))*norm(S)*%eps	then // If S no P.D. give info
  mprintf('Spectral density matrix not pos. def. min[eigen(S)] = %10.8f \n', mineig);
  write(out,'');
end
endfunction
