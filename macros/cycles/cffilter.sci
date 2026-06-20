function [fX,AA]=cffilter(grocer_namey,pl,pu,varargin)
 
// PURPOSE: computes Christiano-Fitzgrald filter
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * pl = minimum period of oscillation of desired component
// * pu = maximum period of oscillation of desired component
//   (2<=pl<pu<infinity).
// * varargin = a list of arguments that can be
//  - 'root=0' or 'root=1' whether you want to assume 0 or 1
//     unit root in time series      (default: root = 1);
//  - 'drift=0' or 'drift=1' whether you want to assume no drift
//     or a time trend in time series   (default: drift = 1);
//  - 'filt=asym' or 'filt=sym' or 'filt=flsym' whether you
//    want to use the asymmetric Filter, the symmetric Filter
//     or the Fixed Length Symmetric Filter (default='asym')
//  - 'nfix=xx' where xx is the fixed length (useful only for
//    the symmetric filter, that is filt=flsym)
//     (default: nfix=-1).
//  - 'thet = xx' with xx a (nx1) vector corresponding to the MA
//    representation of x (if root=0) or delta(x) (if root =1)
//    (default: thet=1)
// ------------------------------------------------------------
// OUPTUT:
// * fX = vector (nX1)) containing filtered data
// * AA = filtering vector
// ------------------------------------------------------------
// NOTE:
//  The filtered data (fX) associated with some filters
//  include zeros at the beginning and end of the data set.
//  Thefilter is not available for these points.You should
//  truncate these points from your analysis.  Examples
//  include fixed length filters and filters for user supplied
//  time series with length(thet)>1. The default filter
//  returns all nonzero data.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2003
// http://grocer.toolbox.free.fr/grocer.html
// sligthly adapted from Terry Fitzgerald
//   tj.fitzgerald@clev.frb.org
 
// set default
root = 1;
drift = 1;
filt = 'asym';
thet = 1;
 
// explode namey into the corresponding variable, its name, if
// it's a ts and if necessary the admissible bounds
[y,namey,prests,boundsvarb]=explone(grocer_namey)
 
if prests & exists('grocer_boundsvar') then
   if size(grocer_boundsvar,1) > 2 then
      error('bounds are discontinous in cffilter')
   end
end
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   select typeof(varargin(grocer_i))
   case 'string' then
      varargin(grocer_i)=strsubst(varargin(grocer_i),' ','')
      if part(varargin(grocer_i),[1:5]) == 'root='...
      | part(varargin(grocer_i),[1:6]) == 'drift='...
      | part(varargin(grocer_i),[1:5]) == 'thet='...
      | part(varargin(grocer_i),[1:5]) == 'nfix=' ...
      then
         execstr(varargin(grocer_i))
         varargin(grocer_i)=null()
      elseif part(varargin(grocer_i),[1:5]) == 'filt=' then
         filt=part(varargin(grocer_i),6:length(varargin(grocer_i)))
         varargin(grocer_i)=null()
      end
   else
      disp(varargin(grocer_i))
      error('wrong type for entry # '+string(grocer_i+6))
   end
end
 
if ~exists('nfix','local') & filt == 'flsym' then
   error('when fil=''flsym'', you should enter the parameter nfix')
end
 
th=vec2row(thet)
nq =size(th,1)-1;
b = 2*%pi/pl;
a = 2*%pi/pu;
 
[T,nvars] = size(y);
 
if T<5 then
   warning('# of observations < 5');
end
 
if T<(2*nq+1) then
  error('# of observations must be at least 2*q+1');
end
 
if pu<=pl then
  error('pu must be larger than pl');
end
 
if pl<2 then
  warning('pl less than 2 , reset to 2');
  pl = 2;
end
if (root~=0)&(root~=1) then
  error('root must be 0 or 1');
end
if drift<0|drift>1 then
  error('drift must be 0 or 1');
end
 
//   compute g(thet)
//   [g(1) g(2) .... g(2*nq+1)] correspond to [c(q),c(q-1),...,c(1),
//                                        c(0),c(1),...,c(q-1),c(q)]
//   cc = [c(0),c(1),...,c(q)]
 
thp = th($:-1:1,:);
g = convol(th,thp);
cc = g(nq+1:2*nq+1);
//   compute """"ideal"""" Bs
j = 1:2*T;
B = [(b-a)/%pi,(sin(j*b)-sin(j*a)) ./ (j*%pi)]';
//    compute R using closed form integral solution
R = zeros(T,1);
if nq>0 then
  R0 = B(1)*cc(1)+2*B(2:nq+1)'*cc(2:nq+1);
  R(1) = %pi*R0
  for i = 2:T
    dj = bge(i-2,nq,B,cc);
    R(i) = R(i-1)-dj
  end
else
  R0 = B(1)*cc(1);
  R(1) = %pi*R0
  for j = 2:T
    dj = 2*%pi*B(j-1)*cc(1);
    R(j) = R(j-1)-dj
  end
end
 
