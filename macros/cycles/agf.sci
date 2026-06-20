function ac = agf(w,AR,MA)
 
// PURPOSE: evaluate autocovariance generating function
// for AR & MA at point w
//----------------------------------------------------------
// INPUT:
// . w   = point where to evaluate
// . AR  = matrix of AR coefficients AR = [A1 .. Ap]
// . MA  = matrix of MA coefficients MA = [B1 .. Bq]
//----------------------------------------------------------
// OUPUT:
// . ac = AGF for VARMA
//----------------------------------------------------------
// E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
// defaults
mac = 1
arc = 1
 
if isempty(MA) then
  mac = 0
  MA = zeros(size(AR,1),size(AR,1))
  the = eye(size(AR,1),size(AR,1))
elseif isempty(AR) then
  arc = 0
  AR = zeros(size(MA,1),size(MA,1))
  phi = eye(size(MA,1),size(MA,1))
end
 
[nvar,nar] = size(AR)
nar = nar/nvar
[test,nma] = size(MA)
nma = nma/nvar
// control for the case where the last MA has a smaller
// dimension than the number of variables
if nma ~= int(nma) then
  res = (int(nma)-nma+1)*nvar
  MA = [MA zeros(test,res)]
  nma = size(MA,2)/nvar
end
if test ~= nvar then
  error('size of AR & MA doesn''t match')
end
 
// compute "AR part" for AGF
if arc then
  phi = zeros(nvar,nvar)
  for l  = 1:nar
    phi =  phi+AR(:,(l-1)*nvar+1:l*nvar)*(w^l)
  end
  phi = eye(nvar,nvar)-phi
end
 
// compute "MA part" for AGF
if mac then
   the = zeros(nvar,nvar)
   for l  = 1:nma
    the = the+MA(:,(l-1)*nvar+1:l*nvar)*(w^l)
   end
end
 
ac = inv(phi)*the
 
 
endfunction
