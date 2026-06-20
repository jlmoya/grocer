function [theta,theta2mat,thetalab,e4param,ineq,Phi,Gam,E,H,D,C,Q,S,R,mat2thet]=ss2param(Phi,Gam,E,H,D,C,Q,r,m,S,R)
 
// PURPOSE:
// The SS formulation is:
//    x(t+1) = Phi·x(t) + Gam·u(t) + E·w(t)
//    y(t)   = H·x(t)   + D·u(t)   + C·v(t)
//    V(w(t) v(t)) = [Q S; S' R];
// ------------------------------------------------------------
// INPUT:
// * Phi = a (
// ------------------------------------------------------------
// OUTPUT:
// * theta = (npx1) vector of parameters that will be estimated
// * theta2mat = vector of strings, representing the
//   instructions that transform back theta into the input
//   parameters
// * V2theta = vector of strings, representing the instructions
//   that transform V into the corresponding parameters in
//   theta
// * theatlab = (np x 1) vector of strings, representing theta
//   names used when printing the results
// * FR = the AR part of the model
// * FS = the seasonal AR part of the model
// * AR = the MA part of the model
// * AS = the seasonal MA part of the model
// * G = the coefficients matrix for the endogenous variables
// * V = the (mxm) (var-covar) matrix
// * n = k*m
// * np = # of estimated parameters
// * %type = type of the e4 model
// ------------------------------------------------------------
// Copyright Eric Dubois 2004-2019
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin] = argn(0)
%type=7
 
// set initial values
index_theta=0
theta=[]
theta2mat=[]
mat2thet=[]
thetalab=[]
ineq=[]
innov=0
 
lab=['Phi';'E';'H';'C']
 
index_theta=0
 
