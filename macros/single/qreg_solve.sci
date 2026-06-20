function [y] = qreg_solve(c,a,b,u,sv,maxit,eps,big,sigma);
 
grocer_ieee=ieee();
ieee(2);
 
[k,n] = size(a);
[y,r,p] = olsqr2(c,a');
z = r .* bool2s(r  >  0);
w = z - r;
 
x = sv;
s = u - x;
gap = c'*x - b'*y + u'*w;
 
mu = %nan;
 
it = 1;
while (it <= maxit)  &  (gap > eps) then
   q  =ones(n,1) ./(z ./x +w ./ s);
   r  = z - w;
   dy =(a*((q .*.ones(1,k)) .* a')) \ (a*(q .* r)) ;
   dx = q .* (a'*dy-r);
   ds = -dx;
   dz =(-z .* dx) ./ x - z;
   dw =(-w .* ds) ./ s - w;
 
   deltap = min([ (bool2s(dx  <  0) .* (-x ./ dx) )+ big * bool2s(dx  >=  0) ;  ...
                   (bool2s(ds  <  0) .* (-s ./ ds) )+ big * bool2s(ds  >=  0)]);
 
   deltad = min([ (bool2s(dz  <  0) .* (-z ./ dz) )+ big * bool2s(dz  >=  0) ;  ...
                   (bool2s(dw  <  0) .* (-w ./ dw) )+ big * bool2s(dw  >=  0)]);
 
   deltap = min([(sigma*deltap);1]);
   deltad = min([(sigma*deltad);1]);
   if  min([deltap;deltad]) < 1 then

      mu = x'*z + s'*w;
      g  = ( x + deltap * dx )'*( z + deltad * dz )  ...
           + ( s + deltap * ds )'*( w + deltad * dw );
      mu =g^3 / (mu^2* 2 * n);
 
      dxdz = dx .* dz ;
      dsdw =ds .* dw;
      xinv = 1 ./ x;
      sinv = 1 ./ s;
 
      xi = mu * (xinv - sinv);
 
      dy =(a*((q .*.ones(1,k)) .* a')) \ ( (a*(q .* r) + ((q' .*.ones(k,1)) .* a)*(dxdz - dsdw - xi)) );
      dx =q .* (a'*dy + xi - r - (dxdz - dsdw));
      ds = -dx;
      dz = mu * xinv - z - (xinv .* z .* dx )- dxdz;
      dw = mu * sinv - w - (sinv .* w .* ds )- dsdw;
 
      deltap = min([ (bool2s(dx  <  0) .* (-x ./ dx) )+ big * bool2s(dx  >=  0) ;  ...
                   (bool2s(ds  <  0) .* (-s ./ ds) )+ big * bool2s(ds  >=  0)]);
 
      deltad = min([ (bool2s(dz  <  0) .* (-z ./ dz) )+ big * bool2s(dz  >=  0) ;  ...
                   (bool2s(dw  <  0) .* (-w ./ dw) )+ big * bool2s(dw  >=  0)]);
 
      deltap = min([(sigma*deltap);1]);
      deltad = min([(sigma*deltad);1]);
   end;
 
   x = x + deltap * dx;
   s = s + deltap * ds;
   y = y + deltad * dy;
   z = z + deltad * dz;
   w = w + deltad * dw;
 
   gap = c'*x - b'*y + u'*w;
 
   it = it + 1;
end;
 

 
ieee(grocer_ieee);
 
endfunction;
