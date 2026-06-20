function rspec = specvarma(result,varargin)
 
// PURPOSE: estimate parametric spectral density of VARMA
// process
//------------------------------------------------------------
// INPUT:
// . result = a tlist of results of estimation for VAR, VARMA,
//   OLS models
// .'spec=1'	: plot spectrum
// .'cospe=1'	: plot cospectrum
// .'dcorr=1'	: plot dynamic correlation
// .'phase=1'	: plot phase spectrum
// .'coher=1'	: plot coherency
// .'cohes=1'	: plot cohesion
// .'ic =1'	: compute asymptotic confindence band by the delta
//  method
// .'noprint'	: if the user doesn't want to plot the results	
//------------------------------------------------------------
// OUTPUT: rspec a tlist result:
// . rspec('cospe')  = matrix of cospectra
// . rspec('cohes')  = matrix of cohesion (if more than one
//   TS)
// . rspec('coher')  = matrix of coherence (if more than one
//   TS)
// . rspec('dcorr')  = matrix of dynamic correlations (if more
//   than one TS)
// . rspec('phase')  = matrix of standardized phase spectrum
//   (if more than one TS)
// . rspec('order')  = order of arrival of variable in
//   cross-products
// . rspec('ucohes') = matrix of upper bound for cohesion
// . rspec('lcohes') = matrix of lower bound for cohesion
// . rspec('ucoher') = matrix of upper bound for coherency
// . rspec('lcoher') = matrix of lower bound for coherency
// . rspec('ucospe') = matrix of upper bound for cospectra
// . rspec('lcospe') = matrix of upper bound for cospectra
// . rspec('udcorr') = matrix of upper bound for dynamic
//   correlations
// . rspec('ldcorr') = matrix of lower bound for dynamic
//   correlations
// . rspec('uphase') = matrix of upper bound for the phase
//   spectrum
// . rspec('lphase') = matrix of lower bound for the phase
//   spectrum
// . rspec('omega')  = vector of frequencies
// . rspec('order')  = order of arrival of variable in
//   cross-products
// . rspec('AR')     = matrix of AR coefficients AR=[A1 .. Ap]
// . rspec('MA')     = matrix of MA coefficients MA=[B1 .. Bq]
//------------------------------------------------------------
// WARNING: no constant is allowed in the model, center
// data before VAR, VARMA and OLS estimation
// -> spectral density is fourrier transform of autocovariance
// function
//------------------------------------------------------------
// REFERENCE:
// C. Croux, M. Forni and L. Reichlin (2001), "A Measure of
// Comovements for Economic Indicators: Theory and
// Empirics", Review of Economics and Statistics,
// Vol. 83(2), p. 232-241
//------------------------------------------------------------
// Copyright E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_prt = %t
grocer_phase = 0
grocer_weight = 0
grocer_spec = 0
grocer_dcorr = 0
grocer_coher = 0
grocer_cospe = 0
grocer_cohes = 0
grocer_ic = 0
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      argi=strsubst(varargin(grocer_i),' ','')
      str2=part(argi,1:2)
      str4=part(argi,1:4)
      str5=part(argi,1:5)
      str6=part(argi,1:6)
      if argi == 'noprint' then
         grocer_prt = %t
      elseif str6 ~= 'weight' & str5 ~= 'trunc' & str5 ~= 'dcorr' ...
       & str5 ~= 'phase' & str5 ~= 'cospe' & str5 ~= 'coher' ...
       & str5 ~= 'cohes' & str4 ~= 'spec' & str2 ~= 'ic' then
         warning(varargin(grocer_i)+ ' is not a valid option: it has been ignored')
      else
         execstr('grocer_'+varargin(grocer_i))
      end
   else
      warning('wrong type for entry number '+string(grocer_i+2)+': it has been ignored')
   end
