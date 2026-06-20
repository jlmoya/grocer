function rspec = spectral0(y,k,w)
 
// PURPOSE: compute coherency, cospectra and dynamic correlation
//-----------------------------------------------------------------
// INPUT:
// . y = (T x N) matrix having variables on the columns
// . k = the lag window size (the default value is k=round(sqrt(T)))
// . w = a (N x 1) vector of weights to compute cohesion (equal weights by default)
//-----------------------------------------------------------------
// OUTPUT:
// rspec a tlist result:
// . rspec('cohes')  = matrix of cohesion
// . rspec('coher')  = matrix of coherency
// . rspec('cospe')  = matrix of cospectra
// . rspec('dcorr')  = matrix of dynamic correlations
// . rspec('phase')  = matrix of phase spectrum
// . rspec('order')  = order of arrival of variable in cross-products
//-----------------------------------------------------------------
// REFERENCE:
// C. Croux, M. Forni and L. Reichlin (2001), "A Measure of Comovements for Economic Indicators:
//		Theory and Empirics", Review of Economics and Statistics, Vol. 83(2), p. 232-241
//-----------------------------------------------------------------
// free adaptation by E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
//	from Forni, Hallin, Lippi and Reichlin.
// http://www.ecares.org
 
[nargout,nargin] = argn(0)
 
// compute T and N
[T,N] = size(y)
 
// defaults
if nargin <=2 then
  w = ones(N,1)
end
if nargin==1 then
  k = round(sqrt(T))
end
 
// compute co-spectra
S = crosspe(y,k)
S = S(1:65,:)
cospectra = real(S)
 
 
if N > 1 then
 
  // extract squared spectra from S
  i = (1:N)'*(N+1)-N
  D = cospectra(:,i)
 
  a = (1:N)'*ones(1,N)
  b = a'
  a = a(:)
  b = b(:)
 
  // dynamic correlation
  dyncorr = cospectra./sqrt(D(:,a) .*D(:,b))
 
  // squared coherency
  coherency = (abs(S./sqrt(D(:,a) .*D(:,b)))).^2
 
  //phase spectrum
  phaspec = atan(-imag(S)./real(S))
 
  // weight cohesions
  W = w*w'
  dyn = dyncorr .*(ones(65,1)*W(:)')
 
  // compute numerators
  dyn = sum(dyn',1)'-sum(dyn(:,i)',1)';
 
  // compute denominator
  Denom = ones(65,1)*W(:)'
  Denom = sum(Denom',1)'-sum((Denom(:,i))',1)'
  cohes = dyn ./ Denom
 
	cospe =[]
	coher =[]
	dcorr =[]
	phase =[]
	// delete cross-products that appear more than once
	for t = 1:size(i,1)-1
		cospe = [cospe cospectra(:,i(t)+1:i(t)+N-t)]
		coher = [coher coherency(:,i(t)+1:i(t)+N-t)]
		dcorr = [dcorr dyncorr(:,i(t)+1:i(t)+N-t)]
		phase = [phase phaspec(:,i(t)+1:i(t)+N-t)]
	end
	cospe = [cospectra(:,i) cospe]
	
	
	// determine order of arrival of cross-products in dcorr, phase...
	// first column contains the number of the first variable
	// second column contains the number of the second variable
	pl2 = (2:N)'	
	npl2 = size(pl2,1)
	pln = [ones(N-1,1) pl2]
	j=1
	for i = N-2:-1:1
		pl1 = [ones(i,1)+j pl2(j+1:npl2)]
		pln = [pln;pl1]
		j=j+1
	end
 
else
	cospe = cospectra
	coher = %nan
	cohes = %nan
	dcorr = %nan
	phase = %nan
	pln   = %nan
end
 
// fill-in results tlist
rspec = tlist(['results';'meth';'coher';'cospe';'dcorr';'phase';'cohes';'order'],...
							'spectral',coher,cospe,dcorr,phase,cohes,pln)
 
	
	
 
endfunction
