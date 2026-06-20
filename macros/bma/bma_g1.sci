function rbma_g = bma_g1(y,x,ndraw,burnin,mcmc,g,nvmax)
 
// PURPOSE: Bayes model averaging estimates of Fernadez, Levy and Steel
//-----------------------------------------------------------------
// INPUT:
//	* y = dependent variable vector (nobs x 1)
//	* x = explanatory variables (nobs x k)
// * ndraw = # of draws to carry out
// * burnin = # of burn-in MCMC simulation
// * mcmc = name of the MCMC algorithm (jump_g or mc3_g)
// * g = value of g-prior (default = 1/max(nobs,k^2))
// * nvmax = max number of variable allowed in each model
//-----------------------------------------------------------------
// OUTPUT:
// a tlist result:
//     rbma_g('meth')  = 'bma g-prior'
//     rbma_g('nmod')  = # of models visited during sampling
//     rbma_g('beta')  = bhat averaged over all models
//     rbma_g('mprob') = posterior prob of each model
//     rbma_g('vprob') = posterior prob of each variable
//     rbma_g('model') = indicator variables for each model (nmod x k)
//     rbma_g('yhat')  = yhat averaged over all models
//     rbma_g('resid') = residuals based on yhat averaged over models
//     rbma_g('sige')  = averaged over all models
//     rbma_g('nobs')  = nobs
//     rbma_g('nvar')  = # of exogenous
//     rbma_g('y')     = y data vector
//     rbma_g('x')     = x data vector
//     rbma_g('visit') = visits to each model during sampling (nmod x 1)
//     rbma_g('time')  = time taken for MCMC sampling
//     rbma_g('ndraw') = # of MCMC sampling draws
//     rbma_g('burnin') = # of burn-in MCMC simulation
//     rbma_g('gprior') = value of g-prior
//-----------------------------------------------------------------
// REFERENCES:
// Fernandez,Carmen, Eduardo Ley, and Mark F. J. Steel, (2001)
// "Model uncertainty in cross-country growth regressions",
// Journal of Applied Econometrics, Volume 16, number 5, pp. 563 - 576.
//
// Fernandez,Carmen, Eduardo Ley, and Mark F. J. Steel, (2001)
// "Benchmark priors for bayesian model averaging",
// Journal of Econometrics, Volume 100, number 2, pp. 381-427.
//
//	Edward I. George and Robert E. McCulloch (1997)
//	"Approaches for Bayesian Variable Selection",
//	Satistica Sinica, n�7, pp. 339-373
//-----------------------------------------------------------------
// Copyright: E. Michaux & E. Dubois (2005)
// http://grocer.toolbox.free.fr/grocer.html
// Translated and improved (less time consuming)
// from James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jlesage@spatial-econometrics.com
 
[nargout,nargin] = argn(0)
 
nobs =size(y,1)
[nx,nvar] =size(x)
if nobs ~= nx then
	error("bma_g : y and x1 need same # of observations")
end
 
if nargin < 7 then
	nvmax = nvar
end
if nargin < 6 then
	g = 1/max(nobs,nvmax^2)
end
if nargin < 4 then
	mcmc  = mc3_g
elseif nargin < 5 then
	burnin = 0 // prelimnary simulation to compute  prob. covered.
end
if nargin < 3 then
   error('must specify the number of MCMC sampling draws')
end
 
// matrix for binary transformation
convert = zeros(nvar,1)
convert = 2 .^ [nvar-1:-1:0]'
 
 
// storage for draws
vsave = zeros(1,nvar)
visits = zeros(1,1)
lposts = zeros(1,1)
vtmp = zeros(nvar,1)
 
// first model
nones = floor(grand(1,1,'unf',1,nvmax))
permu = [ones(nones,1) ; zeros(nvar-nones,1)]
vtmp = grand(1,'prm',permu)
 
keep = (1:nvar)' .* vtmp
vin =  keep(vtmp==1)'
drop = (1:nvar)'-keep
vout = drop(vtmp ==0)'
 
// first model paramters
l0 = bmapost_g(y,x,vin,g)
lposts =l0
lpost_old = l0
vsave(vin) = 1
visits(1) = 1
 
binsave = vsave*convert
 
// <====================== start MCMC sampling
t0 = getdate('s')
write(%io(2),' MCMC sampling, be patient ...','(a)')
 
