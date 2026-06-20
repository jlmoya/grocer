function [theta,f]=e4prees1(theta,theta2mat,z)
 
// PURPOSE: Provides a quick estimation of the parameters of a
// model using a subspace representation model where the
// future of the output is expressed as a linear function of
// its past and the information in the input
// ------------------------------------------------------------
// INPUT:
// * theta = (npx1) vector of starting values for the
//   parameters
// * theta2mat = a string vector of instructions that
//   transforms theta into the matrices FR, FS, AR, AS, V and G
// * z = matrix of endogenous variables
// ------------------------------------------------------------
// OUTPUT:
// * theta = (npx1) vector of estimated parameters
// ------------------------------------------------------------
// NOTE:
// This function does not work with composite models.
// ------------------------------------------------------------
// Copyright Jaime Terceiro, 1997/
// Eric Dubois 2003 for the Scilab translation
// http://grocer.toolbox.free.fr/grocer.html
 
[nargout,nargin] = argn(0)
 
if nargin<3 then
  error('Incorrect number of arguments');
end
[Phi,Gam,E,H,D,C,Q,S,R] = grocer_theta2ss(theta,theta2mat);
N = size(z,1);
n = size(Phi,1);
m = size(H,1);
r = max([size(Gam,2),size(D,2)]);
innov=grocer_e4param.innov
 
if size(z,2)~=(m+r) then
  error('Inconsistent input arguments:');
end
 
if or(abs(spec(Phi))>=grocer_E4OPTION('tol eigv')) then
  stat = 0;
else
  stat = 1;
end
if stat|innov then
  offs = 0;
else
  offs = 1;
end
 
i = max(round(log(N)),ceil(n/m)+2+offs);
 
if N<(2*i*(m+r+1-stat)-1) then
  j = max(fix((N-i*(m+r+1)+1)/(m+r+1)),ceil(n/m)+1);
else
  j = i;
end
ij = i+j;
 
if N<(ij*(m+r+1-stat)-1) then
  i = ceil(n/m)+1+offs;
  j = i;
  ij = i+j;
  if N<(i*(m+r+1-stat)+j*(r+1-stat)-1) then
    error('Not enough data for using e4prees1');
  end
end
 
missing = or(isnan(z(:,1:m)));
if missing then
  z2 = z;
  for h = 1:m
    k = matrix(find(isnan(z(:,h))),1,-1);
    sk = size(k,1);
    if sk then
      k2 = find((k-[min(0,k(1)-2);k(1:sk-1)])>1);
 
      if size(k2,1)<=1 then
        if k(1)==1 then
          z1 = z(k(sk)+1,h);
        elseif k(sk)==N then
          z1 = z(k(1)-1,h);
        else
          z1 = (z(k(sk)+1,h)+z(k(1)-1,h))/2;
        end
        z2(k,h) = z1*ones(sk,1);
      else
        if k(1)==1 then
          z1 = z(k(k2(2)-1)+1,h);
        else
          z1 = (z(k(k2(2)-1)+1,h)+z(k(1)-1,h))/2;
        end
        z2(k(k2(1)):k(k2(2)-1),h) = z1*ones(k(k2(2)-1)-k(k2(1))+1,1);
 
        for l = 2:size(k2,1)-1
          z2(k(k2(l)):k(k2(l+1)-1),h) = (z(k(k2(l))-1,h)+z(k(k2(l+1)-1)+1,h))/2*ones(k(k2(l+1)-1)-k(k2(l))+1,1);
        end
 
        if k(sk)==N then
          z1 = z(k(k2(l+1))-1,h);
        else
          z1 = (z(k(sk)+1,h)+z(k(k2(l+1))-1,h))/2;
        end
        z2(k(k2(l+1)):k(sk),h) = z1*ones(k(sk)-k(k2(l+1))+1,1);
      end
    end
  end
end
 