for i=1:4
// add lab(i) to theta, theta2mat and thetalab
   execstr('[theta0,theta2mat0,thetalab0,'+lab(i)+',index_theta,ineq,mat2thet0]=mat2thetas('''+lab(i)+''',index_theta,ineq,m)')
   theta=[theta ; theta0]
   mat2thet=[mat2thet ; mat2thet0]
   theta2mat=[theta2mat ; theta2mat0]
   thetalab=[thetalab ; thetalab0]
end
 
 
// add Q to theta, theta2mat and thetalab
[theta0,theta2mat0,thetalab0,Q,index_theta,ineq,mat2thet0]=mat2theta('Q',index_theta,ineq,%t,m,1)
theta=[theta ; theta0]
theta2mat=[theta2mat ; theta2mat0]
mat2thet=[mat2thet ; mat2thet0]
if size(thetalab0,'*') == 1 then
   thetalab=[thetalab ; 'Q']
else
   thetalab=[thetalab ; thetalab0]
end
 
// create the Variances to theta transformation (for preest1)
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
 
if exists('S','local') then
   if ~isempty(S) then
 
   // add S to theta, theta2mat and thetalab
      [theta0,theta2mat0,thetalab0,S,index_theta,ineq,mat2thet0]=mat2theta('S',index_theta,ineq,%t,1)
      theta=[theta ; theta0]
      mat2thet=[mat2thet ; mat2thet0]
      theta2mat=[theta2mat ; theta2mat0]
      if size(thetalab0,'*') == 1 then
         thetalab=[thetalab ; 'S']
      else
         thetalab=[thetalab ; thetalab0]
      end
 
      sV2theta=size(theta2mat0,1)
      if sV2theta == 1 & strindex(theta2mat0(1),'vech') ~= [] then
         // this part of theta is the vech transformation of V
         scomma=strindex(theta2mat0,',')
         V2theta=[V2theta ; 'theta('+part(theta2mat0,strindex(theta2mat0,'theta')+6:strindex(theta2mat0,',')-1)+'=vech(V)']
      else
         nV0=size(V2theta,1)
      // update the Variances to theta transformation (for preest1)
         V2theta=[V2theta ; theta2mat0]
 
         for i=1:size(theta2mat0,1)
            sep=strindex(theta2mat0(i),'=')
            V2theta(nV0+i)=part(theta2mat0(i),sep+1:length(theta2mat0(i)))+'='+...
            part(theta2mat0(i),1:sep-1)
            isdiag=strindex(V2theta(i),'diag(')
            if isdiag ~= [] then
               V2theta(nV0+i)=strsubst(V2theta(nV0+i),'diag(','')
               V2theta(nV0+i)=strsubst(V2theta(nV0+i),')=','=diag(')
               V2theta(nV0+i)=part(V2theta(nV0+i),1:length(V2theta(nV0+i)))+')'
            end
         end
      end
   end
 
elseif size(Q,1) == m then
   innov=1
end
 
if exists('R','local') then
   if ~isempty(R) then
   // add R to theta, theta2mat and thetalab
      [theta0,theta2mat0,thetalab0,R,index_theta,ineq,mat2thet0]=mat2theta('R',index_theta,ineq,%t,m,1)
      theta=[theta ; theta0]
      mat2thet=[mat2thet ; mat2thet0]
      theta2mat=[theta2mat ; theta2mat0]
      if length(R) == 1 then
         thetalab=[thetalab ; 'R']
      else
         thetalab=[thetalab ; thetalab0]
      end
 
      sV2theta=size(theta2mat0,1)
      if sV2theta == 1 & strindex(theta2mat0(1),'vech') ~= [] then
         // this part of theta is the vech transformation of V
         scomma=strindex(theta2mat0,',')
         V2theta=[V2theta ; 'theta('+part(theta2mat0,strindex(theta2mat0,'theta')+6:strindex(theta2mat0,',')-1)+'=vech(V)']
      else
         nV0=size(V2theta,1)
      // update the Variances to theta transformation (for preest1)
         V2theta=[V2theta ; theta2mat0]
 
         for i=1:size(theta2mat0,1)
            sep=strindex(theta2mat0(i),'=')
            V2theta(nV0+i)=part(theta2mat0(i),sep+1:length(theta2mat0(i)))+'='+...
            part(theta2mat0(i),1:sep-1)
            isdiag=strindex(V2theta(i),'diag(')
            if isdiag ~= [] then
               %type=%type+2
               V2theta(nV0+i)=strsubst(V2theta(nV0+i),'diag(','')
               V2theta(nV0+i)=strsubst(V2theta(nV0+i),')=','=diag(')
               V2theta(nV0+i)=part(V2theta(nV0+i),1:length(V2theta(nV0+i)))+')'
            end
         end
      end
   end
end
 
// add exogenous variables to theta,theta2mat and thetalab
nG = size(Gam,2)
G2theta=[]
 
if ~isempty(Gam) then
 
   g = size(Gam,2)/r;
   [theta0,theta2mat0,thetalab0,Gam,index_theta,ineq,mat2thet0]=mat2thetas('Gam',index_theta,ineq,m)
 
   if g==1 then
      thetalab0 = strsubst(thetalab0,'- lag 1','')
   end
 
   theta=[theta ; theta0]
   theta2mat=[theta2mat ; theta2mat0]
   thetalab=[thetalab ; thetalab0]
   mat2thet=[mat2thet ; mat2thet0]
 
   G2theta=theta2mat0
   for j=1:size(theta2mat0,1)
      indequ=strindex(G2theta(j),'=')
      G2theta(j)=part(G2theta(j),indequ+1:length(G2theta(j)))+'='+part(G2theta(j),1:indequ-1)
   end
 
end
 
if ~isempty(D) then
 
   d = size(D,2)/r;
   [theta0,theta2mat0,thetalab0,D,index_theta,ineq,mat2thet0]=mat2thetas('D',index_theta,ineq,m)
   if d==1 then
      thetalab0 = strsubst(thetalab0,'- lag 1','')
   end
 
   theta=[theta ; theta0]
   theta2mat=[theta2mat ; theta2mat0]
   thetalab=[thetalab ; thetalab0]
   mat2thet=[mat2thet ; mat2thet0]
 
end
 
n1=size(thetalab,1)
 
n=size(Phi,1)
m = size(H,1)
k=n/m
g=max([size(Gam,2),size(D,2)])
 
np=size(theta,1)
vdiag=1
 
e4param=struct('Phi',Phi,'Gam',Gam,'E',E,'H',H,'D',D,'C',C,'Q',Q...
,'S',S,'R',R,'g',g,'n',n,'np',np,'vdiag',vdiag,'typ',%type,'innov',innov,...
'm',m,'k',k,'r',r,'V2theta',V2theta,'G2theta',G2theta)
 
endfunction