end
 
 
// get AR, MA coefficients, strandard error of regression
// and compute global covariance matrix of estimated parameters
// according to the method of estimation (VAR, OLS, VARMA)
if result('meth') == 'var' then
  AR = result('beta')'
  MA = []
  sig = result('sigma')
 
  if grocer_ic then
    nobs = result('nobs')
    neqs = result('neqs')
    vbeta = sig.*.result('xpxi') // vcv of beta
    sig2 = 2*(dnplus(neqs))*(sig.*.sig)*(dnplus(neqs))' // vcv of estimated cov of parameters
    vsig  = (1/nobs)*sig2;
 
    junk = zeros(size(vbeta,1),size(vsig,2))
    vtheta  = [ vbeta junk ; junk' vsig] // global covariance matrix of estimated parameters
  end
 
elseif result('meth') == 'ols' then
    AR = result('beta')'
    MA = []
    sig = result('sige')
 
    if grocer_ic then
       vbeta = result('vcovar') // vcv of beta
       nobs = result('nobs')
       vsig  = (2/nobs)*sig^2 // vcv of estimated cov of parameters
 
       junk = zeros(size(vbeta,1),1)
       vtheta  = [vbeta junk ; junk' vsig] // global covariance matrix of estimated parameters
    end
 
elseif result('meth') == 'varma' then
    AR = -result('AR') // in VARMA function parameters are written in the form (1+AR(L))*Y = e...
    MA = result('MA')
    sig = result('V')
 
    if grocer_ic then
       z = result('z')
       theta = result('coeff')
       theta2mat = result('theta2mat')
      // option to compute variance-covariance matrix of estimated parameters
      [grocer_E4OPTION]=e4init()
      grocer_E4OPTION=sete4opt(grocer_E4OPTION,'vcond','lyap','econd','zero','var','fac');
      grocer_e4_prt=%t
      grocer_e4_delta=sqrt(%eps)
      grocer_e4_type = result('type')
      grocer_e4_y = result('y')
      grocer_e4_m = result('nendo')
      grocer_e4_s = result('seas')
      grocer_e4_r = result('nexo')
      grocer_e4_g = result('lagexo')
      grocer_e4_k = result('k')
      grocer_e4_n = result('k')*result('nendo')
      grocer_e4_np = size(theta,1)
      grocer_e4_T = result('nobs')
      grocer_yscale=min(round(log10(mean0(abs(grocer_e4_y),'r'))))
      grocer_e4_scaleb = grocer_E4OPTION(2);
      grocer_e4_zeps = grocer_E4OPTION(15)*10^(-grocer_yscale)
      grocer_e4_deps = .00000001;
 
      lname = ['AR';'MA';'ARS';'MAS';'V';'G']
      lnamee4 = ['k';'p';'P';'q';'Q';'type';'userflag';'econd';...
                  'vcond';'filtk';'prests']
      for i = 1:size(lname,1)
        execstr('grocer_'+lname(i)+' = result('''+lname(i)+''')')
      end
      for i = 1:size(lnamee4,1)
        execstr('grocer_e4_'+lnamee4(i)+' = result('''+lnamee4(i)+''')')
      end
 
      [junk1,junk2,vtheta,junk3]=imod(theta,theta2mat,z) // global covariance matrix of estimated parameters
 
    end
end
 
if grocer_ic then
  rspec = deltaspec(sig,vtheta,AR,MA)  // compute interval confidence band with delta-method
else
  rspec = specvarma1(sig,AR,MA)
end
 
// saves the names, the bounds if the regression involves ts
rspec(1)($+1) = 'prests'
rspec(1)($+1) = 'namex'
 
rspec('prests')= result('prests')
rspec('namex')= result('namey')
 
if result('prests') then
   rspec(1)($+1) = 'bounds'
   rspec('bounds')= result('bounds')
end
 
// plot results
if grocer_prt then
   pltspectral(rspec,grocer_spec,grocer_cospe,grocer_dcorr,...
						grocer_phase,grocer_coher,grocer_cohes,grocer_ic)
end
 
 
 
endfunction
