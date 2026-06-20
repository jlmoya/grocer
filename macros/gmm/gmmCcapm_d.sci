function gmmCcapm_d()
 
// PURPOSE: Estimation of a power utility CCAPM model
// Example written by Mike Cliff, Purdue Finance,  mcliff@mgmt.purdue.edu
 
 
global GROCERDIR;
 
lines(0);
 
write(%io(2),'---------------------------------------------------------------------','(a)')
write(%io(2),'GMM Demo:  Application is (nonlinear) Asset Pricing Test','(a)')
write(%io(2),' The economic structure is E[Rm] = 1','(a)')
write(%io(2),'  R is a NxT matrix of returns, N assets, T dates','(a)')
write(%io(2),'  m is the Intertemporal Marginal Rate of Substitution (IMRS)','(a)')
write(%io(2),'  it is a discount rate that makes the price of the asset 1','(a)')
write(%io(2),'  It is T-dimensional vector.','(a)')
write(%io(2),' ','(a)')
write(%io(2),'The model for m is m = b(1)*cg^(-b(2))','(a)')
write(%io(2),'  b(1) is an impatience parameter','(a)')
write(%io(2),'  b(2) is the risk aversion parameter (>0)','(a)')
write(%io(2),'  cg is the consumption growth rate c_t/c_(t-1)','(a)')
write(%io(2),' The returns are real value-weighted market return and T-bill','(a)')
write(%io(2),' For instruments we will use lagged values of R and cg and a constant','(a)')
write(%io(2),'---------------------------------------------------------------------','(a)')
write(%io(2),' ','(a)')
write(%io(2),' ','(a)')
write(%io(2),' ','(a)')
write(%io(2),'Hit a key to continue','(a)')
halt()
 
lines(0);
gmmdata=read(GROCERDIR+'/data/gmmdata.txt',-1,3);// Sample data from Ogaki
rawdata = gmmdata(1:330,:);         // The last few obs are weird
nz = 1;                             // Number of lags used as instruments
T = size(rawdata,1)-nz;
neq = size(rawdata,2)-1;
 
cg = rawdata(1+nz:T+nz,1);
R = rawdata(1+nz:T+nz,2:3);
 
y = ones(T,neq);
X = [cg R];
Z = ones(T,1);
for i = 1:nz
  Z = [Z rawdata(1+nz-i:T+nz-i,1:3)];
end
 
write(%io(2),' ','(a)')
write(%io(2),' ','(a)')
write(%io(2),' We give GMM instructions through the gmmopt tlist:','(a)')
write(%io(2),' We refernce the moment conditions and derivatives','(a)')
write(%io(2),' and specify a Newey-West weighting matrix with 12 lags','(a)')
write(%io(2),' Starting values are b(1)=.98 and b(2) = 4','(a)')
 
gmmopt = tlist(['gmm';'momt';'jake';'prt';'gmmit';'W0';'W';'S';'lags';'namep';'null']);
gmmopt('momt')='gmmCcapmM';			// moment conditions
gmmopt('jake')='gmmCcapmJ';			// Deriv of moment cond.
gmmopt('gmmit') = 2;			// Number of GMM iterations
gmmopt('W0') = 'Z';			// Initial weighting matrix
gmmopt('W')='S';				// Subsequent wtg matrix optimal
gmmopt('S')='NW';				// Select subsequent wtg matrix
gmmopt('lags')=12;				// Lags in weighting matrix
gmmopt('prt')=1;			// Control printing
gmmopt('namep') = ['beta','gamma'];	// variable names
b=[.98;5];				// Starting values
gmmopt('null') = [1;0];			// Null hypothesis
 
write(%io(2),'Hit a key to begin the estimation','(a)')
halt()
 
gout=gmm('y',gmmopt,'exo=''X''','ivar=''Z''','parm0=b');
 
return
 
endfunction
 
