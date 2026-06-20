function rspec = spectral(varargin)
 
// PURPOSE: compute the cospectrum, phase spectrum, coherency, dynamic
// correlation and cohesion of N time series
//-----------------------------------------------------------------
// INPUT:
// varargin = arguments which can be:
// . a matrix or a list of time series
// .'trunc=xx' 		: lag window size (the default value is k=round(sqrt(T)))
// .'weight=xx'		: (N x 1) vector of weights (equal weights by default) for cohesion
// .'spec=1'		: plot spectrum
// .'cospe=1'		: plot cospectrum
// .'dcorr=1'		: plot dynamic correlation
// .'phase=1'		: plot phase spectrum
// .'coher=1'		: plot coherency
// .'cohes=1'		: plot cohesion
// .'boot =1'		: performs block-bootstrap estimation of confidence band
// .'B=xx'		: number of draws for bootsrap replication
// .'sb=xx'		: size of blocks for block bootstrap
// .'noprint'		: if the user doesn't want to plot the results	
//-----------------------------------------------------------------
// OUTPUT:
// rspec a tlist result:
// . rspec('cospe')  = matrix of cospectra
// . rspec('cohes')  = matrix of cohesion (if more than one TS)
// . rspec('coher')  = matrix of coherence (if more than one TS)
// . rspec('dcorr')  = matrix of dynamic correlations (if more than one TS)
// . rspec('phase')  = matrix of standardized phase spectrum (if more than one TS)
// . rspec('order')  = order of arrival of variable in cross-products
// . rspec('ucohes') = matrix of upper bound for cohesion
// . rspec('lcohes') = matrix of lower bound for cohesion
// . rspec('ucoher') = matrix of upper bound for coherency
// . rspec('lcoher') = matrix of lower bound for coherency
// . rspec('ucospe') = matrix of upper bound for cospectra
// . rspec('lcospe') = matrix of upper bound for cospectra
// . rspec('udcorr') = matrix of upper bound for dynamic correlations
// . rspec('ldcorr') = matrix of lower bound for dynamic correlations
// . rspec('uphase') = matrix of upper bound for phase spectrum
// . rspec('lphase') = matrix of lower bound for phase spectrum
// . rspec('prests') = a boolean indicating the presence of
//   time series
// . rspec('namex')  = name of the series
// . rspec('x')      = matrix of the values of the series
// . rspec('bounds') = bounds of the calculations if any
//-----------------------------------------------------------------
// REFERENCE:
// C. Croux, M. Forni and L. Reichlin (2001), "A Measure of Comovements for Economic Indicators:
//		Theory and Empirics", The Review of Economics and Statistics, Vol. 83(2), p. 232-241
//-----------------------------------------------------------------
// Copyright E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_prt=%t
grocer_trunc = 0
grocer_phase = 0
grocer_weight = 0
grocer_spec = 0
grocer_dcorr = 0
grocer_coher = 0
grocer_cospe = 0
grocer_cohes = 0
grocer_boot  = 0
grocer_B = 200
grocer_sb = 8
 
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
   grocer_argi=strsubst(varargin(grocer_i),' ','')
      str1=part(grocer_argi,1:1)
      str2=part(grocer_argi,1:2)
      str4=part(grocer_argi,1:4)
      str5=part(grocer_argi,1:5)
      str6=part(grocer_argi,1:6)
      if str6 == 'weight' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif str5 == 'trunc' | str5 == 'dcorr' | str5 == 'phase' | str5 == 'cospe' |...
      						str5 == 'coher' | str5 == 'cohes' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif str4 == 'boot' | str4 == 'spec' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif str2 == 'sb' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif str1 == 'B' then
         execstr('grocer_'+grocer_argi)
         varargin(grocer_i)=null()
      elseif varargin(grocer_i) == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      end
 
   elseif typeof(varargin(grocer_i)) ~= 'constant' &...
      typeof(varargin(grocer_i)) ~= 'ts' then
      error('wrong type for entry number '+string(grocer_i+2))
   end
end
 
// explode the list of the arguments into the corresponding
// variable, their name, and, if necessary updates the bounds
[grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb]= explone(varargin)
 
[nw,kw]=size(grocer_weight)
kx = size(grocer_x,2)
if grocer_weight ~= 0 then
	if nw ~= kx & kw ~= kx then
		error('weight vector has not the same size as the data')
	elseif kw == kx then
		grocer_weight = grocer_weight'
	end
else
	grocer_weight = ones(kx,1)
end
 
 
// default lag window
if grocer_trunc == 0 then
   T = size(grocer_x,1)
   grocer_trunc = round(sqrt(T))
end
 
// performs spectral analysis
if grocer_boot ~= 1
	rspec = spectral0(grocer_x,grocer_trunc,grocer_weight)
else
	rspec = bootspec(grocer_x,grocer_trunc,grocer_weight,grocer_sb,grocer_B)
end
 
// saves the names and the bounds if any
rspec(1)($+1) = 'prests'
rspec(1)($+1) = 'namex'
rspec(1)($+1) = 'x'
 
rspec('prests')=grocer_prests
rspec('namex')= grocer_namexos
rspec('x')= grocer_x
 
if grocer_prests then
   rspec(1)($+1) = 'bounds'
   rspec('bounds')=grocer_boundsvarb
end
 
if grocer_prt then
   pltspectral(rspec,grocer_spec,grocer_cospe,grocer_dcorr,...
	grocer_phase,grocer_coher,grocer_cohes,grocer_boot)
end
 
 
endfunction
