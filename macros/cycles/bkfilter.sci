function [fX,AA]=bkfilter(grocer_namey,pl,pu,nfix,typ)
 
// PURPOSE: computes Baxter-King filter
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * pl  - minimum period of oscillation of desired component
// * pu  - maximum period of oscillation of desired component
//   (2<=pl<pu<infinity).
// * nfix = length of the fixed filter (if typ = 'sym')
//        or: dropped observations at the beginning and end of
//            resulting variable
// * typ = 'fixed' for a fixed length filter (default)
//         or 'vari' for a variable length filter
// ------------------------------------------------------------
// OUPTUT:
// * fX = (nX1) vector containing filtered data
// * AA = filtering matrix
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
// adapted and extended from Terry Fitzgerald
//   tj.fitzgerald@clev.frb.org
 
[nargout,nargin]=argn(0)
if nargin == 4 then
   typ='sym'
end
b = 2*%pi/pl;
a = 2*%pi/pu;
 
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
[y,namey,prests,boundsvarb]=explone(grocer_namey)
 
if prests & exists('grocer_boundsvar') then
   if size(grocer_boundsvar,1) > 2 then
      error('bounds are discontinous in cffilter')
   end
end
 
[T,nvars] = size(y);
 
if T<5 then
   warning('# of observations in BKfilter < 5');
end
 
if pu<=pl then
  error('pu must be larger than pl');
end
 
if pl<2 then
  warning('in Bkfilter, pl less than 2 , reset to 2');
  pl = 2;
end
 
if (nfix>=T/2) then
  error('fixed lag length must be < T/2');
end
 
j = 1:2*T;
B = [(b-a)/%pi,(sin(j*b)-sin(j*a)) ./ (j*%pi)]';
 
AA = zeros(T,T);
 
select typ
case 'fixed' then
   bb = zeros(2*nfix+1,1);
   bb(nfix+1:2*nfix+1) = B(1:nfix+1)
   bb(nfix:-1:1) = B(2:nfix+1)
   bb = bb-sum(bb) ./ (2*nfix+1);
 
   for i = nfix+1:T-nfix
      AA(i,i-nfix:i+nfix) = bb';
   end
 
case 'vari' then
   for i=nfix+1:T-nfix
      j=min(i-1,T-i)
      bb=zeros(2*j+1,1)
      bb(j+1:2*j+1) = B(1:j+1)
      bb(j:-1:1) = B(2:j+1)
      bb = bb-sum(bb) ./ (2*j+1);
      AA(i,i-j:i+j) = bb'
   end
 
else
   error('not an avalaible option for arg 2 in bkfilter')
end
 
//
//======================================================================
//
// compute filtered time series using selected filter matrix AA
//
 
fX = AA*y;
fX=fX(nfix+1:$-nfix)
 
if prests then
   fX=lagts(nfix,reshape(fX,boundsvarb(1)))
end
endfunction
