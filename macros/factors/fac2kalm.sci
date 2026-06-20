function [Phi,Gam,E,H,D,C,Q,S,R,p0,q0]=fac2kalm(y,ARF,MAF,listar,initown,varargin)
 
// PURPOSE: transform the parameters entered bt the user into
// the standard matrices used by the Kalman filter
// with the Kalman filter
// The model:
// yi_t = sum(lambda_j(i)*F_jt)+ui_t
// ARF_j(L)*F_jt = MAF_j(L)*e_jt
// AR_i(L)*u_it=e_it
// is transformed into:
//    x(t+1) = Phi·x(t) + Gam·u(t) + E·w(t)
//    y(t)   = H·x(t)   + D·u(t)   + C·v(t)
// with E([w(t) ; v(t)]) = [Q S ; S R]
// ------------------------------------------------------------
// INPUT:
// * y= a (nobs x nvar) real matrix of endogenous variables
// * ARF = either a (nar x 1) or (1 x nar) string vector for
//   the AR part
//   (case when there is only one factor)
//         or a list of nf (nar x 1) or (1 x nar) string
//    vectors of AR parts
//   (case when there are nf factors)
// * MAF = either a (nar x 1) or (1 x nar) string vector for
//   the MA part
//   (case when there is only one factor)
//         or a list of nf (nar x 1) or (1 x nar) string
//    vectors of MA parts
//   (case when there are nf factors)
// * listar = or a list of nvar (nar x 1) or (1 x nar) string
//    vectors of AR coefficients for the residuals of each
//    endogenous variable
// * initown = %t if the user wants to impose her own starting
//   values
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007-2008
// http://grocer.toolbox.free.fr/grocer.html
 
 
Gam=[]
C=[]
R=[]
S=[]
D=[]
H=[]
nvar=size(y,2)
nar=0
 
 
nargin=length(varargin)
for i=nargin:-1:1
   argi=varargin(i)
   if typeof(argi) == 'string' then
      argi=strsubst(argi,' ','')
      if part(argi,1:2) == 'Q=' then
         execstr('v'+varargin(i))
         varargin(i)=null()
      elseif part(argi,1:9) == 'loadings=' then
         execstr(varargin(i))
         varargin(i)=null()
      elseif part(argi,1:9) == 'R=' then
         execstr('v'+varargin(i))
         varargin(i)=null()
      end
   end
end
 
if initown then
   if ~exists('vQ','local')  then
      error('with the option ''init=own'', you must also enter starting values for Q')
   end
   if ~exists('loadings','local') then
      error('with the option ''init=own'', you must also enter starting values for loadings')
   end
end
 
nargin=length(listar)
nresid=0
resid=zeros(nargin,1)
for i=1:nargin
   resid(i)=(size(listar(i),'*')~=0)
   nresid=nresid+resid(i)
   nar=nar+size(listar(i),'*')
end
 
if nar == 0 then
   H2=[]
else
   H2=emptystr(nvar,nar)+'=0'
end
colH2=1
 
for i=1:nargin
   if resid(i) then
      H2(i,colH2)='=1'
      colH2=colH2+size(listar(i),'*')
   end
end
 
 
Phi=[]
nb_ARF=length(ARF)
nb_MAF=length(MAF)
if nb_ARF ~= nb_MAF then
   error('number of MA and AR terms have not the same size')
end
p0=[]
q0=[]
for i=1:nb_ARF
    ARFi=ARF(i)
    MAFi=MAF(i)
    nARFi=size(ARFi,'*')
    nMAFi=size(MAFi,'*')
    p0=[p0 nARFi]
    q0=[q0 nMAFi]
 
    if exists('loadings','local')
       H=[H , string(loadings(:,i))]
    else
       H=[H , emptystr(nvar,1)+'1']
    end
    if nARFi+nMAFi > 1 then
       H=[H , '='+string(zeros(nvar,nARFi+nMAFi-1))]
    end
end
 
H=[H H2]
 
Phi=emptystr(sum(p0)+sum(q0)+nar,sum(p0)+sum(q0)+nar)+'=0'
E=emptystr(sum(p0)+sum(q0)+nar,nb_ARF+nresid)+'=0'
Phic0=0
for i=1:nb_ARF
   Phi(Phic0+1,Phic0+1:Phic0+p0(i))=vec2row(string(-evstr(ARF(i))))
   Phi(Phic0+1,Phic0+p0(i)+1:Phic0+p0(i)+q0(i))=vec2row(string(MAF(i)))
 
   for j=Phic0+1:Phic0+p0(i)-1
      Phi(j+1,j)='=1'
   end
 
   for j=Phic0+p0(i)+1:Phic0+p0(i)+q0(i)-1
      Phi(j+1,j)='=1'
   end
 
   E(Phic0+1,i)='=1'
   if q0(i) ~= 0 then
      E(Phic0+p0(i)+1,i)='=1'
   end
 
   Phic0=Phic0+p0(i)+q0(i)
 
end
 
n0=sum(p0)+sum(q0)
i0=nb_ARF
for i=1:nargin
   ari=listar(i)
   n1=n0+size(listar(i),'*')
   if isempty(ari) then
      nR=size(R,1)
      if initown & exists('vR','local') then
         if nR == 0 then
            R=string(vR(1,1))
         else
            R=[R , '='+string(zeros(nR,1));
            '='+string(zeros(1,nR)) string(vR(nR+1,nR+1))]
         end
      elseif ~exists('vR','local') then
         if nR == 0 then
            R='1'
         else
            R=[R , '='+string(zeros(nR,1));
               '='+string(zeros(1,nR)) '1']
         end
      else
         error('with the option ''init=own'' & some empty ar, you must also enter starting values for R')
      end
 
      Ci=zeros(nvar,1)
      Ci(i)=1
      C=[C , '='+string(Ci)]
   else
      Phi(n0+1,n0+1:n1)=vec2row(listar(i))
      for i=n0+2:n1
         Phi(i,i-1)='=1'
      end
      E(n0+1,i0+1)='=1'
      i0=i0+1
   end
   n0=n1
end
 
Q=emptystr(nb_ARF+nresid,nb_ARF+nresid)+'=0'
if exists('vQ','local') then
   Q(1,1)='='+string(vQ(1,1))
   for i=2:nresid+nb_ARF
      Q(i,i)=string(vQ(i,i))
   end
else
   Q(1,1)='=0.5'
   for i=2:nb_ARF+nresid
      Q(i,i)='0.25'
   end
end
 
 
endfunction
 
