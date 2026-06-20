function [theta,theta2mat,thetalab,e4param,ineq,n1,mat2thet]=arma2param(m,AR,ARS,MA,MAS,V,index_theta,s,G,r,namexos)
 
// PURPOSE: explodes a Varmax model for estimation uses
// The input arguments corresponding to the model:
//   (I + AR1·B + ... +ARp·B^p)(I + ARS1·B^s + ... + ARSps·B^ps·s) y(t) =
//   (G0 + G1·B + ... + Gt·B^l) u(t) +
//   (I + MA1·B + ... + MAq·B^q)(I + MAS1·B^s + ... + MASqs·B^qs·s) e(t)
// are:
//   AR = [AR1 | ... | ARp]  ARS = [ARS1 | ... | ARSps]
//   G  = [G0 | G1 | ... | Gg]
//   MA = [MA1 | ... | MAq]  MAS = [MAS1 | ... | MASqs]
//
// ------------------------------------------------------------
// INPUT:
// * m = # of endogenous variables
// * AR = a string, representing the name of the AR part of the
//   model
// * ARS = a string, representing the name of the seasonal AR
//   part of the model
// * MA = a string, representing the name of the MA part of the
//   model
// * MAS = a string, representing the name of seasonal MA part
//   of the model
//   the names of FR, FS, AR and AS represent objects that can
//   be either of constant type or list type; in the last case,
//   the first item of the list should represent as in the first
//   case the starting value of the corresponding matrix, and
//   second one a string matrix, of same size, of constraints
//   ('' for no constraint, '=' for equality constraint,
//    'value<*', '*<value' or 'value1<*<value2' for inequality
//    constraints)
// * V = a (mxm) (var-covar) matrix
//     or a (mx1) vector (the diagonal of a var-covar matrix,
//     supposed to have 0 outside the diagonal)
// * s = order of seasonality
// * G = the coefficients martrix for the endogenous variables
//     (if any)
// * r = # of exogenous variables (if any)
// ------------------------------------------------------------
// OUTPUT:
// * theta = (npx1) vector of parameters that will be estimated
// * theta2mat = vector of strings, representing the
//   instructions that transform back theta into the input
//   parameters
// * V2theta = vector of strings, representing the instructions
//   that transform V into the corresponding parameters in
//   theta
// * theatlab = (npx1) vector of strings, representing theta
//   names used when printing the results
// * FR = the AR part of the model
// * FS = the seasonal AR part of the model
// * AR = the MA part of the model
// * AS = the seasonal MA part of the model
// * G = the coefficients matrix for the endogenous variables
// * V = the (mxm) (var-covar) matrix
// * p = degree of the AR part of the model
// * P = degree of the seasonal AR part of the model
// * q = degree of the MA part of the model
// * Q = degree of the seasonal MA part of the model
// * s = order of seasonality
// * k = maximum degree of the total AR, MA and G parts
// * n = k*m
// * np = # of estimated parameters
// * %type = type of the e4 model
// * vdiag = 0 if V is diagonal, 1 if not
// ------------------------------------------------------------
// Copyright Eric Dubois 2004-2008
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin] = argn(0)
if nargin<7|(nargin>8)&(nargin~=11) then
  error('Incorrect number of arguments');
end
if nargin<8 then
  s = 1;
end
s = round(s);
if s<=0 then
  s = 1;
end
 
// set initial values
theta=[]
theta2mat=[]
mat2thet=[]
thetalab=[]
ineq=[]
 
if nargin<9 then
   r = 0;
   G = [];
   g=0
end
 
// add AR to theta, theta2mat and thetalab
[theta0,theta2mat0,thetalab0,AR,index_theta,ineq,mat2thet0]=mat2theta('AR',index_theta,ineq,%f,m,m)
theta=[theta ; theta0]
theta2mat=[theta2mat ; theta2mat0]
mat2thet=[mat2thet ;mat2thet0]
thetalab=[thetalab ; thetalab0]
 
// add ARS to theta, theta2mat and thetalab
[theta0,theta2mat0,thetalab0,ARS,index_theta,ineq,mat2thet0]=mat2theta('ARS',index_theta,ineq,%f,m,m)
theta=[theta ; theta0]
theta2mat=[theta2mat ; theta2mat0]
mat2thet=[mat2thet ;mat2thet0]
thetalab=[thetalab ; thetalab0]
 
// add MA to theta, theta2mat and thetalab
[theta0,theta2mat0,thetalab0,MA,index_theta,ineq,mat2thet0]=mat2theta('MA',index_theta,ineq,%f,m,m)
theta=[theta ; theta0]
theta2mat=[theta2mat ; theta2mat0]
mat2thet=[mat2thet ;mat2thet0]
thetalab=[thetalab ; thetalab0]
 