if r then
  Yi = blkhkel(z(:,1:m),ij,1,stat);
  N = min(size(Yi,2),size(z,1));
  if missing then
    K = or(isnan(Yi),1);
    Yi = blkhkel(z2(:,1:m)*N/(N-sum(K)/2),ij,1,stat);
    Ui = blkhkel(z(:,m+1:m+r)*N/(N-sum(K)/2),ij,1,stat);
    Yi(:,K) = Yi(:,K)/2;
    Ui(:,K) = Ui(:,K)/2;
  else
    Ui = blkhkel(z(:,m+1:m+r),ij,1,stat);
  end
  [Q,R]= qr([Ui(r*i+1:r*ij,:);Ui(1:r*i,:);Yi]')
  Q = Q(:,1:size(R,2))
  R = R(1:size(R,2),:)
  ix = zeros(5,2);
  ix(:,1) = [1;j*r+1;ij*r+1;ij*r+i*m+1;ij*r+(i+1)*m+1];
  ix(:,2) = [ix(2:5,1)-1;ij*(m+r)];
  R = R'/sqrt(N);
else
  Yi = blkhkel(z,ij,1,stat);
  N = min(size(Yi,2),size(z,1));
  if missing then
    K = or(isnan(Yi),1)
    Yi = blkhkel(z2(:,1:m)*N/(N-mtlb_sum(K)/2),ij,1,stat);
    Yi(:,K) = Yi(:,K)/2;
  end
  [Q,R]= qr(Yi')
  Q = Q(:,1:size(R,2))
  R = R(1:size(R,2),:)
  R = R'/sqrt(N);
  ix = zeros(3,2);
  if stat|grocer_e4_innov then
    ix(:,1) = [1;i*m+1;(i+1)*m+1];
  else
    ix(:,1) = [m+1;i*m+1;(i+1)*m+1];
  end
  ix(:,2) = [ix(2:3,1)-1;ij*m];
end
 
if size(R,1)>size(R,2) then
  R = [R,zeros(size(R,1),size(R,1)-size(R,2))];
  pond = 0;
else
  if stat|grocer_e4_innov then
    pond = 1;
  else
    pond = 0;
  end
end
 
sth = size(theta,1);
 
k = size(theta,1)
if k~= 0 then
   ij=[i,j,pond,N];
   if innov then
      deff('[f,g,ind]=grocer_e4_cost(p,ind,theta2mat,R,ix,ij)',['f=e4prees2(p,theta2mat,R,ix,ij)' ; ...
          'g=numz0(e4prees2,p,sth,ones(sth,1),1e-5,theta2mat,R,ix,ij)']);
      [f,theta] = optim(list(grocer_e4_cost,theta2mat,R,ix,ij),theta)
 
   else
      deff('[f,g,ind]=grocer_e4_cost(p,ind,theta2mat,R,ix,ij)',...
      ['f=e4prees3(p,theta2mat,R,ix,ij)' ;...
       'g=numz0(e4prees3,p,sth,ones(sth,1),1e-5,theta2mat,R,ix,ij)']);
      [f,theta] = optim(list(grocer_e4_cost,theta2mat,R,ix,ij),theta)
 
      [f,KB] = e4prees3(theta,theta2mat,R,ix,[i,j,pond,N]);
      theta(1:k,1) = trace(KB(n+1:n+m,:))*ones(k,1);
   end
else
  pond = 0;
end
 
if innov then
  if pond then
    [f,V] = e4prees2(theta,theta2mat,R,ix,[i,j,pond,N]);
  else
    if missing then
      [f,e] = lfmiss(theta,theta2mat,z);
    else
      [f,e] = lffast(theta,theta2mat,z);
    end
    V = e'*e/size(z,1);
  end
 
  if grocer_E4OPTION('var') == 'factorized' then
    V = cholp(V)';
  end
  execstr(grocer_e4param.V2theta)
end
 
endfunction
