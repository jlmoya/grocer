function result=kalm1(y,Phi,Gam,E,H,D,C,Q,r,m,S,R,u)
 
// PURPOSE:
// The SS formulation is:
//    x(t+1) = Phi·x(t) + Gam·u(t) + E·w(t)
//    y(t)   = H·x(t)   + D·u(t)   + C·v(t)
//    V(w(t) v(t)) = [Q S; S' R];
// ------------------------------------------------------------
// INPUT:
// *
// ------------------------------------------------------------
// OUTPUT:
// *
// ------------------------------------------------------------
// Copyright Eric Dubois 2006
// http://grocer.toolbox.free.fr/grocer.html
 
[grocer_E4OPTION]=e4init()
grocer_theta2ss=theta2ssss
grocer_E4OPTION=sete4opt(grocer_E4OPTION,'vcond','idej','econd','zero','var','fac');
 
[grocer_e4_theta,grocer_e4_theta2mat,grocer_e4_V2theta,grocer_e4_thetalab,grocer_Phi,...
grocer_Gam,grocer_E,grocer_H,grocer_D,grocer_C,grocer_Q,grocer_S,grocer_R,...
grocer_e4_g,n,grocer_e4_np,grocer_e4_type,grocer_e4_ineq,grocer_e4_innov,grocer_e4_vdiag]=ss2param(Phi,Gam,E,H,D,C,Q,S,R)
 
grocer_e4_filtk = 0;
if grocer_E4OPTION(1)==1 then
  grocer_e4_filtk = 1;
end
grocer_e4_scaleb = grocer_E4OPTION(2);
grocer_e4_vcond = grocer_E4OPTION(3);
grocer_e4_econd = grocer_E4OPTION(4);
grocer_e4_zeps = grocer_E4OPTION(15)
grocer_e4_deps = .00000001;
grocer_e4_userflag=0
 
grocer_e4_z=[y u]
 
[grocer_e4_T,grocer_e4_m]=size(y)
grocer_e4_r=size(u,2)
grocer_e4_delta=sqrt(%eps)
if (grocer_e4_econd==2) then
  grocer_e4_MV = 1;
else
  grocer_e4_MV = 0;
end
grocer_e4_filtk = 0;
if grocer_E4OPTION(1)==1 then
  grocer_e4_filtk = 1;
end
 
theta = e4prees1(grocer_e4_theta,grocer_e4_theta2mat,grocer_e4_z);
grocer_e4_theta2mat2=''''+grocer_e4_theta2mat+''''
grocer_g=zeros(grocer_e4_np,1)
grocer_e4_str2f='deff(''[f,grocer_g,ind]=grocer_e4_lffast(p,ind)'',[''f=lffast(p,grocer_e4_theta2mat,grocer_e4_z)'
for i=1:grocer_e4_np
   aux=grocer_e4_delta*[zeros(i-1,1);1;zeros(grocer_e4_np-i,1)]
   grocer_e4_str2f=grocer_e4_str2f+...
   ''';''grocer_g('+string(i)+')=(lffast(p+['...
   +joinstr(string(aux),';')+'],grocer_e4_theta2mat,grocer_e4_z)-lffast(p-['+joinstr(string(aux),';')+'],grocer_e4_theta2mat,grocer_e4_z))/2/'+string(grocer_e4_delta)
end
grocer_e4_str2f=grocer_e4_str2f+'''])'
execstr(grocer_e4_str2f)
 
sqrteps=sqrt(%eps)
//sqrteps=1e-3
 
if or(grocer_e4_ineq(:,1) ~= -%inf) | or(grocer_e4_ineq(:,2) ~= %inf) then
// there are inequality constraints
   [f,theta,g] = optim(grocer_e4_lffast,'b',grocer_e4_ineq(:,1),grocer_e4_ineq(:,2),theta);
   if g'*g > sqrteps then
// numerical estimation has failed to provide acurate
// estimate; then, use the exact derivative
      [f,theta,g] = optim(lfmod_gmod_103,'b',grocer_e4_ineq(:,1),grocer_e4_ineq(:,2),theta);
   end
 
else
// there is no inequality constraint
   [f,theta,g] = optim(grocer_e4_lffast,theta);
   [f,g]=lfmod_gmod_103(theta)
   if g'*g > sqrt(%eps) then
      [f,theta,g] = optim(lfmod_gmod_103,theta);
   end
end
 
// return to the original values and recover the true likelihood
[Phi,Gam,E,H,D,C,Q,S,R]=theta2ssss(theta,grocer_e4_theta2mat)
[f,z1,zT]=lffast(theta,grocer_e4_theta2mat,grocer_e4_z)
 
grocer_E4OPTION(5)=0
execstr(grocer_e4_V2theta)
[std,corrm,varm,Im] = imod(theta,grocer_e4_theta2mat,grocer_e4_z,0,1);
tstat=theta ./ std
AIC = 2*(f+grocer_e4_np)/grocer_e4_T
BIC = (2*f+grocer_e4_np*log(grocer_e4_T))/grocer_e4_T
 
result=tlist(['results';'meth';'y';'x';'z';'nobs';'nendo';'nvar';'coeff';'lab';'like';'grad';...
'tstat';'std';'exact';'cov';'AIC';'BIC';'theta2mat';'nexo';'resid';...
'Phi';'Gam';'E';'H';'D';'C';'Q';'S';'R';'type';'userflag';'innov';'econd';'vcond';'filtk';'E4OPTION'],...
'kalman',y,u,grocer_e4_z,grocer_e4_T,grocer_e4_m,grocer_e4_np,theta,...
grocer_e4_thetalab,-f,-g,tstat,std,%t,corrm,AIC,BIC,grocer_e4_theta2mat,grocer_e4_r,z1,...
Phi,Gam,E,H,D,C,Q,S,R,grocer_e4_type,%f,grocer_e4_innov,...
grocer_e4_econd,grocer_e4_vcond,grocer_e4_filtk,grocer_E4OPTION)
 
endfunction
 