// <==== burn-in MCMC sampling
if burnin > 0 then
	
	for i = 1:burnin
		
		// number of different models visited
		nbinsave = size(binsave,1)
 
		// choose new model
		[vinew,vonew] = mcmc(vin,vout,nvmax)
		[j,visits] = find_new(binsave,vinew,visits,nvar,convert)
		
		if j== nbinsave+1 then
		// we found a new model
		 	lpost_new = bmapost_g(y,x,vinew,g)
			lposts = [lposts;lpost_new]
 
			conc = zeros(1,nvar)	
			conc(vinew)=1
			conc = conc*convert
	  		
	  		binsave = [binsave;conc]
 		else
			lpost_new = lposts(j)
	  end  // end of if-else visits
	
		bf = exp(lpost_new-lpost_old)
 
		if bf >= 1 then
			vin = vinew
			vout = vonew
	  	 lpost_old = lpost_new
	  else
 	   flag = grand(1,1,'bin',1,bf)
 		 	 if flag ==1 then // change models
				vin = vinew
				vout = vonew
				lpost_old = lpost_new
  			 end
 		end
	end //<==== end of draws
end
 
// new intialization
vsave = zeros(1,nvar)
visits = zeros(1,1)
lposts = zeros(1,1)
lpost_old = zeros(1,1)
		
vsave(vin) = 1
binsave = vsave*convert
visits = 1
 
l0 = bmapost_g(y,x,vin,g)
lposts =l0
lpost_old = l0
 
// <==== after burn-in MCMC sampling
for i = 1:ndraw-burnin
	
	nbinsave = size(binsave,1)
 
	// choose new model
	[vinew,vonew] = mcmc(vin,vout,nvmax)
	[j,visits] = find_new(binsave,vinew,visits,nvar,convert)
 
	if j== nbinsave+1 then
		// we found a new model
		lpost_new = bmapost_g(y,x,vinew,g)
		lposts = [lposts;lpost_new]
		
		conc = zeros(1,nvar)	
		conc(vinew)=1
        conc = conc*convert
 
	  binsave = [binsave;conc]
	
	else
		lpost_new = lposts(j)
	end  // end of if-else visits
	
	bf = exp(lpost_new-lpost_old)
 
	if bf >= 1 then
     vin = vinew
     vout = vonew
     lpost_old = lpost_new
  else
     flag = grand(1,1,'bin',1,bf)
     if flag ==1 then // change models
        vin = vinew
        vout = vonew
        lpost_old = lpost_new
     end   	
  end
 
end //<==== end of draws
t1 = getdate('s')
time = t1-t0
 
// compute posterior probabilities
maxml = max(lposts)
posts = exp(lposts)
 
postprob = posts/sum(posts,1)
[mposto,mposti] = gsort(postprob,'r','d')
visito = visits(mposti,:)
 
// convert numbered models into bits
vsave = bintodec(binsave,nvar)
modelo = vsave(mposti,:)
 
nmodels = size(modelo,1)
vposto = sum(modelo .* (ones(1,nvar) .*. mposto),1)'
 
// compute bhat, sige, yhat averaged  over unique models
bavg = zeros(nvar+1,1)	// bhat
 
bstock = zeros(nmodels,nvar)
for i = 1:nmodels
   vin = []
   cnt = 1
   for j = 1:nvar
      if modelo(i,j) ~=0 then
         vin(1,cnt) = j
         cnt = cnt+1
      end
   end
   // do regression using model explanatory variables
   // and weight by posterior probabilities
   bet = ols0(y,[x(:,vin) ones(nobs,1)])
   cnt = 1
   for k=1:nvar
      if modelo(i,k) ~= 0 then
				bavg(k) = bavg(k) + bet(cnt)*mposto(i)
				bstock(i,k) = bet(cnt)
        cnt = cnt+1
      end
   end
   bavg(nvar+1) = bavg(nvar+1) + bet(cnt)*mposto(i)
	
end
bavg = (1/(1+g))*bavg // beta coef in case of g-prior
 
// now find y-hat weighted by posterior probability for the model
yhat = zeros(nobs,1)
yhat = [x ones(nobs,1)]*bavg
 
// r-squared
resid = y-yhat
sigu = resid'*resid
 
nvar = nvar + 1 // number of variable + constant
 
if nvmax < nobs then
	sige= sigu/(nobs-nvmax-1)
	ser=sqrt(sige)
else
	rbar = %nan
	ser = %nan
end
 
// fill-in results tlist
rbma_g = tlist(['results';'meth';'nmod';'beta';'all beta';'mprob';'vprob';'model';'yhat';'sigu';'ser';...
				'resid';'nobs';'nvar';'y';'x';'visit';'ndraw';'time';'burnin';'gprior';'nvmax'],...
				'bma_g',nmodels,bavg,bstock,mposto,vposto,modelo,yhat,sigu,ser,resid,nobs,...
								nvar,y,x,visito,ndraw,time,burnin,g,nvmax)
						
endfunction