// add MAS to theta, theta2mat and thetalab
[theta0,theta2mat0,thetalab0,MAS,index_theta,ineq,mat2thet0]=mat2theta('MAS',index_theta,ineq,%f,m,m)
theta=[theta ; theta0]
theta2mat=[theta2mat ; theta2mat0]
mat2thet=[mat2thet ;mat2thet0]
thetalab=[thetalab ; thetalab0]
 
p = size(AR,2)/m;
P = size(ARS,2)/m;
q = size(MA,2)/m;
Q = size(MAS,2)/m;
inpmax = 0;
 
ysize=[size(AR,1) ; size(ARS,1) ; size(MA,1) ; size(MAS,1) ; size(V,1) ; size(G,1)]
if and(ysize == 0) then
   error('no parameter to estimate')
else
   m=max(ysize)
   for i=1:6
      if ysize(i) ~= 0 & ysize(i) ~= m then
         error('format of matrices AR, ARS, MA, MAS, V and G are not conformable')
      end
   end
end
 
vdiag=0
if size(V,2)==1 then
  vdiag = 1
end
 
// add exogenous variables to theta,theta2mat and thetalab
if r then
   nG = size(G,2)
   if nG-fix(nG/r)*r then
      error('Incorrect model specification');
   elseif size(G,1)~=m then
      error('size of intial exogenous parameters and of endogenous variables not matching')
   else
      g = size(G,2)/r;
   end
   [theta0,theta2mat0,thetalab0,G,index_theta,ineq,mat2thet0]=mat2theta('G',index_theta,ineq,%f,m,r)
 
   if g==1 then
      thetalab0 = strsubst(thetalab0,'- lag 1','')
   end
   if r == 1 then
      thetalab0 = strsubst(thetalab0,'G',namexos)
   else
      thetalab0 = strsubst(thetalab0,'G ','')
      for i=1:r
         execstr('thetalab0=strsubst(thetalab0,''var # '+string(i)+''','''+namexos(i)+''')')
      end
   end
   theta=[theta ; theta0]
   theta2mat=[theta2mat ; theta2mat0]
   mat2thet=[mat2thet ;mat2thet0]
   thetalab=[thetalab ; thetalab0]
 
   G2theta=mat2thet0
 
else
 
   G2theta = []
 
end
n1=size(thetalab,1)
 
k=max([p+P*s,q+Q*s,g])
if k == 0 then
   error('you have no parameters to estimate')
end
// add V to theta, theta2mat and thetalab
[theta0,theta2mat0,thetalab0,V,index_theta,ineq,mat2thet0]=mat2theta('V',index_theta,ineq,%t,m)
theta=[theta ; theta0]
theta2mat=[theta2mat ; theta2mat0]
mat2thet=[mat2thet ;mat2thet0]
if length(V) == 1 then
   thetalab=[thetalab ; 'V']
else
   thetalab=[thetalab ; thetalab0]
end
 
// create the V to theta transformation (for preest1)
V2theta=theta2mat0
sV2theta=size(theta2mat0,1)
if sV2theta == 1 & strindex(theta2mat0(1),'vech') ~= [] then
// this part of theta is the vech transformation of V
   scomma=strindex(theta2mat0,',')
   V2theta='theta('+part(theta2mat0,strindex(theta2mat0,'theta')+6:strindex(theta2mat0,',')-1)+'=vech(V)'
else
   for i=1:size(theta2mat0,1)
      sep=strindex(theta2mat0(i),'=')
      V2theta(i)=part(theta2mat0(i),sep+1:length(theta2mat0(i)))+'='+...
      part(theta2mat0(i),1:sep-1)
      isdiag=strindex(V2theta(i),'diag(')
      if isdiag ~= [] then
         V2theta(i)=strsubst(V2theta(i),'diag(','')
         V2theta(i)=strsubst(V2theta(i),')=','=diag(')
         V2theta(i)=part(V2theta(i),1:length(V2theta(i)))+')'
      end
   end
end
 
e4param=struct('AR',AR,'MA',MA,'ARS',ARS,'MAS',MAS,'G',G,'V',V,'s',s,'p',p,'P',P,'q',q,'Q',Q,...
'g',g,'m',m,'r',r,'k',k,'n',k*m,'np',size(theta,1),'vdiag',vdiag,'typ',1,'innov',1,...
'V2theta',V2theta,'G2theta',G2theta)
 
endfunction
 