//
//======================================================================
//
AA = zeros(T,T);
//
//----------------------------------
//  asymmetric filter
//----------------------------------
//
if filt=='asym' then
  if nq==0 then
    for i = 1:T
      AA(i,i:T) = B(1:T-i+1)';
      if root==1 then
        AA(i,T) = R(T+1-i)/(2*%pi);
      end
    end
    AA(1,1) = AA(T,T);
    //  Use symmetry to construct bottom 'half' of AA
    %v2 = triu(AA,1)
    %v2 = %v2(:,$:-1:1)
    AA = AA+%v2($:-1:1,:);
  else
    // CONSTRUCT THE A MATRIX size T x T
    A = Abuild(T,nq,g,root);
    Ainv = inv(A);
    // CONSTRUCT THE d MATRIX size T x 1
    for np = 0:ceil(T/2-1)
      d = zeros(T,1);
      ii = 0;
      for jj = np-root:-1:np+1+root-T
        ii = ii+1;
        %v4 = bge(jj,nq,B,cc)
        d(ii,1) = %v4(:);
      end
      if root==1 then
        d(T-1) = R(T-np)
      end
      //  COMPUTE Bhat = inv(A)*d
      Bhat = Ainv*d;
      AA(np+1,:) = Bhat';
    end
    //  Use symmetry to construct bottom 'half' of AA
    %v2 = AA(1:floor(T/2),:)
    %v2 = %v2(:,$:-1:1)
    AA(ceil(T/2)+1:T,:) = %v2($:-1:1,:);
  end
end
//
//-------------------------------------
//  symmetric filter
//-------------------------------------
//
if filt=='sym' then
  if nq==0 then
    for i = 2:ceil(T/2)
      np = i-1;
      AA(i,i:i+np) = B(1:1+np)';
      if root==1 then
        AA(i,i+np) = R(np+1)/(2*%pi);
      end
      AA(i,i-1:-1:i-np) = AA(i,i+1:i+np);
    end
    //  Use symmetry to construct bottom 'half' of AA
    %v2 = AA(1:floor(T/2),:)
    %v2 = %v2(:,$:-1:1)
    AA(ceil(T/2)+1:T,:) = %v2($:-1:1,:);
  else
    for np = nq:ceil(T/2-1)
      nf = np;
      nn = 2*np+1;
      // CONSTRUCT THE A MATRIX size nn x nn
      A = Abuild(nn,nq,g,root);
      Ainv = inv(A);
      // CONSTRUCT THE d MATRIX size nn x 1
      d = zeros(nn,1);
      ii = 0;
      for jj = np-root:-1:-nf+root
        ii = ii+1;
        %v4 = bge(jj,nq,B,cc)
        d(ii,1) = %v4(:);
      end
      if root==1 then
        d(nn-1) = R(nf+1)
      end
      //  COMPUTE Bhat = inv(A)*d
      Bhat = Ainv*d;
      AA(np+1,1:2*np+1) = Bhat';
    end
    //  Use symmetry to construct bottom 'half' of AA
    %v2 = AA(1:floor(T/2),:)
    %v2 = %v2(:,$:-1:1)
    AA(ceil(T/2)+1:T,:) = %v2($:-1:1,:);
  end
end
 
//
//----------------------------------
//  fixed length symmetric filter
//----------------------------------
//
if filt=='flsym' then
   if nfix<1 then
      error('fixed lag length must be >= 1');
   end
   if nfix<nq then
      error('fixed lag length must be >= q');
   end
   if nfix>=T/2 then
      error('fixed lag length must be < T/2');
   end
 
   if nq==0 then
      bb = zeros(2*nfix+1,1);
      bb(nfix+1:2*nfix+1) = B(1:nfix+1)
      bb(nfix:-1:1) = B(2:nfix+1)
      if root==1 then
         bb(2*nfix+1) = R(nfix+1)/(2*%pi)
         bb(1) = R(nfix+1)/(2*%pi)
      end
      for i = nfix+1:T-nfix
         AA(i,i-nfix:i+nfix) = bb';
      end
   else
      nn = 2*nfix+1;
      // CONSTRUCT THE A MATRIX size nn x nn
      A = Abuild(nn,nq,g,root);
      Ainv = inv(A);
      // CONSTRUCT THE d MATRIX size nn x 1
      d = zeros(nn,1);
      ii = 0;
      for jj = nfix-root:-1:-nfix+root
         ii = ii+1;
         %v3 = bge(jj,nq,B,cc)
         d(ii,1) = %v3(:);
      end
      if root==1 then
         d(nn-1) = R(nn-nfix)
      end
      //  COMPUTE Bhat = inv(A)*d
      Bhat = Ainv*d;
      for ii = nfix+1:T-nfix
         AA(ii,ii-nfix:ii+nfix) = Bhat';
 
      end
   end
end
 
 
if root == 1 then
   tst = max(abs(sum(AA',1)))
   if (tst>.000000001)&(root~=0) then
      warning(' (bpass): Bhat does not sum to 0 ');
      tst = tst;
   end
end
//
//======================================================================
//
// compute filtered time series using selected filter matrix AA
//
if drift>0 then
  y = undrift(y);
end
fX = AA*y;
 
if prests then
   fX=reshape(fX,boundsvarb(1))
end
endfunction
