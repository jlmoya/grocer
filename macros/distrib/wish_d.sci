function []=wish_d()
 
// PURPOSE: demo of random draws from a Wishart distribution
 
 
 
ndraws = 1000;
n = 100;
k = 5;
x = rand(n,5,'n');
xpx = x'*x;
xpxi = inv(xpx);
v = 10;
 
w = zeros(k,k);
for i = 1:ndraws
  w = w+wish_rnd(xpx,v);
end
 
write(%io(2),'mean of wishart should = ','(a)');
disp(v*xpx);
write(%io(2),' ','(a)');
 
write(%io(2),'mean of wishart draws =','(a)');
disp(w/ndraws);
write(%io(2),' ','(a)');
 
endfunction
